import 'package:equatable/equatable.dart';
import 'package:ilms/features/premise/domain/entities/premise_image_upload_status.dart';

/// Census photo attached to a premise form.
///
/// Improved over legacy [ImageData]: explicit upload lifecycle and optional
/// image type metadata instead of mixing bytes/path/url without status.
class PremiseCensusImage extends Equatable {
  const PremiseCensusImage({
    this.id,
    this.localId,
    this.typeCode,
    this.typeDescription,
    this.localPath,
    this.networkUrl,
    this.uploadStatus = PremiseImageUploadStatus.local,
    this.visitNo,
    this.uploadSeq,
  });

  final int? id;
  final int? localId;
  final String? typeCode;
  final String? typeDescription;
  final String? localPath;
  final String? networkUrl;
  final PremiseImageUploadStatus uploadStatus;
  final String? visitNo;
  final int? uploadSeq;

  bool get isLocalOnly => localPath != null && networkUrl == null && id == null;

  PremiseCensusImage copyWith({
    int? id,
    int? localId,
    String? typeCode,
    String? typeDescription,
    String? localPath,
    String? networkUrl,
    PremiseImageUploadStatus? uploadStatus,
    String? visitNo,
    int? uploadSeq,
  }) {
    return PremiseCensusImage(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      typeCode: typeCode ?? this.typeCode,
      typeDescription: typeDescription ?? this.typeDescription,
      localPath: localPath ?? this.localPath,
      networkUrl: networkUrl ?? this.networkUrl,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      visitNo: visitNo ?? this.visitNo,
      uploadSeq: uploadSeq ?? this.uploadSeq,
    );
  }

  @override
  List<Object?> get props => [
        id,
        localId,
        typeCode,
        typeDescription,
        localPath,
        networkUrl,
        uploadStatus,
        visitNo,
        uploadSeq,
      ];
}
