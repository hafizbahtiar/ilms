import 'package:ilms/features/premise/domain/entities/premise_address_listing.dart';
import 'package:ilms/shared/models/general_response_model.dart';

class PremiseAddressListingPageModel {
  const PremiseAddressListingPageModel({required this.items, required this.hasNextPage, required this.nextPage});

  final List<PremiseAddressListing> items;
  final bool hasNextPage;
  final int nextPage;
}

class PremiseAddressListingResponseModel {
  PremiseAddressListingResponseModel({this.data, this.pagination});

  final List<PremiseAddressListingModel>? data;
  final Pagination? pagination;

  factory PremiseAddressListingResponseModel.fromJson(Map<String, dynamic> json) {
    return PremiseAddressListingResponseModel(
      data: json['data'] is List
          ? (json['data'] as List)
                .whereType<Map>()
                .map((item) => PremiseAddressListingModel.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
      pagination: json['pagination'] is Map ? Pagination.fromJson(Map<String, dynamic>.from(json['pagination'])) : null,
    );
  }
}

class PremiseAddressListingModel {
  PremiseAddressListingModel({
    required this.id,
    this.unitNo,
    this.streetName,
    this.building,
    this.area,
    this.parliament,
    this.postcode,
    this.state,
    this.latitude,
    this.longitude,
  });

  final int? id;
  final String? unitNo;
  final String? streetName;
  final String? building;
  final String? area;
  final String? parliament;
  final String? postcode;
  final String? state;
  final String? latitude;
  final String? longitude;

  factory PremiseAddressListingModel.fromJson(Map<String, dynamic> json) {
    return PremiseAddressListingModel(
      id: json['paid'] is int ? json['paid'] as int : int.tryParse('${json['paid']}'),
      unitNo: json['unit_no']?.toString(),
      streetName: json['street_name']?.toString(),
      building: json['building']?.toString(),
      area: json['area']?.toString(),
      parliament: json['parliament']?.toString(),
      postcode: json['postcode']?.toString(),
      state: json['state']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  PremiseAddressListing toDomain() {
    return PremiseAddressListing(
      id: id ?? -1,
      unitNo: unitNo,
      streetName: streetName,
      building: building,
      area: area,
      parliament: parliament,
      postcode: postcode,
      state: state,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
