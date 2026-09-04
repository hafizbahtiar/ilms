import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/lookups/data/general_lookup_cache_keys.dart';

void main() {
  group('GeneralLookupCacheKeys', () {
    // The search* lookups (areasByParliament/streets/buildings/units) hit
    // paginated endpoints — a cache entry written before
    // ApiGeneralLookupDataSource._search() looped every page could hold only
    // page 1's results. These keys carry a version suffix so a device with a
    // pre-fix (incomplete) cached entry misses and refetches the full list,
    // rather than reusing a truncated one forever (there's no cache expiry).
    test('paginated lookups are versioned so pre-fix cache entries miss', () {
      expect(GeneralLookupCacheKeys.areasByParliament('P01'), contains(':v2:'));
      expect(GeneralLookupCacheKeys.streets('AREA01'), contains(':v2:'));
      expect(GeneralLookupCacheKeys.buildings('STREET01'), contains(':v2:'));
      expect(GeneralLookupCacheKeys.units(buildingCode: 'B1', streetCode: 'S1'), contains(':v2:'));
    });

    test('non-paginated lookups are unaffected (no version suffix)', () {
      expect(GeneralLookupCacheKeys.states(), isNot(contains(':v2:')));
      expect(GeneralLookupCacheKeys.parliaments(null), isNot(contains(':v2:')));
      expect(GeneralLookupCacheKeys.areas(null, null), isNot(contains(':v2:')));
    });
  });
}
