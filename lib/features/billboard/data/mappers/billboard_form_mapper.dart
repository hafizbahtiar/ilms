import 'package:ilms/features/billboard/domain/entities/billboard_asset_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_details.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_face.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_gps.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_license.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_location.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_media_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_photo.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_remark.dart';
import 'package:ilms/features/premise/domain/entities/premise_image_upload_status.dart';

/// Maps `/api/billboardCensus/detail` payload into [BillboardForm], for
/// view/edit flows. Mirrors legacy `CreateBillBoardInput.fromJsonView`.
class BillboardFormMapper {
  BillboardFormMapper._();

  static BillboardForm fromApiDetail(Map<String, dynamic> data) {
    final location = _asMap(data['location_details']);
    final gps = _asMap(data['gps_details']);
    final mediaOwner = _asMap(data['media_owner_details']);
    final assetOwner = _asMap(data['asset_owner_details']);
    final details = _asMap(data['billboard_details']);
    final license = _asMap(data['license_details']);
    final remarks = _asMap(data['remarks_details']);

    return BillboardForm(
      billboardNo: _nullableString(data['billboard_no']),
      updatedAt: _nullableString(data['updated_at']),
      details: BillboardDetails(
        phaseCode: _nullableString(details['phase_code']),
        phaseDesc: _nullableString(details['phase_desc']),
        description: _nullableString(details['description']),
        billboardTypeCode: _nullableString(details['billboard_type']),
        billboardTypeDesc: _nullableString(details['billboard_type_desc']),
        isLedBoard: _isYes(details['is_led_board']),
        isLight: _isYes(details['is_light']),
        isPotential: _isYes(details['is_potential']),
        hoardingStartDate: _nullableString(details['hording_start_date']),
        hoardingCompleteDate: _nullableString(details['hording_complete_date']),
      ),
      location: BillboardLocation(
        mediaClientName: _nullableString(location['media_client_name']),
        mediaClientTel: _nullableString(location['media_client_tel']),
        unit: _nullableString(location['unit']),
        // `street1` is dropped in the domain model — only `street2` survives
        // as `address`.
        address: _nullableString(location['street2']),
        postal: _nullableString(location['postal']),
        building: _nullableString(location['building']),
        parliamentCode: _nullableString(location['parliament_code']),
        parliamentDesc: _nullableString(location['parliament_desc']),
        areaCode: _nullableString(location['area']),
        areaDesc: _nullableString(location['area_desc']),
      ),
      gps: BillboardGps(latitude: _nullableString(gps['lat_census']), longitude: _nullableString(gps['long_census'])),
      mediaOwner: BillboardMediaOwner(
        name: _nullableString(mediaOwner['mo_name']),
        tel: _nullableString(mediaOwner['mo_tel']),
      ),
      assetOwner: BillboardAssetOwner(
        code: _nullableString(assetOwner['ao_code']),
        desc: _nullableString(assetOwner['ao_desc']),
      ),
      license: BillboardLicense(fileNo: _nullableString(license['license_file_no'])),
      remark: _mapRemark(remarks['remark']),
      faces: _mapFaces(data['faces']),
      photos: _mapPhotos(data['images']),
    );
  }

  /// The server stores remarks as a single comma-joined string. Resolving it
  /// into fixed codes vs. "Others" free text requires the live remark option
  /// list (`billboard_remark_codec.dart`'s `resolveRemarkOptions`), which
  /// this data-layer mapper does not have — that resolution happens once the
  /// presentation layer loads the option list. Here every token is carried
  /// through as a code so no data is lost.
  static BillboardRemark _mapRemark(dynamic raw) {
    final tokens = (raw?.toString() ?? '')
        .split(',')
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toList();
    return BillboardRemark(codes: tokens);
  }

  static List<BillboardFace> _mapFaces(dynamic rawFaces) {
    if (rawFaces is! List) return const [];

    return rawFaces.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return BillboardFace(
        id: _int(map['id']),
        width: _int(map['width']),
        height: _int(map['height']),
        count: _int(map['count']),
      );
    }).toList();
  }

  static List<BillboardPhoto> _mapPhotos(dynamic rawImages) {
    if (rawImages is! List) return const [];

    return rawImages.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return BillboardPhoto(
        id: _int(map['id']),
        networkUrl: _nullableString(map['url']),
        uploadStatus: PremiseImageUploadStatus.uploaded,
      );
    }).toList();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static int? _int(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value');
  }

  static bool _isYes(dynamic value) => value?.toString().toUpperCase() == 'Y';
}
