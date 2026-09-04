import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/network/form_data_builder.dart';
import 'package:ilms/features/premise/data/models/premise_duplicate_models.dart';

void main() {
  group('FormDataBuilder.flatFields', () {
    test('builds flat multipart fields synchronously', () {
      final formData = FormDataBuilder.flatFields({'parliament': 'BUKIT BINTANG', 'area': ''});

      expect(formData.fields.length, 2);
      expect(formData.fields[0].key, 'parliament');
      expect(formData.fields[0].value, 'BUKIT BINTANG');
      expect(formData.fields[1].key, 'area');
      expect(formData.fields[1].value, '');
      expect(formData.files, isEmpty);
    });
  });

  group('FormDataBuilder.fromMap', () {
    test('flattens a list of maps under bracket-index keys', () async {
      final formData = await const FormDataBuilder().fromMap({
        'remarks': [
          {'code': 'R1', 'remark': 'first'},
          {'code': 'R2', 'remark': 'second'},
        ],
      });

      final fields = {for (final f in formData.fields) f.key: f.value};
      expect(fields['remarks[0][code]'], 'R1');
      expect(fields['remarks[0][remark]'], 'first');
      expect(fields['remarks[1][code]'], 'R2');
      expect(fields['remarks[1][remark]'], 'second');
    });

    test('flattens a list nested inside a list of maps (license business activities)', () async {
      // Mirrors PremiseLicenseRequest.toJson()'s license_information[].additional_license_info
      // shape — a list embedded inside each entry of an outer list of maps.
      final formData = await const FormDataBuilder().fromMap({
        'license_information': [
          {
            'license_file_no': 'DBKL.JPPP/12345/01/2026/0001',
            'status': 'V',
            'additional_license_info': [
              {'business_type': 'F&B', 'amount': '100.00'},
              {'business_type': 'RETAIL', 'amount': '50.00'},
            ],
          },
        ],
      });

      final fields = {for (final f in formData.fields) f.key: f.value};
      expect(fields['license_information[0][license_file_no]'], 'DBKL.JPPP/12345/01/2026/0001');
      expect(fields['license_information[0][status]'], 'V');
      expect(fields['license_information[0][additional_license_info][0][business_type]'], 'F&B');
      expect(fields['license_information[0][additional_license_info][0][amount]'], '100.00');
      expect(fields['license_information[0][additional_license_info][1][business_type]'], 'RETAIL');
      expect(fields['license_information[0][additional_license_info][1][amount]'], '50.00');
      // Regression: the nested list must never be stringified as a raw Dart
      // literal (e.g. "[{business_type: F&B, ...}]") under the parent key.
      expect(fields.containsKey('license_information[0][additional_license_info]'), isFalse);
    });

    test('sends key[] with an empty value for an empty list instead of dropping the key', () async {
      // Regression: without this, deleting every license/business-activity
      // row left `license_information`/`business_activities` absent from the
      // request entirely, so the backend kept the old rows instead of
      // clearing them. A plain string value (e.g. "[]") doesn't work either —
      // PHP still parses it as a scalar and the backend's `foreach` over it
      // throws a 500 ("foreach() argument must be of type array|object,
      // string given"). `key[]` with an empty value is the classic
      // HTML-forms idiom: PHP parses it as a real array so `foreach` doesn't
      // choke, and the backend filters out the blank placeholder row.
      final formData = await const FormDataBuilder().fromMap({'license_information': [], 'business_activities': []});

      final fields = {for (final f in formData.fields) f.key: f.value};
      expect(fields['license_information[]'], '');
      expect(fields['business_activities[]'], '');
      expect(fields.containsKey('license_information'), isFalse);
      expect(fields.containsKey('business_activities'), isFalse);
    });

    test('flattens nested maps under bracket keys', () async {
      final formData = await const FormDataBuilder().fromMap({
        'company_details': {'company_name': 'ACME', 'contact': {'phone': '0123456789'}},
      });

      final fields = {for (final f in formData.fields) f.key: f.value};
      expect(fields['company_details[company_name]'], 'ACME');
      expect(fields['company_details[contact][phone]'], '0123456789');
    });
  });

  group('PremiseDuplicateFilterDto', () {
    test('toJson matches legacy PremisSearchFilter field names and order', () {
      const dto = PremiseDuplicateFilterDto(parliament: 'P118', companyName: 'ACME');

      expect(dto.toJson().keys.toList(), [
        'keyword',
        'license_file_no',
        'license_no',
        'unit',
        'floor',
        'block',
        'building',
        'street',
        'area',
        'parliament',
        'company_name',
        'trader_name',
        'phase',
      ]);
      expect(dto.toJson()['parliament'], 'P118');
      expect(dto.toJson()['company_name'], 'ACME');
      expect(dto.toJson()['keyword'], '');
      expect(dto.toJson()['phase'], '');
    });
  });
}
