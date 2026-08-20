import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';

void main() {
  group('lookup labels', () {
    test('generalLookupLabel formats code and description', () {
      const item = GeneralModel(code: 'WP', desc: 'Wilayah Persekutuan Kuala Lumpur');
      expect(generalLookupLabel(item), 'WP : Wilayah Persekutuan Kuala Lumpur');
    });

    test('generalPostcodeLabel formats postcode and city', () {
      const item = GeneralModel(code: '50000', desc: 'Kuala Lumpur');
      expect(generalPostcodeLabel(item), '50000 - Kuala Lumpur');
    });

    test('lookupCodeFromDisplay parses both label styles', () {
      expect(lookupCodeFromDisplay('WP : Wilayah Persekutuan Kuala Lumpur'), 'WP');
      expect(lookupCodeFromDisplay('50000 - Kuala Lumpur'), '50000');
    });
  });
}
