import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_image_upload_status.dart';

/// Serializable snapshot of premise form presentation state for local drafts.
class PremiseDraftPayloadModel {
  const PremiseDraftPayloadModel({
    this.companyStateCode,
    this.companyPostcode,
    this.fields = const {},
    this.censusImages = const [],
  });

  final String? companyStateCode;
  final String? companyPostcode;
  final Map<String, String> fields;
  final List<PremiseCensusImage> censusImages;

  Map<String, dynamic> toJson() => {
        'companyStateCode': companyStateCode,
        'companyPostcode': companyPostcode,
        'fields': fields,
        'censusImages': censusImages.map(_imageToJson).toList(),
      };

  factory PremiseDraftPayloadModel.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'];
    final rawImages = json['censusImages'];

    return PremiseDraftPayloadModel(
      companyStateCode: json['companyStateCode'] as String?,
      companyPostcode: json['companyPostcode'] as String?,
      fields: rawFields is Map
          ? rawFields.map((key, value) => MapEntry('$key', '$value'))
          : const {},
      censusImages: rawImages is List
          ? rawImages
              .whereType<Map>()
              .map((item) => _imageFromJson(Map<String, dynamic>.from(item)))
              .toList()
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
}
