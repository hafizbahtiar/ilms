import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A single investigation photo. Untyped — legacy sends one fixed empty
/// photo type with no per-image classification or description (unlike
/// premise's typed census images).
///
/// [bytes] is set for a newly-picked, not-yet-uploaded photo; [url] is set
/// for a photo already on the server. Both may be null-paired but never
/// both null in practice.
class InvestigationPhoto extends Equatable {
  const InvestigationPhoto({this.imageId, this.sequence, this.uploadedBy, this.uploadedAt, this.url, this.bytes});

  final int? imageId;
  final int? sequence;
  final String? uploadedBy;
  final DateTime? uploadedAt;
  final String? url;
  final Uint8List? bytes;

  bool get isUploaded => url != null;

  InvestigationPhoto copyWith({
    int? imageId,
    int? sequence,
    String? uploadedBy,
    DateTime? uploadedAt,
    String? url,
    Uint8List? bytes,
  }) {
    return InvestigationPhoto(
      imageId: imageId ?? this.imageId,
      sequence: sequence ?? this.sequence,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      url: url ?? this.url,
      bytes: bytes ?? this.bytes,
    );
  }

  @override
  List<Object?> get props => [imageId, sequence, uploadedBy, uploadedAt, url, bytes];
}
