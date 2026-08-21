import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_image_upload_status.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';

/// Serializable snapshot of premise form presentation state for local drafts.
class PremiseDraftPayloadModel {
  const PremiseDraftPayloadModel({
    this.companyStateCode,
    this.companyPostcode,
    this.fields = const {},
    this.censusImages = const [],
    this.remarks = const [],
    this.licenses = const [],
    this.businessActivities = const [],
    this.addresses = const [],
  });

  final String? companyStateCode;
  final String? companyPostcode;
  final Map<String, String> fields;
  final List<PremiseCensusImage> censusImages;
  final List<PremiseRemark> remarks;
  final List<PremiseLicense> licenses;
  final List<PremiseBusinessActivity> businessActivities;
  final List<PremiseAddress> addresses;

  Map<String, dynamic> toJson() => {
    'companyStateCode': companyStateCode,
    'companyPostcode': companyPostcode,
    'fields': fields,
    'censusImages': censusImages.map(_imageToJson).toList(),
    'remarks': remarks.map(_remarkToJson).toList(),
    'licenses': licenses.map(_licenseToJson).toList(),
    'businessActivities': businessActivities.map(_businessActivityToJson).toList(),
    'addresses': addresses.map(_addressToJson).toList(),
  };

  factory PremiseDraftPayloadModel.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'];
    final rawImages = json['censusImages'];
    final rawRemarks = json['remarks'];
    final rawLicenses = json['licenses'];
    final rawBusinessActivities = json['businessActivities'];
    final rawAddresses = json['addresses'];

    return PremiseDraftPayloadModel(
      companyStateCode: json['companyStateCode'] as String?,
      companyPostcode: json['companyPostcode'] as String?,
      fields: rawFields is Map ? rawFields.map((key, value) => MapEntry('$key', '$value')) : const {},
      censusImages: rawImages is List
          ? rawImages.whereType<Map>().map((item) => _imageFromJson(Map<String, dynamic>.from(item))).toList()
          : const [],
      remarks: rawRemarks is List
          ? rawRemarks.whereType<Map>().map((item) => _remarkFromJson(Map<String, dynamic>.from(item))).toList()
          : const [],
      licenses: rawLicenses is List
          ? rawLicenses.whereType<Map>().map((item) => _licenseFromJson(Map<String, dynamic>.from(item))).toList()
          : const [],
      businessActivities: rawBusinessActivities is List
          ? rawBusinessActivities
                .whereType<Map>()
                .map((item) => _businessActivityFromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
      addresses: rawAddresses is List
          ? rawAddresses.whereType<Map>().map((item) => _addressFromJson(Map<String, dynamic>.from(item))).toList()
          : const [],
    );
  }

  static Map<String, dynamic> _imageToJson(PremiseCensusImage image) => {
    'localPath': image.localPath,
    'networkUrl': image.networkUrl,
    'typeCode': image.typeCode,
    'typeDescription': image.typeDescription,
    'uploadStatus': image.uploadStatus.name,
    'visitNo': image.visitNo,
    'uploadSeq': image.uploadSeq,
  };

  static PremiseCensusImage _imageFromJson(Map<String, dynamic> json) {
    return PremiseCensusImage(
      localPath: json['localPath'] as String?,
      networkUrl: json['networkUrl'] as String?,
      typeCode: json['typeCode'] as String?,
      typeDescription: json['typeDescription'] as String?,
      uploadStatus: _uploadStatusFromStorage(json['uploadStatus'] as String?),
      visitNo: json['visitNo'] as String?,
      uploadSeq: json['uploadSeq'] as int?,
    );
  }

  static PremiseImageUploadStatus _uploadStatusFromStorage(String? value) {
    return PremiseImageUploadStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => PremiseImageUploadStatus.local,
    );
  }

  static Map<String, dynamic> _remarkToJson(PremiseRemark remark) => {
    if (remark.id != null) 'id': remark.id,
    if (remark.localId != null) 'localId': remark.localId,
    'code': remark.code,
    'remark': remark.remark,
    'remarkType': remark.remarkType,
    'remarkDesc': remark.remarkDesc,
    'description': remark.description,
  };

  static PremiseRemark _remarkFromJson(Map<String, dynamic> json) {
    return PremiseRemark(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      localId: json['localId'] is int ? json['localId'] as int : int.tryParse('${json['localId']}'),
      code: json['code'] as String?,
      remark: json['remark'] as String?,
      remarkType: json['remarkType'] as String?,
      remarkDesc: json['remarkDesc'] as String?,
      description: json['description'] as String?,
    );
  }

  static Map<String, dynamic> _licenseToJson(PremiseLicense license) => {
    if (license.id != null) 'id': license.id,
    if (license.localId != null) 'localId': license.localId,
    'licenseNo': license.licenseNo,
    'licenseFileNo': license.licenseFileNo,
    'validFrom': license.validFrom,
    'validTo': license.validTo,
    'status': license.status,
    'statusDesc': license.statusDesc,
    'businessActivities': license.businessActivities.map(_licenseActivityToJson).toList(),
  };

  static PremiseLicense _licenseFromJson(Map<String, dynamic> json) {
    final rawActivities = json['businessActivities'];

    return PremiseLicense(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      localId: json['localId'] is int ? json['localId'] as int : int.tryParse('${json['localId']}'),
      licenseNo: json['licenseNo'] as String?,
      licenseFileNo: json['licenseFileNo'] as String?,
      validFrom: json['validFrom'] as String?,
      validTo: json['validTo'] as String?,
      status: json['status'] as String?,
      statusDesc: json['statusDesc'] as String?,
      businessActivities: rawActivities is List
          ? rawActivities
                .whereType<Map>()
                .map((item) => _licenseActivityFromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
    );
  }

  static Map<String, dynamic> _licenseActivityToJson(PremiseLicenseActivity activity) => {
    'businessType': activity.businessType,
    'businessTypeDesc': activity.businessTypeDesc,
    'status': activity.status,
    'statusDesc': activity.statusDesc,
    'description': activity.description,
    'amount': activity.amount,
    'saveToBusiness': activity.saveToBusiness,
    if (activity.businessActivityLocalId != null) 'businessActivityLocalId': activity.businessActivityLocalId,
  };

  static PremiseLicenseActivity _licenseActivityFromJson(Map<String, dynamic> json) {
    return PremiseLicenseActivity(
      businessType: json['businessType'] as String?,
      businessTypeDesc: json['businessTypeDesc'] as String?,
      status: json['status'] as String?,
      statusDesc: json['statusDesc'] as String?,
      description: json['description'] as String?,
      amount: json['amount'] as String?,
      saveToBusiness: json['saveToBusiness'] == true,
      businessActivityLocalId: json['businessActivityLocalId'] is int
          ? json['businessActivityLocalId'] as int
          : int.tryParse('${json['businessActivityLocalId']}'),
    );
  }

  static Map<String, dynamic> _businessActivityToJson(PremiseBusinessActivity activity) => {
    if (activity.id != null) 'id': activity.id,
    if (activity.localId != null) 'localId': activity.localId,
    'businessType': activity.businessType,
    'businessTypeDesc': activity.businessTypeDesc,
    'status': activity.status,
    'statusDesc': activity.statusDesc,
    'description': activity.description,
  };

  static PremiseBusinessActivity _businessActivityFromJson(Map<String, dynamic> json) {
    return PremiseBusinessActivity(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      localId: json['localId'] is int ? json['localId'] as int : int.tryParse('${json['localId']}'),
      businessType: json['businessType'] as String?,
      businessTypeDesc: json['businessTypeDesc'] as String?,
      status: json['status'] as String?,
      statusDesc: json['statusDesc'] as String?,
      description: json['description'] as String?,
    );
  }

  static Map<String, dynamic> _addressToJson(PremiseAddress address) => {
    if (address.premiseAddressId != null) 'premiseAddressId': address.premiseAddressId,
    if (address.visitPremiseAddressId != null) 'visitPremiseAddressId': address.visitPremiseAddressId,
    if (address.localId != null) 'localId': address.localId,
    'unitNo': address.unitNo,
    'floor': address.floor,
    'blockNo': address.blockNo,
    'building': address.building,
    'streetName': address.streetName,
    'area': address.area,
    'parliament': address.parliament,
    'postcode': address.postcode,
    'state': address.state,
    'latitude': address.latitude,
    'longitude': address.longitude,
  };

  static PremiseAddress _addressFromJson(Map<String, dynamic> json) {
    return PremiseAddress(
      premiseAddressId: json['premiseAddressId'] is int
          ? json['premiseAddressId'] as int
          : int.tryParse('${json['premiseAddressId']}'),
      visitPremiseAddressId: json['visitPremiseAddressId'] is int
          ? json['visitPremiseAddressId'] as int
          : int.tryParse('${json['visitPremiseAddressId']}'),
      localId: json['localId'] is int ? json['localId'] as int : int.tryParse('${json['localId']}'),
      unitNo: json['unitNo'] as String?,
      floor: json['floor'] as String?,
      blockNo: json['blockNo'] as String?,
      building: json['building'] as String?,
      streetName: json['streetName'] as String?,
      area: json['area'] as String?,
      parliament: json['parliament'] as String?,
      postcode: json['postcode'] as String?,
      state: json['state'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
    );
  }
}
