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
          {'id': 7, 'type': 'FRONT', 'image_url': 'https://example.com/front.jpg'},
        ],
      });

      expect(payload.fields['companyName'], 'ACME Sdn Bhd');
      expect(payload.censusImages, isEmpty);
      expect(payload.remarks, isEmpty);
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
        'contact_person': {'name': 'Ali', 'phone': '012-3456789', 'email': 'ali@example.com', 'position': 'Manager'},
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
          {'id': 7, 'type': 'FRONT', 'type_desc': 'Front View', 'image_url': 'https://example.com/front.jpg'},
        ],
        'remarks': [
          {
            'id': 1,
            'code': 'R01',
            'remark': 'Premis bersih',
            'remark_type': 'O',
            'remark_desc': 'O : Premis bersih',
            'description': null,
          },
        ],
        'license_information': [
          {
            'id': 5,
            'license_no': 'LN-001',
            'file_no': 'DBKL.JPPP/12345',
            'license_from': '01/01/2026',
            'license_to': '31/12/2026',
            'status': 'V',
            'status_desc': 'Valid',
            'additional_license_info': [
              {
                'business_type': 'A402',
                'business_type_desc': 'Retail',
                'status': 'A',
                'status_desc': 'Active',
                'description': 'Retail activity',
                'amount': '100.00',
              },
            ],
          },
        ],
        'business_activities': [
          {
            'id': 9,
            'business_type': 'A402',
            'business_type_desc': 'Retail',
            'status': 'A',
            'status_desc': 'Active',
            'description': 'Standalone activity',
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

      expect(payload.remarks, hasLength(1));
      expect(payload.remarks.first.code, 'R01');
      expect(payload.remarks.first.remarkDesc, 'O : Premis bersih');

      expect(payload.licenses, hasLength(1));
      expect(payload.licenses.first.licenseNo, 'LN-001');
      expect(payload.licenses.first.businessActivities, hasLength(1));
      expect(payload.licenses.first.businessActivities.first.amount, '100.00');

      expect(payload.businessActivities, hasLength(1));
      expect(payload.businessActivities.first.businessType, 'A402');
    });
  });
}
