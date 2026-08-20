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

Future<List<File>> _pickFromGallery({required int imageQuality, int? limit}) async {
  final picked = await ImagePicker().pickMultiImage(imageQuality: imageQuality, limit: limit);
  if (picked.isEmpty) return const [];
  return picked.map((file) => File(file.path)).toList();
}
