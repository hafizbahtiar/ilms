/// Body filter for billboard search — mirrors legacy `BillboardSearchController`
/// filter set (9 fields).
class BillboardSearchFilter {
  const BillboardSearchFilter({
    this.billType = '',
    this.dateFrom = '',
    this.dateTo = '',
    this.ledBoard = '',
    this.mediaOwner = '',
    this.mediaOwnerClient = '',
    this.assetOwner = '',
    this.street = '',
    this.parliament = '',
    this.phase = '',
  });

  final String billType;
  final String dateFrom;
  final String dateTo;
  final String ledBoard;
  final String mediaOwner;
  final String mediaOwnerClient;
  final String assetOwner;
  final String street;
  final String parliament;
  final String phase;

  Map<String, dynamic> toJson() => {
    'bill_type': billType,
    'date_from': dateFrom,
    'date_to': dateTo,
    'led_board': ledBoard,
    'media_owner': mediaOwner,
    'media_owner_client': mediaOwnerClient,
    'asset_owner': assetOwner,
    'street': street,
    'parliament': parliament,
    'phase': phase,
  };
}
