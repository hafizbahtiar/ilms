import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ilms/shared/ui/media/app_image_source_sheet.dart';
import 'package:ilms/shared/ui/media/camera/app_camera_page.dart';

/// Shows the camera/gallery chooser, then returns picked image files.
///
/// Camera returns a single file. Gallery uses multi-select when supported.
Future<List<File>> pickAppImageFiles(
  BuildContext context, {
  String sheetTitle = 'Add Photo',
  String sheetSubtitle = 'Take a photo or choose from your gallery',
  int imageQuality = 88,
  int? galleryLimit,
}) async {
  final source = await showAppImageSourceSheet(
    context,
    title: sheetTitle,
    subtitle: sheetSubtitle,
  );
  if (source == null || !context.mounted) return const [];

  return switch (source) {
    AppImageSourceChoice.camera => _pickFromCamera(context),
    AppImageSourceChoice.gallery => _pickFromGallery(
        imageQuality: imageQuality,
        limit: galleryLimit,
      ),
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

Future<List<File>> _pickFromCamera(BuildContext context) async {
  final captured = await AppCameraPage.open(context);
  if (captured == null) return const [];
  return [captured];
}

Future<List<File>> _pickFromGallery({
  required int imageQuality,
  int? limit,
}) async {
  final picked = await ImagePicker().pickMultiImage(
    imageQuality: imageQuality,
    limit: limit,
  );
  if (picked.isEmpty) return const [];
  return picked.map((file) => File(file.path)).toList();
}
