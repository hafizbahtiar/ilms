import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A single image reference for [AppImageField] and form persistence.
///
/// Provide exactly one source: [localPath], [networkUrl], or [bytes].
class AppImageItem extends Equatable {
  const AppImageItem({
    this.id,
    this.localPath,
    this.networkUrl,
    this.bytes,
  }) : assert(
          localPath != null || networkUrl != null || bytes != null,
          'AppImageItem requires a localPath, networkUrl, or bytes source.',
        );

  final String? id;
  final String? localPath;
  final String? networkUrl;
  final Uint8List? bytes;

  bool get hasSource {
    if (bytes != null && bytes!.isNotEmpty) return true;
    if (networkUrl != null && networkUrl!.isNotEmpty) return true;
    if (localPath != null && localPath!.isNotEmpty) {
      return File(localPath!).existsSync();
    }
    return false;
  }

  AppImageItem copyWith({
    String? id,
    String? localPath,
    String? networkUrl,
    Uint8List? bytes,
  }) {
    return AppImageItem(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      networkUrl: networkUrl ?? this.networkUrl,
      bytes: bytes ?? this.bytes,
    );
  }

  @override
  List<Object?> get props => [id, localPath, networkUrl, bytes];
}
