import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/investigation/data/mappers/investigation_draft_mapper.dart';
import 'package:ilms/features/investigation/data/models/investigation_draft_payload_model.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_advertisement.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_applicant_info.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_business_activity.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_code_description.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_location.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minutes_entry.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_photo.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_pollution_disturbance.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_premise_details.dart';

void main() {
  group('InvestigationDraftMapper', () {
    test('round-trips a full InvestigationDetails through JSON, including pending photo bytes', () {
      final original = InvestigationDetails(
        investigationNo: 'INV10000001',
        investigationId: 7,
        investigationStatus: 'OPEN',
        applicant: const InvestigationApplicantInfo(
          applicantName: 'Ahmad',
          businessTypes: [InvestigationCodeDescription(code: 'A01', description: 'Restoran')],
        ),
        location: const InvestigationLocation(parliamentCode: 'P001', areaCode: 'A001'),
        premiseDetails: const InvestigationPremiseDetails(premisePosition: 'Corner', premiseModification: true),
        businessActivity: const InvestigationBusinessActivity(),
        pollutionDisturbance: const InvestigationPollutionDisturbance(placingFurniture: true, chairCount: '4'),
        advertisement: const InvestigationAdvertisement(displayed: true, location: 'Front'),
        photos: [
          InvestigationPhoto(sequence: 1, bytes: Uint8List.fromList([1, 2, 3])),
        ],
        minutes: const [],
        minutesEntry: InvestigationMinutesEntry(
          investigationDate: DateTime(2026, 1, 15),
          investigationTime: '14:30',
          minutes: 'Follow-up visit',
        ),
      );

      final payload = InvestigationDraftMapper.toPayload(original);
      final decoded = InvestigationDraftPayloadModel.decode(payload.encode());
      final restored = InvestigationDraftMapper.toDomain(decoded);

      expect(restored.investigationNo, original.investigationNo);
      expect(restored.applicant.applicantName, 'Ahmad');
      expect(restored.applicant.businessTypes.single.code, 'A01');
      expect(restored.location.parliamentCode, 'P001');
      expect(restored.premiseDetails.premiseModification, isTrue);
      expect(restored.pollutionDisturbance.placingFurniture, isTrue);
      expect(restored.pollutionDisturbance.chairCount, '4');
      expect(restored.advertisement.displayed, isTrue);
      expect(restored.photos.single.bytes, Uint8List.fromList([1, 2, 3]));
      expect(restored.minutesEntry.investigationDate, DateTime(2026, 1, 15));
      expect(restored.minutesEntry.minutes, 'Follow-up visit');
    });
  });
}
