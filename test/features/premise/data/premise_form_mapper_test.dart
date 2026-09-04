import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/premise/data/mappers/premise_census_image_mapper.dart';
import 'package:ilms/features/premise/data/mappers/premise_form_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_submit_payload_model.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';

void main() {
  group('PremiseFormMapper', () {
    test('maps text fields into domain aggregate', () {
      final fields = PremiseFormFields();
      fields.companyName.text = 'ACME SDN BHD';
      fields.registerNumber.text = '123456-A';
      fields.businessType.text = 'Retail';
      fields.traderName.text = 'ACME TRADING';

      final form = PremiseFormMapper.fromPresentation(
        fields: fields,
        censusImages: [PremiseCensusImageMapper.fromLocalCapture(localPath: '/tmp/a.jpg')],
        businessTypeCode: 'RETAIL',
        businessTypeDesc: 'Retail',
      );

      expect(form.companyContact.companyName, 'ACME SDN BHD');
      expect(form.companyContact.registerNumber, '123456-A');
      expect(form.details.traderName, 'ACME TRADING');
      expect(form.details.businessTypeCode, 'RETAIL');
      expect(form.details.businessTypeDescription, 'Retail');
      expect(form.censusImages, hasLength(1));

      fields.dispose();
    });

    test('business/premise type code comes from the selected value, never parsed from display text', () {
      final fields = PremiseFormFields();
      // The display text shows only the description (e.g. "Office"), which
      // has no "code - desc" separator to parse — the real code ("OF") must
      // come from the explicit businessTypeCode/premiseTypeCode args, not be
      // re-derived from this text (that would silently send "Office" as the
      // code).
      fields.businessType.text = 'Office';
      fields.premiseType.text = 'Office';

      final form = PremiseFormMapper.fromPresentation(
        fields: fields,
        censusImages: const [],
        businessTypeCode: 'OF',
        businessTypeDesc: 'Office',
        premiseTypeCode: 'OF',
        premiseTypeDesc: 'Office',
      );

      expect(form.details.businessTypeCode, 'OF');
      expect(form.details.businessTypeDescription, 'Office');
      expect(form.details.premiseTypeCode, 'OF');
      expect(form.details.premiseTypeDescription, 'Office');

      fields.dispose();
    });

    test('state/postcode codes come from the selection, never parsed from display text', () {
      final fields = PremiseFormFields();
      // Picker fields show the description only, so there is no code to parse
      // out of the text — re-deriving it here would send "KUALA LUMPUR" as the
      // state code and "Kuala Lumpur" as the postcode.
      fields.state.text = 'Kuala Lumpur';
      fields.postcode.text = 'Kuala Lumpur';

      final form = PremiseFormMapper.fromPresentation(
        fields: fields,
        censusImages: const [],
        stateCode: '14',
        postcode: '50100',
      );

      expect(form.companyContact.stateCode, '14');
      expect(form.companyContact.stateDescription, 'Kuala Lumpur');
      expect(form.companyContact.postcode, '50100');

      fields.dispose();
    });

    test('falls back to parsing a legacy "code : desc" draft when no code is passed', () {
      final fields = PremiseFormFields();
      fields.state.text = 'WP : Wilayah Persekutuan';

      final form = PremiseFormMapper.fromPresentation(fields: fields, censusImages: const []);

      expect(form.companyContact.stateCode, 'WP');

      fields.dispose();
    });

    test('sends the full area display text as areaDescription, never truncated', () {
      final fields = PremiseFormFields();
      // The area field shows the area's plain description, which may itself
      // contain a " - " separator (e.g. area name - locality) — this must not
      // be mistaken for a "code - desc" pair and truncated. The backend's
      // `area` field expects this full text verbatim (it mirrors
      // premise_addresses[*][area]).
      fields.area.text = 'SEGAMBUT - DESA SERI HARTAMAS';

      final form = PremiseFormMapper.fromPresentation(
        fields: fields,
        censusImages: const [],
        areaCode: 'SEGAMBUT',
      );

      expect(form.companyContact.areaCode, 'SEGAMBUT');
      expect(form.companyContact.areaDescription, 'SEGAMBUT - DESA SERI HARTAMAS');

      fields.dispose();
    });

    test('falls back to parsing the area code from display text when none is given', () {
      final fields = PremiseFormFields();
      fields.area.text = 'SEGAMBUT - DESA SERI HARTAMAS';

      final form = PremiseFormMapper.fromPresentation(fields: fields, censusImages: const []);

      // Best-effort only — used for internal lookups, never for the submitted
      // `area` payload value, which always uses the untouched full text.
      expect(form.companyContact.areaCode, 'SEGAMBUT');
      expect(form.companyContact.areaDescription, 'SEGAMBUT - DESA SERI HARTAMAS');

      fields.dispose();
    });
  });

  group('PremiseSubmitPayloadModel', () {
    test('builds create payload without images', () {
      final fields = PremiseFormFields();
      fields.companyName.text = 'ACME SDN BHD';
      fields.traderName.text = 'ACME TRADING';

      final form = PremiseFormMapper.fromPresentation(fields: fields, censusImages: const []);
      final payload = PremiseSubmitPayloadModel.fromDomain(form).toCreateJson();

      expect(payload['company_details'], isA<Map>());
      expect(payload['premise_details'], isA<Map>());
      expect(payload.containsKey('images'), isFalse);

      fields.dispose();
    });

    test('sends business/premise type code, not the display description', () {
      final fields = PremiseFormFields();
      fields.companyName.text = 'ACME SDN BHD';
      fields.traderName.text = 'ACME TRADING';
      // Picker stores description-only labels — these must not leak into the
      // `business_type` / `premise_type` code fields.
      fields.businessType.text = 'Office';
      fields.premiseType.text = 'Shoplot';

      final form = PremiseFormMapper.fromPresentation(
        fields: fields,
        censusImages: const [],
        businessTypeCode: 'OF',
        businessTypeDesc: 'Office',
        premiseTypeCode: 'SL',
        premiseTypeDesc: 'Shoplot',
      );
      final payload = PremiseSubmitPayloadModel.fromDomain(form).toCreateJson();
      final details = payload['premise_details'] as Map;

      expect(details['business_type'], 'OF');
      expect(details['business_type_desc'], 'Office');
      expect(details['premise_type'], 'SL');
      expect(details['premise_type_desc'], 'Shoplot');

      fields.dispose();
    });

    test('sends the full area description, not the short area/parliament code', () {
      final fields = PremiseFormFields();
      fields.companyName.text = 'ACME SDN BHD';
      fields.traderName.text = 'ACME TRADING';
      fields.area.text = 'SEGAMBUT - DESA SERI HARTAMAS';

      final form = PremiseFormMapper.fromPresentation(
        fields: fields,
        censusImages: const [],
        areaCode: 'SEGAMBUT',
      );
      final payload = PremiseSubmitPayloadModel.fromDomain(form).toCreateJson();

      final companyDetails = payload['company_details'] as Map;
      expect(companyDetails['area'], 'SEGAMBUT - DESA SERI HARTAMAS');

      fields.dispose();
    });

    test('nests visit_status inside company_details, not top-level', () {
      final fields = PremiseFormFields();
      fields.companyName.text = 'ACME SDN BHD';
      fields.traderName.text = 'ACME TRADING';

      final form = PremiseFormMapper.fromPresentation(
        fields: fields,
        censusImages: const [],
        visitStatus: '01',
        visitStatusDesc: '01 : Berjaya Lawati',
      );
      final payload = PremiseSubmitPayloadModel.fromDomain(form).toCreateJson();

      // The server rejects the request as "Visit status is required." unless
      // this is nested under company_details — a top-level key is ignored.
      expect(payload.containsKey('visit_status'), isFalse);
      final companyDetails = payload['company_details'] as Map;
      expect(companyDetails['visit_status'], '01');

      fields.dispose();
    });
  });

  group('PremiseCensusImageMapper', () {
    test('maps local capture to app image item', () {
      final image = PremiseCensusImageMapper.fromLocalCapture(localPath: '/tmp/test.jpg');
      final item = PremiseCensusImageMapper.toAppImageItem(image);

      expect(item.localPath, '/tmp/test.jpg');
    });
  });
}
