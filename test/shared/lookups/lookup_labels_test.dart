import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';

void main() {
  group('lookup labels', () {
    test('generalLookupLabel shows desc only, never the code prefix', () {
      const item = GeneralModel(code: 'O', desc: 'OTHER', apiDisplay: 'O : OTHER');
      expect(generalLookupLabel(item), 'OTHER');
    });

    test('generalLookupLabel strips the code half of a display-only option', () {
      const item = GeneralModel(code: 'O', apiDisplay: 'O : OTHER');
      expect(generalLookupLabel(item), 'OTHER');
    });

    test('generalLookupLabel shows desc for display', () {
      const item = GeneralModel(code: 'WP', desc: 'Wilayah Persekutuan Kuala Lumpur');
      expect(generalLookupLabel(item), 'Wilayah Persekutuan Kuala Lumpur');
    });

    test('generalLookupLabel falls back to code when desc is missing', () {
      const item = GeneralModel(code: 'WP');
      expect(generalLookupLabel(item), 'WP');
    });

    test('generalLookupDisplay returns null for null option', () {
      expect(generalLookupDisplay(null), isNull);
    });

    test('generalPostcodeLabel formats postcode and city', () {
      const item = GeneralModel(code: '50000', desc: 'Kuala Lumpur');
      expect(generalPostcodeLabel(item), '50000 - Kuala Lumpur');
    });

    test('generalPostcodeLabel shows single value when code and desc match', () {
      const item = GeneralModel(code: '51000', desc: '51000');
      expect(generalPostcodeLabel(item), '51000');
    });

    test('generalPostcodeLabel prefers api display when provided', () {
      const item = GeneralModel(code: '51000', desc: '51000', apiDisplay: '51000 - Petaling Jaya');
      expect(generalPostcodeLabel(item), '51000 - Petaling Jaya');
    });

    test('lookupCodeFromDisplay parses both label styles', () {
      expect(lookupCodeFromDisplay('WP : Wilayah Persekutuan Kuala Lumpur'), 'WP');
      expect(lookupCodeFromDisplay('50000 - Kuala Lumpur'), '50000');
    });
  });
}
