import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/premise/data/mappers/premise_draft_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';

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
  });
}
