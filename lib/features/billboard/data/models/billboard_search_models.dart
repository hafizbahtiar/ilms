import 'package:ilms/features/billboard/domain/entities/billboard_search_filter.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_search_record.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_search_result.dart';

/// Request body for `/api/billboardCensus/search`, mirroring legacy
/// `BillboardSearchInput`'s field names (a superset of the 9 filters the
/// billboard search UI exposes — the JSON keys must match the real API).
class BillboardSearchFilterDto {
  const BillboardSearchFilterDto({
    this.billboardType = '',
    this.billboardDateFrom = '',
    this.billboardDateTo = '',
    this.ledBoard = '',
    this.mediaOwner = '',
    this.mediaOwnerClient = '',
    this.assetOwner = '',
    this.street2 = '',
    this.parliament = '',
    this.phase = '',
  });

  final String billboardType;
  final String billboardDateFrom;
  final String billboardDateTo;
  final String ledBoard;
  final String mediaOwner;
  final String mediaOwnerClient;
  final String assetOwner;
  final String street2;
  final String parliament;
  final String phase;

  factory BillboardSearchFilterDto.fromDomain(BillboardSearchFilter filter) {
    return BillboardSearchFilterDto(
      billboardType: filter.billType,
      billboardDateFrom: filter.dateFrom,
      billboardDateTo: filter.dateTo,
      ledBoard: filter.ledBoard,
      mediaOwner: filter.mediaOwner,
      mediaOwnerClient: filter.mediaOwnerClient,
      assetOwner: filter.assetOwner,
      street2: filter.street,
      parliament: filter.parliament,
      phase: filter.phase,
    );
  }

  Map<String, dynamic> toJson() => {
    'billboard_type': billboardType,
    'billboard_date_from': billboardDateFrom,
    'billboard_date_to': billboardDateTo,
    'led_board': ledBoard,
    'media_owner': mediaOwner,
    'media_owner_client': mediaOwnerClient,
    'asset_owner': assetOwner,
    'street2': street2,
    'parliament': parliament,
    'phase': phase,
  };
}

class BillboardSearchRecordDto {
  const BillboardSearchRecordDto({
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

  BillboardSearchRecord toDomain() {
    return BillboardSearchRecord(
      billboardNo: billboardNo,
      billboardDate: billboardDate,
      mediaOwnerClient: mediaOwnerClient,
      location: location,
      address: address,
      previewImage: previewImage,
      startDate: startDate,
      completeDate: completeDate,
    );
  }

  factory BillboardSearchRecordDto.fromJson(Map<String, dynamic> json) {
    return BillboardSearchRecordDto(
      billboardNo: json['billboard_no']?.toString() ?? '',
      billboardDate: json['billboard_date']?.toString(),
      // Legacy field name is `moclient`, not `media_owner_client`.
      mediaOwnerClient: json['moclient']?.toString(),
      location: json['location']?.toString(),
      address: json['address']?.toString(),
      previewImage: json['preview_image']?.toString(),
      startDate: json['startdate']?.toString(),
      completeDate: json['completedate']?.toString(),
    );
  }
}

class BillboardSearchResultDto {
  const BillboardSearchResultDto({required this.items, required this.nextPage, required this.hasNextPage});

  final List<BillboardSearchRecordDto> items;
  final int nextPage;
  final bool hasNextPage;

  BillboardSearchResult toDomain() {
    return BillboardSearchResult(
      items: items.map((item) => item.toDomain()).toList(),
      nextPage: nextPage,
      hasNextPage: hasNextPage,
    );
  }
}
