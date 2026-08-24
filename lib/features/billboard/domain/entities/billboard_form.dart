import 'package:equatable/equatable.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_asset_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_details.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_face.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_gps.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_license.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_location.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_media_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_photo.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_remark.dart';

/// Aggregate root for the billboard census form.
class BillboardForm extends Equatable {
  const BillboardForm({
    this.billboardNo,
    this.updatedAt,
    required this.details,
    required this.location,
    required this.gps,
    required this.mediaOwner,
    required this.assetOwner,
    required this.license,
    required this.remark,
    this.faces = const [],
    this.photos = const [],
  });

  final String? billboardNo;
  final String? updatedAt;
  final BillboardDetails details;
  final BillboardLocation location;
  final BillboardGps gps;
  final BillboardMediaOwner mediaOwner;
  final BillboardAssetOwner assetOwner;
  final BillboardLicense license;
  final BillboardRemark remark;
  final List<BillboardFace> faces;
  final List<BillboardPhoto> photos;

  bool get isUpdate => billboardNo != null && billboardNo!.isNotEmpty;

  BillboardForm copyWith({
    String? billboardNo,
    String? updatedAt,
    BillboardDetails? details,
    BillboardLocation? location,
    BillboardGps? gps,
    BillboardMediaOwner? mediaOwner,
    BillboardAssetOwner? assetOwner,
    BillboardLicense? license,
    BillboardRemark? remark,
    List<BillboardFace>? faces,
    List<BillboardPhoto>? photos,
  }) {
    return BillboardForm(
      billboardNo: billboardNo ?? this.billboardNo,
      updatedAt: updatedAt ?? this.updatedAt,
      details: details ?? this.details,
      location: location ?? this.location,
      gps: gps ?? this.gps,
      mediaOwner: mediaOwner ?? this.mediaOwner,
      assetOwner: assetOwner ?? this.assetOwner,
      license: license ?? this.license,
      remark: remark ?? this.remark,
      faces: faces ?? this.faces,
      photos: photos ?? this.photos,
    );
  }

  @override
  List<Object?> get props => [
    billboardNo,
    updatedAt,
    details,
    location,
    gps,
    mediaOwner,
    assetOwner,
    license,
    remark,
    faces,
    photos,
  ];
}
