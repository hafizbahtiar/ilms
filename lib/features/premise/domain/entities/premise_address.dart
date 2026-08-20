import 'package:equatable/equatable.dart';

class PremiseAddress extends Equatable {
  const PremiseAddress({
    this.localId,
    this.premiseAddressId,
    this.visitPremiseAddressId,
    this.unitNo,
    this.floor,
    this.blockNo,
    this.building,
    this.streetName,
    this.area,
    this.parliament,
    this.postcode,
    this.state,
    this.latitude,
    this.longitude,
  });

  final int? localId;
  final int? premiseAddressId;
  final int? visitPremiseAddressId;
  final String? unitNo;
  final String? floor;
  final String? blockNo;
  final String? building;
  final String? streetName;
  final String? area;
  final String? parliament;
  final String? postcode;
  final String? state;
  final String? latitude;
  final String? longitude;

  @override
  List<Object?> get props => [
        localId,
        premiseAddressId,
        visitPremiseAddressId,
        unitNo,
        floor,
        blockNo,
        building,
        streetName,
        area,
        parliament,
        postcode,
        state,
        latitude,
        longitude,
      ];
}
