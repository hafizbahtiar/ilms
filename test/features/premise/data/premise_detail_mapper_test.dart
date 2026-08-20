import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/premise/data/mappers/premise_detail_mapper.dart';
import 'package:ilms/features/premise/domain/entities/premise_image_upload_status.dart';

void main() {
  group('PremiseDetailMapper', () {
    test('fromApiDetailForDuplicate omits census images and remarks', () {
      final payload = PremiseDetailMapper.fromApiDetailForDuplicate({
        'company_details': {'company_name': 'ACME Sdn Bhd'},
        'premise_details': {'trader_name': 'ACME Trading'},
        'remarks': [
          {'id': 1, 'remark': 'Old remark'},
        ],
        'images': [
          {
            'id': 7,
            'type': 'FRONT',
            'image_url': 'https://example.com/front.jpg',
          },
        ],
      });

      expect(payload.fields['companyName'], 'ACME Sdn Bhd');
      expect(payload.censusImages, isEmpty);
    });

    test('fromApiDetail maps API detail payload into draft fields', () {
      final payload = PremiseDetailMapper.fromApiDetail({
        'company_details': {
          'company_name': 'ACME Sdn Bhd',
          'register_no': 'ROC-1',
          'tel_no': '03-111',
          'state': '14',
          'postcode': '50000',
          'unit': 'G-1',
          'building': 'Plaza BB',
          'street1': 'Jalan BB',
          'census_date': '2024-01-01',
        },
        'contact_person': {
          'name': 'Ali',
          'phone': '012-3456789',
          'email': 'ali@example.com',
          'position': 'Manager',
        },
        'premise_details': {
          'trader_name': 'ACME Trading',
          'business_type': 'A402',
          'business_type_desc': 'Retail',
          'premise_type': '01',
          'premise_type_desc': 'Shoplot',
          'width': '10',
          'length': '20',
        },
        'images': [
          {
            'id': 7,
            'type': 'FRONT',
            'type_desc': 'Front View',
            'image_url': 'https://example.com/front.jpg',
          },
        ],
      });

      expect(payload.companyStateCode, '14');
      expect(payload.companyPostcode, '50000');
      expect(payload.fields['companyName'], 'ACME Sdn Bhd');
      expect(payload.fields['traderName'], 'ACME Trading');
      expect(payload.fields['businessType'], 'A402 : Retail');
      expect(payload.fields['contactPersonName'], 'Ali');
      expect(payload.censusImages, hasLength(1));
      expect(payload.censusImages.first.networkUrl, 'https://example.com/front.jpg');
      expect(payload.censusImages.first.uploadStatus, PremiseImageUploadStatus.uploaded);
    });
  });
}
