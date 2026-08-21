/// One row from `POST /api/premiseCensus/search`.
class PremiseSearchRecord {
  const PremiseSearchRecord({
    required this.visitNo,
    this.companyName,
    this.traderName,
    this.address,
    this.visitStatus,
    this.phase,
    this.visitDate,
    this.createdBy,
  });

  final String visitNo;
  final String? companyName;
  final String? traderName;
  final String? address;
  final String? visitStatus;
  final String? phase;
  final String? visitDate;
  final String? createdBy;

  String get displayHeader {
    final company = companyName?.trim();
    if (company != null && company.isNotEmpty) return company;
    return traderName?.trim().isNotEmpty == true ? traderName!.trim() : visitNo;
  }

  String get displayTitle => traderName?.trim().isNotEmpty == true ? traderName!.trim() : visitNo;
}
