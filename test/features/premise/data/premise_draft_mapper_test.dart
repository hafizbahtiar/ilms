import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/premise/data/mappers/premise_draft_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_gps.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';

void main() {
  group('PremiseDraftMapper', () {
    test('isEmptyPayload detects blank drafts', () {
      expect(PremiseDraftMapper.isEmptyPayload(PremiseDraftMapper.emptyPayload()), isTrue);
      expect(
        PremiseDraftMapper.isEmptyPayload(
          const PremiseDraftPayloadModel(fields: {'companyName': 'Acme'}),
        ),
        isFalse,
      );
      expect(
        PremiseDraftMapper.isEmptyPayload(
          const PremiseDraftPayloadModel(businessTypeCode: 'OF', premiseTypeCode: 'SL'),
        ),
        isFalse,
      );
    });

    test('encode/decode preserves business and premise type codes', () {
      const original = PremiseDraftPayloadModel(
        businessTypeCode: 'OF',
        businessTypeDesc: 'Office',
        premiseTypeCode: 'SL',
        premiseTypeDesc: 'Shoplot',
        fields: {'businessType': 'Office', 'premiseType': 'Shoplot'},
      );

      final roundTripped = PremiseDraftMapper.decodePayload(PremiseDraftMapper.encodePayload(original));

      expect(roundTripped.businessTypeCode, 'OF');
      expect(roundTripped.businessTypeDesc, 'Office');
      expect(roundTripped.premiseTypeCode, 'SL');
      expect(roundTripped.premiseTypeDesc, 'Shoplot');
    });

    test('encode/decode preserves the top-level GPS coordinate', () {
      const original = PremiseDraftPayloadModel(gps: PremiseGps(latitude: '3.139012', longitude: '101.686901'));

      final roundTripped = PremiseDraftMapper.decodePayload(PremiseDraftMapper.encodePayload(original));

      expect(roundTripped.gps.latitude, '3.139012');
      expect(roundTripped.gps.longitude, '101.686901');
    });

    test('payloadsEqual compares encoded snapshots', () {
      const a = PremiseDraftPayloadModel(fields: {'companyName': 'Acme'});
      const b = PremiseDraftPayloadModel(fields: {'companyName': 'Acme'});
      const c = PremiseDraftPayloadModel(
        fields: {'companyName': 'Acme'},
        censusImages: [PremiseCensusImage(localPath: '/tmp/a.jpg')],
      );

      expect(PremiseDraftMapper.payloadsEqual(a, b), isTrue);
      expect(PremiseDraftMapper.payloadsEqual(a, c), isFalse);
    });

    test('toPayload carries the GPS coordinate from form state, so picking a location marks the form dirty', () {
      final fields = PremiseFormFields();
      addTearDown(fields.dispose);

      final withoutGps = PremiseDraftMapper.toPayload(
        fields: fields,
        state: const PremiseFormState(mode: PremiseFormMode.create),
      );
      final withGps = PremiseDraftMapper.toPayload(
        fields: fields,
        state: const PremiseFormState(
          mode: PremiseFormMode.create,
          gps: PremiseGps(latitude: '3.139012', longitude: '101.686901'),
        ),
      );

      expect(withoutGps.gps.hasCoordinate, isFalse);
      expect(withGps.gps.latitude, '3.139012');
      expect(withGps.gps.longitude, '101.686901');
      // Regression: toPayload used to drop `state.gps` entirely, so
      // hasUnsavedChanges (which diffs toPayload snapshots) never noticed a
      // freshly picked location — the edit form's back button skipped the
      // "Discard unsaved changes?" prompt after picking a GPS location.
      expect(PremiseDraftMapper.payloadsEqual(withoutGps, withGps), isFalse);
    });

    test('applyPayload restores the GPS coordinate into form state', () {
      final fields = PremiseFormFields();
      addTearDown(fields.dispose);
      const payload = PremiseDraftPayloadModel(gps: PremiseGps(latitude: '3.139012', longitude: '101.686901'));

      PremiseFormState? applied;
      PremiseDraftMapper.applyPayload(
        fields: fields,
        payload: payload,
        currentState: const PremiseFormState(mode: PremiseFormMode.create),
        updateState: (state) => applied = state,
      );

      expect(applied!.gps.latitude, '3.139012');
      expect(applied!.gps.longitude, '101.686901');
    });
  });
}
