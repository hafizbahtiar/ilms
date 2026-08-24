import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_photo.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_form_providers.dart';
import 'package:ilms/shared/constants/app_image_limits.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/forms/app_image_field.dart';
import 'package:ilms/shared/ui/media/app_image_picker.dart';

/// Untyped photo list — legacy sends one fixed empty photo type with no
/// per-image classification or description (unlike premise's typed census
/// images).
class InvestigationPhotoSection extends ConsumerStatefulWidget {
  const InvestigationPhotoSection({super.key});

  @override
  ConsumerState<InvestigationPhotoSection> createState() => _InvestigationPhotoSectionState();
}

class _InvestigationPhotoSectionState extends ConsumerState<InvestigationPhotoSection> {
  var _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final session = InvestigationFormScope.of(context);
    final readOnly = ref.watch(investigationFormControllerProvider(session).select((s) => s.isReadOnly));
    final photos = ref.watch(investigationFormControllerProvider(session).select((s) => s.photos));
    final controller = ref.read(investigationFormControllerProvider(session).notifier);

    return AppImageField(
      label: 'Photos',
      images: photos.map(_toAppImageItem).toList(),
      readOnly: readOnly,
      isProcessing: _isSaving,
      maxImages: AppImageLimits.defaultMaxImages,
      onAdd: readOnly ? null : () => _pickPhotos(context, controller, photos.length),
      onRemove: readOnly ? null : (index) => controller.removePhotoAt(index),
    );
  }

  AppImageItem _toAppImageItem(InvestigationPhoto photo) {
    return AppImageItem(id: photo.imageId?.toString(), networkUrl: photo.url, bytes: photo.bytes);
  }

  Future<void> _pickPhotos(BuildContext context, dynamic controller, int currentCount) async {
    final remaining = remainingImageSlots(currentCount: currentCount);
    if (remaining <= 0) {
      AppSnackbar.warning(context, 'Maximum ${AppImageLimits.defaultMaxImages} photos reached.');
      return;
    }

    final picked = await pickAppImageFiles(
      context,
      sheetTitle: 'Add Investigation Photo',
      sheetSubtitle: 'Up to $remaining more photo${remaining == 1 ? '' : 's'}',
      galleryLimit: remaining,
    );
    if (picked.isEmpty || !context.mounted) return;

    setState(() => _isSaving = true);
    try {
      for (var i = 0; i < picked.length; i++) {
        final bytes = await picked[i].readAsBytes();
        controller.addPhoto(InvestigationPhoto(sequence: currentCount + i, bytes: bytes));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
