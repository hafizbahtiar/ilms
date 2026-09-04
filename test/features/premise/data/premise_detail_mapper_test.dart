import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/premise/data/mappers/premise_detail_mapper.dart';
import 'package:ilms/features/premise/domain/entities/premise_image_upload_status.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';

void main() {
  group('PremiseDetailMapper', () {
    test('fromApiDetailForDuplicate omits census images and clears visit-only fields', () {
      final payload = PremiseDetailMapper.fromApiDetailForDuplicate({
        'company_details': {
          'company_name': 'ACME Sdn Bhd',
          'sticker_no': 'ST-001',
          'census_date': '2024-01-01',
        },
        'premise_details': {'trader_name': 'ACME Trading'},
        'remarks': [
          {'id': 1, 'remark': 'Old remark', 'code': 'R01'},
        ],
        'business_activities': [
          {'id': 9, 'business_type': 'A402', 'description': 'Retail'},
        ],
        'premise_addresses': [
          {'paid': 42, 'vpa_id': 99, 'unit_no': 'G-1', 'building': 'Plaza BB', 'street_name': 'Jalan BB'},
        ],
        'gps_details': {'latitude': '3.139012', 'longitude': '101.686901'},
        'images': [
          {'id': 7, 'type': 'FRONT', 'image_url': 'https://example.com/front.jpg'},
        ],
      });

      expect(payload.fields['companyName'], 'ACME Sdn Bhd');
      expect(payload.fields['stickerNo'], isEmpty);
      expect(payload.fields['censusDate'], formatDdMmYyyy(DateTime.now()));
      expect(payload.censusImages, isEmpty);
      expect(payload.licenses, isEmpty);

      expect(payload.remarks, hasLength(1));
      expect(payload.remarks.first.id, isNull);
      expect(payload.remarks.first.remark, 'Old remark');

      expect(payload.businessActivities, hasLength(1));
      expect(payload.businessActivities.first.id, 9);
      expect(payload.businessActivities.first.businessType, 'A402');

      expect(payload.addresses, hasLength(1));
      expect(payload.addresses.first.premiseAddressId, 42);
      expect(payload.addresses.first.visitPremiseAddressId, isNull);
      expect(payload.addresses.first.unitNo, 'G-1');

      // GPS travels at the top level now (see PremiseGps), carried forward
      // as-is into the duplicate since it's the same physical location.
      expect(payload.gps.latitude, '3.139012');
      expect(payload.gps.longitude, '101.686901');
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
        'premise_addresses': [
          {'paid': 10, 'vpa_id': 20, 'unit_no': '1-1', 'street_name': 'Main St'},
        ],
        'gps_details': {'latitude': '3.139012', 'longitude': '101.686901'},
      });

      expect(payload.companyStateCode, '14');
      expect(payload.companyPostcode, '50000');
      expect(payload.fields['companyName'], 'ACME Sdn Bhd');
      expect(payload.fields['traderName'], 'ACME Trading');
      // Prefill text matches what the picker shows — desc only; the codes
      // travel separately below.
      expect(payload.fields['businessType'], 'Retail');
      expect(payload.fields['premiseType'], 'Shoplot');
      expect(payload.businessTypeCode, 'A402');
      expect(payload.businessTypeDesc, 'Retail');
      expect(payload.premiseTypeCode, '01');
      expect(payload.premiseTypeDesc, 'Shoplot');
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

      expect(payload.addresses, hasLength(1));
      expect(payload.addresses.first.premiseAddressId, 10);
      expect(payload.addresses.first.visitPremiseAddressId, 20);

      expect(payload.gps.latitude, '3.139012');
      expect(payload.gps.longitude, '101.686901');
    });

    test('fromApiDetail defaults gps to empty when gps_details is missing', () {
      final payload = PremiseDetailMapper.fromApiDetail({
        'company_details': {'company_name': 'ACME Sdn Bhd'},
        'premise_details': {'trader_name': 'ACME Trading'},
      });

      expect(payload.gps.hasCoordinate, isFalse);
    });
  });
}
