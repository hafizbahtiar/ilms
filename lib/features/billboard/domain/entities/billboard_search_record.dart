/// One row from the billboard search API (legacy `BillboardSearchData`).
class BillboardSearchRecord {
  const BillboardSearchRecord({
    required this.billboardNo,
    this.billboardDate,
    this.mediaOwnerClient,
    this.location,
    this.address,
    this.previewImage,
    this.startDate,
    this.completeDate,
  });

  final String billboardNo;
  final String? billboardDate;
  final String? mediaOwnerClient;
  final String? location;
  final String? address;
  final String? previewImage;
  final String? startDate;
  final String? completeDate;

  String get displayTitle => mediaOwnerClient?.trim().isNotEmpty == true ? mediaOwnerClient!.trim() : billboardNo;
}
