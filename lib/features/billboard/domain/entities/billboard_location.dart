import 'package:equatable/equatable.dart';

/// Site/address details for a billboard (legacy `LocationDetails`).
///
/// `mediaClientName`/`mediaClientTel` identify the advertiser/client at this
/// location — distinct from [BillboardMediaOwner] (the media company) and
/// [BillboardAssetOwner] (owner of the physical structure). Keep all three
/// separate; do not conflate them.
class BillboardLocation extends Equatable {
  const BillboardLocation({
    this.mediaClientName,
    this.mediaClientTel,
    this.unit,
    this.address,
    this.postal,
    this.building,
    this.parliamentCode,
    this.parliamentDesc,
    this.areaCode,
    this.areaDesc,
  });

  final String? mediaClientName;
  final String? mediaClientTel;
  final String? unit;
  final String? address;
  final String? postal;
  final String? building;
  final String? parliamentCode;
  final String? parliamentDesc;
  final String? areaCode;
  final String? areaDesc;

  BillboardLocation copyWith({
    String? mediaClientName,
    String? mediaClientTel,
    String? unit,
    String? address,
    String? postal,
    String? building,
    String? parliamentCode,
    String? parliamentDesc,
    String? areaCode,
    String? areaDesc,
    bool clearArea = false,
  }) {
    return BillboardLocation(
      mediaClientName: mediaClientName ?? this.mediaClientName,
      mediaClientTel: mediaClientTel ?? this.mediaClientTel,
      unit: unit ?? this.unit,
      address: address ?? this.address,
      postal: postal ?? this.postal,
      building: building ?? this.building,
      parliamentCode: parliamentCode ?? this.parliamentCode,
      parliamentDesc: parliamentDesc ?? this.parliamentDesc,
      areaCode: clearArea ? null : (areaCode ?? this.areaCode),
      areaDesc: clearArea ? null : (areaDesc ?? this.areaDesc),
    );
  }

  @override
  List<Object?> get props => [
    mediaClientName,
    mediaClientTel,
    unit,
    address,
    postal,
    building,
    parliamentCode,
    parliamentDesc,
    areaCode,
    areaDesc,
  ];
}
