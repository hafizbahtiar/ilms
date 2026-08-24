import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/investigation/data/mappers/investigation_detail_mapper.dart';

void main() {
  group('InvestigationDetailMapper', () {
    test('fromApiDetail maps a full API detail payload', () {
      final details = InvestigationDetailMapper.fromApiDetail({
        'investigation_no': 'INV10000001',
        'investigation_id': 42,
        'investigation_status': 'OPEN',
        'applicant_information': {
          'license_file_no': 'LF-0001',
          'applicant_name': 'Ahmad bin Ismail',
          'identification_no': '900101-01-1234',
          'company_name': 'Warung Ahmad Sdn Bhd',
          'registration_no': 'ROC-1',
          'business_types': [
            {'code': 'A01', 'description': 'Restoran'},
          ],
          'advertisement_types': [
            {'code': 'AD01', 'description': 'Signboard'},
          ],
        },
        'location': {'parliament': 'P001', 'area': 'A001'},
        'investigation_details': {
          'premise_position': 'Corner lot',
          'premise_left': 'Shop A',
          'premise_right': 'Shop B',
          'premise_above': '',
          'premise_below': '',
          'building_type': 'Shoplot',
          'level': '1',
          'building_status': 'Active',
          'premise_modification': 'Y',
          'premise_length': '10',
          'premise_width': '5',
          'similar_premises_count': '2',
        },
        'business_activities': {
          'floor_length': '8',
          'floor_width': '4',
          'opening_time': '09:00',
          'closing_time': '22:00',
        },
        'pollution_disturbance': {
          'placing_furniture': 'Y',
          'chair_count': '4',
          'table_count': '2',
          'stall_count': '0',
          'machine_count': '1',
          'hair_salon_chair_count': '0',
          'room_count': '0',
          'student_count': '0',
          'petrol_liters': '0',
          'diesel_liters': '0',
          'gas_liters': '0',
          'other_activities': 'None',
        },
        'advertisement': {
          'advertisement_displayed': 'Y',
          'advertisement_location': 'Front facade',
          'advertisement_compliant': 'N',
          'advertisement_non_compliant_reason': 'Too large',
          'malay_language': 'Y',
          'advertisement_size': 'N',
          'advertisement_spelling': 'Y',
        },
        'images': [
          {
            'image_id': 1,
            'sequence': 1,
            'uploaded_by': 'officer1',
            'uploaded_at': '2026-01-01T10:00:00Z',
            'url': 'https://x/1.jpg',
          },
        ],
        'minutes': [
          {
            'minute_id': 1,
            'sequence': 1,
            'role': 'Officer',
            'officer': 'Tan',
            'date': '2026-01-01',
            'minutes': 'Initial visit',
          },
        ],
        'investigation_minutes': {
          'investigation_date': '2026-01-15',
          'investigation_time': '14:30',
          'prepared_by': 'Officer Tan',
          'minutes': 'Follow-up visit conducted.',
        },
      });

      expect(details.investigationNo, 'INV10000001');
      expect(details.investigationId, 42);
      expect(details.applicant.applicantName, 'Ahmad bin Ismail');
      expect(details.applicant.businessTypes, hasLength(1));
      expect(details.applicant.businessTypes.first.description, 'Restoran');
      expect(details.location.parliamentCode, 'P001');
      expect(details.premiseDetails.premiseModification, isTrue);
      expect(details.premiseDetails.premiseLength, '10');
      expect(details.pollutionDisturbance.placingFurniture, isTrue);
      expect(details.pollutionDisturbance.chairCount, '4');
      expect(details.advertisement.displayed, isTrue);
      expect(details.advertisement.compliant, isFalse);
      expect(details.advertisement.nonCompliantReason, 'Too large');
      expect(details.photos, hasLength(1));
      expect(details.photos.first.url, 'https://x/1.jpg');
      expect(details.minutes, hasLength(1));
      expect(details.minutes.first.officer, 'Tan');
      expect(details.minutesEntry.investigationDate, DateTime.parse('2026-01-15'));
      expect(details.minutesEntry.investigationTime, '14:30');
      expect(details.minutesEntry.minutes, 'Follow-up visit conducted.');
    });

    test('fromApiDetail defensively handles an empty-string date without throwing', () {
      final details = InvestigationDetailMapper.fromApiDetail({
        'investigation_no': 'INV10000002',
        'applicant_information': {},
        'location': {},
        'investigation_details': {},
        'business_activities': {},
        'pollution_disturbance': {},
        'advertisement': {},
        'images': [],
        'minutes': [],
        'investigation_minutes': {'investigation_date': ''},
      });

      expect(details.minutesEntry.investigationDate, isNull);
      expect(details.premiseDetails.similarPremisesCount, '0');
    });

    test('fromApiDetail accepts legacy id/seq/type image key aliases', () {
      final details = InvestigationDetailMapper.fromApiDetail({
        'investigation_no': 'INV10000003',
        'applicant_information': {},
        'location': {},
        'investigation_details': {},
        'business_activities': {},
        'pollution_disturbance': {},
        'advertisement': {},
        'images': [
          {'id': 5, 'seq': 2, 'thumbnail_url': 'https://x/thumb.jpg'},
        ],
        'minutes': [],
        'investigation_minutes': {},
      });

      expect(details.photos.single.imageId, 5);
      expect(details.photos.single.sequence, 2);
      expect(details.photos.single.url, 'https://x/thumb.jpg');
    });
  });
}
