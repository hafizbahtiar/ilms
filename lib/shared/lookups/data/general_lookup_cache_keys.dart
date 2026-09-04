import 'dart:convert';

import 'package:ilms/shared/models/general_model.dart';

abstract final class GeneralLookupCacheKeys {
  static const prefix = 'lookup:';

  static String states() => '${prefix}states';

  static String postcodes(String? stateCode) => '${prefix}postcodes:${stateCode ?? 'all'}';

  static String areas(String? stateCode, String? postcode) =>
      '${prefix}areas:${stateCode ?? 'all'}:${postcode ?? 'all'}';

  static String parliaments(String? stateCode) => '${prefix}parliaments:${stateCode ?? 'all'}';

  // The `search*` lookups below (areasByParliament/streets/buildings/units)
  // hit paginated endpoints. Before ApiGeneralLookupDataSource._search()
  // looped every page, a cached entry could hold only page 1's results — the
  // ":v2" suffix keys those entries separately so a device holding a
  // pre-fix (incomplete) cache misses and refetches the complete list,
  // instead of silently reusing a truncated one indefinitely (there's no
  // cache expiry otherwise). Don't remove the suffix without a similar bump.
  static String areasByParliament(String parliamentCode) => '${prefix}areasByParliament:v2:$parliamentCode';

  static String streets(String areaCode) => '${prefix}streets:v2:$areaCode';

  static String buildings(String streetCode) => '${prefix}buildings:v2:$streetCode';

  static String units({String? buildingCode, String? streetCode}) =>
      '${prefix}units:v2:${buildingCode ?? ''}:${streetCode ?? ''}';

  static String businessTypes() => '${prefix}businessTypes';

  static String premiseTypes() => '${prefix}premiseTypes';

  static String visitBusinessTypes() => '${prefix}visitBusinessTypes';

  static String visitStatuses() => '${prefix}visitStatuses';

  static String imageTypes() => '${prefix}imageTypes';

  static String remarks() => '${prefix}remarks';

  static String businessActivityStatuses() => '${prefix}businessActivityStatuses';

  static String businessLicenseStatuses() => '${prefix}businessLicenseStatuses';

  static String phases() => '${prefix}phases';

  static String phasesByBillboard() => '${prefix}phasesByBillboard';

  static String billboardTypes() => '${prefix}billboardTypes';

  static String assetOwnerTypes() => '${prefix}assetOwnerTypes';

  static String yesNo() => '${prefix}yesNo';
}

class GeneralLookupCacheCodec {
  GeneralLookupCacheCodec._();

  static String encode(List<GeneralModel> items) {
    return jsonEncode(items.map((item) => item.toJson()).toList(growable: false));
  }

  static List<GeneralModel> decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return [
      for (final item in decoded)
        if (item is Map<String, dynamic>)
          GeneralModel.fromJson(item)
        else if (item is Map)
          GeneralModel.fromJson(Map<String, dynamic>.from(item)),
    ];
  }
}
