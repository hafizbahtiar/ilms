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
