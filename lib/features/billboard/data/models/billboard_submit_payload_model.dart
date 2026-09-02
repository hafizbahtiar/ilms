import 'package:ilms/features/billboard/domain/entities/billboard_asset_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_details.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_face.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_gps.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_license.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_location.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_media_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_remark.dart';
import 'package:ilms/features/billboard/domain/utils/billboard_remark_codec.dart';

/// Request model for `/api/billboardCensus/create|update`, mirroring legacy
/// `CreateBillBoardInput` (one class per sub-object, same field placement).
///
/// Photos are intentionally excluded — they upload via `/create-photo` after submit.
class BillboardSubmitPayloadModel {
  const BillboardSubmitPayloadModel({
    this.billboardNo,
    required this.locationDetails,
    required this.gpsDetails,
    required this.mediaOwnerDetails,
    required this.assetOwnerDetails,
    required this.billboardDetails,
    required this.licenseDetails,
    required this.remarksDetails,
    this.faces = const [],
  });

  final String? billboardNo;
  final BillboardLocationRequest locationDetails;
  final BillboardGpsRequest gpsDetails;
  final BillboardMediaOwnerRequest mediaOwnerDetails;
  final BillboardAssetOwnerRequest assetOwnerDetails;
  final BillboardDetailsRequest billboardDetails;
  final BillboardLicenseRequest licenseDetails;
  final BillboardRemarkRequest remarksDetails;
  final List<BillboardFaceRequest> faces;

  factory BillboardSubmitPayloadModel.fromDomain(BillboardForm form) {
    return BillboardSubmitPayloadModel(
      billboardNo: form.billboardNo,
      locationDetails: BillboardLocationRequest.fromDomain(form.location),
      gpsDetails: BillboardGpsRequest.fromDomain(form.gps),
      mediaOwnerDetails: BillboardMediaOwnerRequest.fromDomain(form.mediaOwner),
      assetOwnerDetails: BillboardAssetOwnerRequest.fromDomain(form.assetOwner),
      billboardDetails: BillboardDetailsRequest.fromDomain(form.details),
      licenseDetails: BillboardLicenseRequest.fromDomain(form.license),
      remarksDetails: BillboardRemarkRequest.fromDomain(form.remark),
      faces: form.faces.map(BillboardFaceRequest.fromDomain).toList(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'location_details': locationDetails.toJson(),
      'gps_details': gpsDetails.toJson(),
      'media_owner_details': mediaOwnerDetails.toJson(),
      'asset_owner_details': assetOwnerDetails.toJson(),
      'billboard_details': billboardDetails.toJson(),
      'license_details': licenseDetails.toJson(),
      'remarks_details': remarksDetails.toJson(),
      'faces': faces.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'billboard_no': billboardNo,
      'location_details': locationDetails.toJson(),
      'gps_details': gpsDetails.toJson(),
      'media_owner_details': mediaOwnerDetails.toJson(),
      'asset_owner_details': assetOwnerDetails.toJson(),
      'billboard_details': billboardDetails.toJson(),
      'license_details': licenseDetails.toJson(),
      'remarks_details': remarksDetails.toJson(),
      'faces': faces.map((e) => e.toJson()).toList(),
    };
  }
}

/// `billboard_details` (legacy `BillboardDetails`). Yes/No fields are
/// re-encoded from domain `bool` back into the legacy `"Y"`/`"N"` strings.
class BillboardDetailsRequest {
  const BillboardDetailsRequest({
    this.phase,
    this.description,
    this.billboardType,
    required this.isLedBoard,
    required this.isLight,
    required this.isPotential,
    this.hoardingStartDate,
    this.hoardingCompleteDate,
  });

  final String? phase;
  final String? description;
  final String? billboardType;
  final bool isLedBoard;
  final bool isLight;
  final bool isPotential;
  final String? hoardingStartDate;
  final String? hoardingCompleteDate;

  factory BillboardDetailsRequest.fromDomain(BillboardDetails details) => BillboardDetailsRequest(
    phase: details.phaseCode,
    description: details.description,
    billboardType: details.billboardTypeCode,
    isLedBoard: details.isLedBoard,
    isLight: details.isLight,
    isPotential: details.isPotential,
    hoardingStartDate: details.hoardingStartDate,
    hoardingCompleteDate: details.hoardingCompleteDate,
  );

  static String _yesNo(bool value) => value ? 'Y' : 'N';

  Map<String, dynamic> toJson() => {
    'phase': phase,
    'description': description,
    'billboard_type': billboardType,
    'is_led_board': _yesNo(isLedBoard),
    'is_light': _yesNo(isLight),
    'is_potential': _yesNo(isPotential),
    // Backend still uses the misspelled `hording_*` keys.
    'hording_start_date': hoardingStartDate,
    'hording_complete_date': hoardingCompleteDate,
  };
}

/// `location_details` (legacy `LocationDetails`). `street1` is sent empty —
/// the domain model has dropped it; only `street2`'s role survives as
/// [BillboardLocation.address].
class BillboardLocationRequest {
  const BillboardLocationRequest({
    this.mediaClientName,
    this.mediaClientTel,
    this.unit,
    this.address,
    this.postal,
    this.building,
    this.parliamentCode,
    this.areaCode,
  });

  final String? mediaClientName;
  final String? mediaClientTel;
  final String? unit;
  final String? address;
  final String? postal;
  final String? building;
  final String? parliamentCode;
  final String? areaCode;

  factory BillboardLocationRequest.fromDomain(BillboardLocation location) => BillboardLocationRequest(
    mediaClientName: location.mediaClientName,
    mediaClientTel: location.mediaClientTel,
    unit: location.unit,
    address: location.address,
    postal: location.postal,
    building: location.building,
    parliamentCode: location.parliamentCode,
    areaCode: location.areaCode,
  );

  Map<String, dynamic> toJson() => {
    'media_client_name': mediaClientName,
    'media_client_tel': mediaClientTel,
    'unit': unit,
    'street1': '',
    'street2': address,
    'postal': postal,
    'building': building,
    'parliament_code': parliamentCode,
    'area': areaCode,
  };
}

/// `gps_details` (legacy `GpsDetails`).
class BillboardGpsRequest {
  const BillboardGpsRequest({this.latitude, this.longitude});

  final String? latitude;
  final String? longitude;

  factory BillboardGpsRequest.fromDomain(BillboardGps gps) =>
      BillboardGpsRequest(latitude: gps.latitude, longitude: gps.longitude);

  Map<String, dynamic> toJson() => {'lat_census': latitude, 'long_census': longitude};
}

/// `media_owner_details` (legacy `MediaOwnerDetails`).
class BillboardMediaOwnerRequest {
  const BillboardMediaOwnerRequest({this.name, this.tel});

  final String? name;
  final String? tel;

  factory BillboardMediaOwnerRequest.fromDomain(BillboardMediaOwner mediaOwner) =>
      BillboardMediaOwnerRequest(name: mediaOwner.name, tel: mediaOwner.tel);

  Map<String, dynamic> toJson() => {'mo_name': name, 'mo_tel': tel};
}

/// `asset_owner_details` (legacy `AssetOwnerDetails`).
class BillboardAssetOwnerRequest {
  const BillboardAssetOwnerRequest({this.code, this.desc});

  final String? code;
  final String? desc;

  factory BillboardAssetOwnerRequest.fromDomain(BillboardAssetOwner assetOwner) =>
      BillboardAssetOwnerRequest(code: assetOwner.code, desc: assetOwner.desc);

  Map<String, dynamic> toJson() => {'ao_code': code, 'ao_desc': desc};
}

/// `license_details` (legacy `LicenseDetails`).
class BillboardLicenseRequest {
  const BillboardLicenseRequest({this.fileNo});

  final String? fileNo;

  factory BillboardLicenseRequest.fromDomain(BillboardLicense license) =>
      BillboardLicenseRequest(fileNo: license.fileNo);

  Map<String, dynamic> toJson() => {'license_file_no': fileNo};
}

/// `remarks_details` (legacy `RemarksDetails`) — selected codes plus optional
/// "Others" free text re-encoded into the legacy comma-joined string.
class BillboardRemarkRequest {
  const BillboardRemarkRequest({this.remark});

  final String? remark;

  factory BillboardRemarkRequest.fromDomain(BillboardRemark remark) => BillboardRemarkRequest(
    remark: encodeRemarkOptions(codes: remark.codes, otherText: remark.otherText),
  );

  Map<String, dynamic> toJson() => {'remark': remark};
}

/// One entry in `faces` (legacy `Face`). `id` is included only for existing
/// faces (update); newly added faces (no server `id`) omit it.
class BillboardFaceRequest {
  const BillboardFaceRequest({this.id, this.width, this.height, this.count});

  final int? id;
  final int? width;
  final int? height;
  final int? count;

  factory BillboardFaceRequest.fromDomain(BillboardFace face) =>
      BillboardFaceRequest(id: face.id, width: face.width, height: face.height, count: face.count);

  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'width': width, 'height': height, 'count': count};
}
