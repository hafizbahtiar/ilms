import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/lookups/data/mock/general_lookup_catalog.dart';

void main() {
  group('GeneralLookupCatalog', () {
    test('states include all major regions', () {
      expect(GeneralLookupCatalog.states.length, greaterThanOrEqualTo(16));
      expect(GeneralLookupCatalog.states.any((s) => s.code == 'WP'), isTrue);
      expect(GeneralLookupCatalog.states.any((s) => s.code == 'SGR'), isTrue);
    });

    test('postcodes filter by state', () {
      final wp = GeneralLookupCatalog.filterPostcodes(stateCode: 'WP');
      expect(wp, isNotEmpty);
      expect(wp.every((item) => item.type == 'WP'), isTrue);

      final sgr = GeneralLookupCatalog.filterPostcodes(stateCode: 'SGR');
      expect(sgr.every((item) => item.type == 'SGR'), isTrue);
      expect(sgr.any((item) => item.code == '47500'), isTrue);
    });

    test('parliaments filter by state', () {
      final wp = GeneralLookupCatalog.filterByParent(GeneralLookupCatalog.parliaments, 'WP');
      expect(wp.any((item) => item.code == 'P118'), isTrue);

      final sgr = GeneralLookupCatalog.filterByParent(GeneralLookupCatalog.parliaments, 'SGR');
      expect(sgr.any((item) => item.code == 'P107'), isTrue);
    });

    test('areas by parliament cascade', () {
      final areas = GeneralLookupCatalog.filterByParent(GeneralLookupCatalog.areasByParliament, 'P118');
      expect(areas, isNotEmpty);
      expect(areas.every((item) => item.type == 'P118'), isTrue);
    });
  });
}
