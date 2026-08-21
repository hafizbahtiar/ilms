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
      fields.businessType.text = 'RETAIL : Retail';
      fields.traderName.text = 'ACME TRADING';

      final form = PremiseFormMapper.fromPresentation(
        fields: fields,
        censusImages: [PremiseCensusImageMapper.fromLocalCapture(localPath: '/tmp/a.jpg')],
      );

      expect(form.companyContact.companyName, 'ACME SDN BHD');
      expect(form.companyContact.registerNumber, '123456-A');
      expect(form.details.traderName, 'ACME TRADING');
      expect(form.details.businessTypeCode, 'RETAIL');
      expect(form.details.businessTypeDescription, 'Retail');
      expect(form.censusImages, hasLength(1));

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
