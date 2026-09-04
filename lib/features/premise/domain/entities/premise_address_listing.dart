import 'package:equatable/equatable.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';

/// One row from `/api/listPremiseAddress` (legacy `PremisAddressResponseData`).
class PremiseAddressListing extends Equatable {
  const PremiseAddressListing({
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

  final int id;
  final String? unitNo;
  final String? streetName;
  final String? building;
  final String? area;
  final String? parliament;
  final String? postcode;
  final String? state;
  final String? latitude;
  final String? longitude;

  PremiseAddress toDomain({PremiseAddress? existing}) {
    return PremiseAddress(
      localId: existing?.localId,
      premiseAddressId: id,
      visitPremiseAddressId: existing?.visitPremiseAddressId,
      unitNo: unitNo,
      building: building,
      streetName: streetName,
      area: area,
      parliament: parliament,
      postcode: postcode,
      state: state,
    );
  }

  /// Reverse mapping is used only to seed the search sheet's "already
  /// selected" set for id-based matching — coordinates aren't needed there,
  /// [PremiseAddress] no longer carries them (see [PremiseGps]).
  factory PremiseAddressListing.fromDomain(PremiseAddress address) {
    return PremiseAddressListing(
      id: address.premiseAddressId ?? -1,
      unitNo: address.unitNo,
      streetName: address.streetName,
      building: address.building,
      area: address.area,
      parliament: address.parliament,
      postcode: address.postcode,
      state: address.state,
    );
  }

  @override
  List<Object?> get props => [id];
}
