import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/investigation/data/models/investigation_submit_payload_model.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_advertisement.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_applicant_info.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_business_activity.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_location.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minutes_entry.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_pollution_disturbance.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_premise_details.dart';

InvestigationDetails _details({
  required bool placingFurniture,
  required bool advertisementDisplayed,
  required bool advertisementCompliant,
}) {
  return InvestigationDetails(
    investigationNo: 'INV10000001',
    applicant: const InvestigationApplicantInfo(),
    location: const InvestigationLocation(parliamentCode: 'P001', areaCode: 'A001'),
    premiseDetails: const InvestigationPremiseDetails(premiseModification: true, premiseLength: '10'),
    businessActivity: const InvestigationBusinessActivity(),
    pollutionDisturbance: InvestigationPollutionDisturbance(
      placingFurniture: placingFurniture,
      chairCount: '4',
      tableCount: '2',
      stallCount: '1',
      machineCount: '3',
    ),
    advertisement: InvestigationAdvertisement(
      displayed: advertisementDisplayed,
      location: 'Front facade',
      compliant: advertisementCompliant,
      nonCompliantReason: 'Too large',
    ),
    minutesEntry: InvestigationMinutesEntry(
      investigationDate: DateTime(2026, 1, 15),
      investigationTime: '14:30',
      minutes: 'Follow-up visit',
    ),
  );
}

void main() {
  group('InvestigationSubmitPayloadModel', () {
    test('sends Y and the entered counts when placingFurniture is on', () {
      final json = InvestigationSubmitPayloadModel.fromDomain(
        _details(placingFurniture: true, advertisementDisplayed: true, advertisementCompliant: false),
      ).toUpdateJson();

      final pollution = json['pollution_disturbance'] as Map<String, dynamic>;
      expect(pollution['placing_furniture'], 'Y');
      expect(pollution['chair_count'], '4');
      expect(pollution['table_count'], '2');
      expect(pollution['stall_count'], '1');
      // Independent counters are always sent regardless of the toggle.
      expect(pollution['machine_count'], '3');
    });

    test('clears chair/table/stall to 0 when placingFurniture is off, but keeps independent counters', () {
      final json = InvestigationSubmitPayloadModel.fromDomain(
        _details(placingFurniture: false, advertisementDisplayed: true, advertisementCompliant: false),
      ).toUpdateJson();

      final pollution = json['pollution_disturbance'] as Map<String, dynamic>;
      expect(pollution['placing_furniture'], 'N');
      expect(pollution['chair_count'], '0');
      expect(pollution['table_count'], '0');
      expect(pollution['stall_count'], '0');
      expect(pollution['machine_count'], '3');
    });

    test('advertisement_location is sent only when displayed, non_compliant_reason only when not compliant', () {
      final displayedAndNonCompliant =
          InvestigationSubmitPayloadModel.fromDomain(
                _details(placingFurniture: false, advertisementDisplayed: true, advertisementCompliant: false),
              ).toUpdateJson()['advertisement']
              as Map<String, dynamic>;
      expect(displayedAndNonCompliant['advertisement_displayed'], 'Y');
      expect(displayedAndNonCompliant['advertisement_location'], 'Front facade');
      expect(displayedAndNonCompliant['advertisement_compliant'], 'N');
      expect(displayedAndNonCompliant['advertisement_non_compliant_reason'], 'Too large');

      final hiddenAndCompliant =
          InvestigationSubmitPayloadModel.fromDomain(
                _details(placingFurniture: false, advertisementDisplayed: false, advertisementCompliant: true),
              ).toUpdateJson()['advertisement']
              as Map<String, dynamic>;
      expect(hiddenAndCompliant['advertisement_displayed'], 'N');
      expect(hiddenAndCompliant['advertisement_location'], '');
      expect(hiddenAndCompliant['advertisement_compliant'], 'Y');
      expect(hiddenAndCompliant['advertisement_non_compliant_reason'], '');
    });

    test('does not include applicant info, location description fields, or images', () {
      final json = InvestigationSubmitPayloadModel.fromDomain(
        _details(placingFurniture: false, advertisementDisplayed: false, advertisementCompliant: true),
      ).toUpdateJson();

      expect(json.containsKey('applicant_information'), isFalse);
      expect(json.containsKey('images'), isFalse);
      expect(json['location'], {'parliament': 'P001', 'area': 'A001'});
    });

    test('numeric fields fall back to "0" for blank or non-numeric input', () {
      final json = InvestigationSubmitPayloadModel.fromDomain(
        _details(placingFurniture: true, advertisementDisplayed: true, advertisementCompliant: false),
      ).toUpdateJson();

      final premiseDetails = json['investigation_details'] as Map<String, dynamic>;
      expect(premiseDetails['premise_length'], '10');
      expect(premiseDetails['premise_width'], '0');
    });
  });
}
