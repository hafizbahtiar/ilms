import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/files/internal_storage_manager.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_photo.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_form_providers.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_providers.dart';
import 'package:ilms/shared/constants/app_image_limits.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/forms/app_image_field.dart';
import 'package:ilms/shared/ui/media/app_image_picker.dart';

/// Flat photo list, no caption/type-code — unlike premise's typed census
/// images. No minimum-photo gate (design doc: "validation stays light").
class BillboardPhotoSection extends ConsumerStatefulWidget {
  const BillboardPhotoSection({super.key});

  @override
  ConsumerState<BillboardPhotoSection> createState() => _BillboardPhotoSectionState();
}

class _BillboardPhotoSectionState extends ConsumerState<BillboardPhotoSection> {
  var _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final session = BillboardFormScope.of(context);
    final readOnly = ref.watch(billboardFormControllerProvider(session).select((s) => s.isReadOnly));
    final photos = ref.watch(billboardFormControllerProvider(session).select((s) => s.photos));
    final controller = ref.read(billboardFormControllerProvider(session).notifier);

    return AppImageField(
      label: 'Photos',
      images: photos.map(_toAppImageItem).toList(),
      readOnly: readOnly,
      isProcessing: _isSaving,
      maxImages: AppImageLimits.defaultMaxImages,
      onAdd: readOnly ? null : () => _pickPhotos(context, controller, photos.length),
      onRemove: readOnly ? null : (index) => _removePhoto(context, controller, photos, index),
    );
  }

  AppImageItem _toAppImageItem(BillboardPhoto photo) {
    return AppImageItem(
      id: photo.localId?.toString() ?? photo.id?.toString(),
      localPath: photo.localPath,
      networkUrl: photo.networkUrl,
    );
  }

  Future<void> _pickPhotos(BuildContext context, BillboardFormController controller, int currentCount) async {
    final remaining = remainingImageSlots(currentCount: currentCount);
    if (remaining <= 0) {
      AppSnackbar.warning(context, 'Maximum ${AppImageLimits.defaultMaxImages} photos reached.');
      return;
    }

    final picked = await pickAppImageFiles(
      context,
      sheetTitle: 'Add Billboard Photo',
      sheetSubtitle: 'Up to $remaining more photo${remaining == 1 ? '' : 's'}',
      galleryLimit: remaining,
    );
    if (picked.isEmpty || !context.mounted) return;

    setState(() => _isSaving = true);

    var savedCount = 0;
    try {
      for (final file in picked.take(remaining)) {
        final saved = await InternalStorageManager.instance.saveFile(
          fileData: file,
          fileName: 'billboard_${DateTime.now().millisecondsSinceEpoch}_$savedCount.jpg',
          subFolder: 'billboard_photos',
        );

        if (!context.mounted) return;
        if (saved == null) continue;

        controller.addPhoto(BillboardPhoto(localPath: saved.path));
        savedCount++;

        if (file.path != saved.path) {
          final temp = File(file.path);
          if (temp.existsSync()) {
            await temp.delete();
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    if (!context.mounted) return;

    if (savedCount == 0) {
      AppSnackbar.error(context, 'Failed to save the selected photos.');
    } else if (savedCount < picked.length) {
      AppSnackbar.warning(context, '$savedCount of ${picked.length} photos were saved.');
    }
  }

  Future<void> _removePhoto(
    BuildContext context,
    BillboardFormController controller,
    List<BillboardPhoto> photos,
    int index,
  ) async {
    if (index < 0 || index >= photos.length) return;
    final photo = photos[index];

    if (photo.id != null) {
      final confirmed = await confirmAppDialog(
        context: context,
        title: 'Delete this photo?',
        message: 'This photo has already been uploaded and will be permanently removed from the record.',
        confirmLabel: 'Delete',
        confirmStyle: AppDialogActionStyle.destructive,
      );
      if (!confirmed || !context.mounted) return;

      setState(() => _isSaving = true);
      try {
        await ref.read(billboardRepositoryProvider).deletePhoto(photoId: photo.id!.toString());
      } catch (_) {
        if (mounted) setState(() => _isSaving = false);
        if (context.mounted) AppSnackbar.error(context, 'Failed to delete photo.');
        return;
      }
      if (mounted) setState(() => _isSaving = false);
    }

    controller.removePhotoAt(index);
  }
}
