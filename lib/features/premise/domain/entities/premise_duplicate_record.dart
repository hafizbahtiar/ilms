/// A previous-phase premise row returned from duplicate search.
class PremiseDuplicateRecord {
  const PremiseDuplicateRecord({
    required this.visitNo,
    this.companyName,
    this.traderName,
    this.address,
    this.visitStatus,
    this.phase,
    this.visitDate,
    this.createdBy,
    this.parliament,
    this.area,
    this.street,
    this.building,
    this.unit,
  });

  final String visitNo;
  final String? companyName;
  final String? traderName;
  final String? address;
  final String? visitStatus;
  final String? phase;
  final String? visitDate;
  final String? createdBy;
  final String? parliament;
  final String? area;
  final String? street;
  final String? building;
  final String? unit;

  String get displayHeader {
    final company = companyName?.trim();
    if (company != null && company.isNotEmpty) return company;
    return traderName?.trim().isNotEmpty == true ? traderName!.trim() : visitNo;
  }

  String get displayTitle => traderName?.trim().isNotEmpty == true ? traderName!.trim() : visitNo;
}
