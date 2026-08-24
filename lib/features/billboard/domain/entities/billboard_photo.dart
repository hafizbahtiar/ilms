import 'package:equatable/equatable.dart';
import 'package:ilms/features/premise/domain/entities/premise_image_upload_status.dart';

/// Billboard photo — flat list, no caption/type-code distinction (unlike
/// premise's typed census images). Reuses `PremiseImageUploadStatus` for the
/// same local/uploading/uploaded lifecycle.
class BillboardPhoto extends Equatable {
  const BillboardPhoto({
    this.id,
    this.localId,
    this.localPath,
    this.networkUrl,
    this.uploadStatus = PremiseImageUploadStatus.local,
  });

  final int? id;
  final int? localId;
  final String? localPath;
  final String? networkUrl;
  final PremiseImageUploadStatus uploadStatus;

  bool get isLocalOnly => localPath != null && networkUrl == null && id == null;

  BillboardPhoto copyWith({
    int? id,
    int? localId,
    String? localPath,
    String? networkUrl,
    PremiseImageUploadStatus? uploadStatus,
  }) {
    return BillboardPhoto(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      localPath: localPath ?? this.localPath,
      networkUrl: networkUrl ?? this.networkUrl,
      uploadStatus: uploadStatus ?? this.uploadStatus,
    );
  }

  @override
  List<Object?> get props => [id, localId, localPath, networkUrl, uploadStatus];
}
