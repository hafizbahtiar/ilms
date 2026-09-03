import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ilms/shared/ui/media/app_image_source_sheet.dart';
import 'package:ilms/shared/ui/media/camera/app_camera_page.dart';

/// Shows the camera/gallery chooser, then returns picked image files.
///
/// Pass [galleryLimit] to cap selections (e.g. remaining slots toward [AppImageLimits.defaultMaxImages]).
Future<List<File>> pickAppImageFiles(
  BuildContext context, {
  String sheetTitle = 'Add Photo',
  String sheetSubtitle = 'Take a photo or choose from your gallery',
  int imageQuality = 88,
  int? galleryLimit,
}) async {
  final source = await showAppImageSourceSheet(context, title: sheetTitle, subtitle: sheetSubtitle);
  if (source == null || !context.mounted) return const [];

  return switch (source) {
    AppImageSourceChoice.camera => _pickFromCamera(context, maxPhotos: galleryLimit),
    AppImageSourceChoice.gallery => _pickFromGallery(imageQuality: imageQuality, limit: galleryLimit),
  };
}

/// Convenience wrapper when only one file is expected.
Future<File?> pickAppImageFile(
  BuildContext context, {
  String sheetTitle = 'Add Photo',
  String sheetSubtitle = 'Take a photo or choose from your gallery',
  int imageQuality = 88,
}) async {
  final files = await pickAppImageFiles(
    context,
    sheetTitle: sheetTitle,
    sheetSubtitle: sheetSubtitle,
    imageQuality: imageQuality,
    galleryLimit: 1,
  );
  return files.isEmpty ? null : files.first;
}

/// Camera returns one or more files after the review step.
Future<List<File>> _pickFromCamera(BuildContext context, {int? maxPhotos}) async {
  return AppCameraPage.open(context, maxPhotos: maxPhotos);
}

/// Gallery photos come straight off the camera roll at full sensor
/// resolution (often 10+ MB, sometimes HEIC) — unlike the in-app camera,
/// which shoots at [ResolutionPreset.high] and is always a few hundred KB.
/// Without capping dimensions here, a large gallery photo can exceed the
/// backend's upload size limit; PHP then drops the upload before Laravel's
/// validator ever sees a file, which surfaces as a misleading "required"
/// error instead of a size/format one. `maxWidth`/`maxHeight` make
/// image_picker downsample natively (same mechanism as `imageQuality`), so
/// this needs no extra compression dependency.
const int _galleryMaxDimension = 1920;

Future<List<File>> _pickFromGallery({required int imageQuality, int? limit}) async {
  final picked = await ImagePicker().pickMultiImage(
    imageQuality: imageQuality,
    maxWidth: _galleryMaxDimension.toDouble(),
    maxHeight: _galleryMaxDimension.toDouble(),
    limit: limit,
  );
  if (picked.isEmpty) return const [];
  return picked.map((file) => File(file.path)).toList();
}
