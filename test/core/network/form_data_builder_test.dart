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
