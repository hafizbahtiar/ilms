/// Query filter for `/api/listPremiseAddress` (legacy `PremisFilterInput`).
class PremiseAddressFilter {
  const PremiseAddressFilter({
    this.page = 1,
    this.perPage = 40,
    this.unit,
    this.parliamentCode,
    this.areaCode,
    this.streetCode,
    this.buildingCode,
  });

  final int page;
  final int perPage;
  final String? unit;
  final String? parliamentCode;
  final String? areaCode;
  final String? streetCode;
  final String? buildingCode;

  PremiseAddressFilter copyWith({
    int? page,
    int? perPage,
    String? unit,
    String? parliamentCode,
    String? areaCode,
    String? streetCode,
    String? buildingCode,
    bool clearUnit = false,
  }) {
    return PremiseAddressFilter(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      unit: clearUnit ? null : (unit ?? this.unit),
      parliamentCode: parliamentCode ?? this.parliamentCode,
      areaCode: areaCode ?? this.areaCode,
      streetCode: streetCode ?? this.streetCode,
      buildingCode: buildingCode ?? this.buildingCode,
    );
  }

  Map<String, String> toQuery() {
    return {
      'page': '$page',
      'per_page': '$perPage',
      if (unit != null && unit!.isNotEmpty) 'unit': unit!,
      if (parliamentCode != null && parliamentCode!.isNotEmpty) 'parliament': parliamentCode!,
      if (areaCode != null && areaCode!.isNotEmpty) 'area': areaCode!,
      if (streetCode != null && streetCode!.isNotEmpty) 'street': streetCode!,
      if (buildingCode != null && buildingCode!.isNotEmpty) 'building': buildingCode!,
    };
  }
}
