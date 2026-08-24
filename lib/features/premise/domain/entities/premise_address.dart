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

  PremiseAddress copyWith({
    int? localId,
    int? premiseAddressId,
    int? visitPremiseAddressId,
    String? unitNo,
    String? floor,
    String? blockNo,
    String? building,
    String? streetName,
    String? area,
    String? parliament,
    String? postcode,
    String? state,
    String? latitude,
    String? longitude,
  }) {
    return PremiseAddress(
      localId: localId ?? this.localId,
      premiseAddressId: premiseAddressId ?? this.premiseAddressId,
      visitPremiseAddressId: visitPremiseAddressId ?? this.visitPremiseAddressId,
      unitNo: unitNo ?? this.unitNo,
      floor: floor ?? this.floor,
      blockNo: blockNo ?? this.blockNo,
      building: building ?? this.building,
      streetName: streetName ?? this.streetName,
      area: area ?? this.area,
      parliament: parliament ?? this.parliament,
      postcode: postcode ?? this.postcode,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

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
