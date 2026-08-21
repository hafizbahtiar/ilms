/// Body filter for `POST /api/premiseCensus/search`.
///
/// Address fields use lookup **descriptions** (legacy `PremisSearchFilter`);
/// [phase] uses the lookup **code**.
class PremiseSearchFilter {
  const PremiseSearchFilter({
    this.keyword = '',
    this.licenseFileNo = '',
    this.licenseNo = '',
    this.unit = '',
    this.building = '',
    this.street = '',
    this.area = '',
    this.parliament = '',
    this.companyName = '',
    this.traderName = '',
    this.phase = '',
  });

  final String keyword;
  final String licenseFileNo;
  final String licenseNo;
  final String unit;
  final String building;
  final String street;
  final String area;
  final String parliament;
  final String companyName;
  final String traderName;
  final String phase;

  Map<String, dynamic> toJson() => {
    'keyword': keyword,
    'license_file_no': licenseFileNo,
    'license_no': licenseNo,
    'unit': unit,
    'building': building,
    'street': street,
    'area': area,
    'parliament': parliament,
    'company_name': companyName,
    'trader_name': traderName,
    'phase': phase,
  };
}
