/// API filter body for duplicate search (`searchPrevPhase`).
class PremiseDuplicateFilter {
  const PremiseDuplicateFilter({
    this.parliament = '',
    this.area = '',
    this.street = '',
    this.building = '',
    this.unit = '',
    this.companyName = '',
    this.traderName = '',
    this.licenseNo = '',
    this.licenseFileNo = '',
  });

  final String parliament;
  final String area;
  final String street;
  final String building;
  final String unit;
  final String companyName;
  final String traderName;
  final String licenseNo;
  final String licenseFileNo;

  bool get isEmpty =>
      parliament.isEmpty &&
      area.isEmpty &&
      street.isEmpty &&
      building.isEmpty &&
      unit.isEmpty &&
      companyName.isEmpty &&
      traderName.isEmpty &&
      licenseNo.isEmpty &&
      licenseFileNo.isEmpty;
}
