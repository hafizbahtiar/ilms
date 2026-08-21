import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/files/internal_storage_manager.dart';
import 'package:ilms/features/premise/data/mappers/premise_census_image_mapper.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/shared/constants/app_image_limits.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/forms/app_image_field.dart';
import 'package:ilms/shared/ui/media/app_image_picker.dart';

class CensusImagesSection extends ConsumerStatefulWidget {
  const CensusImagesSection({super.key});

  @override
  ConsumerState<CensusImagesSection> createState() => _CensusImagesSectionState();
}

class _CensusImagesSectionState extends ConsumerState<CensusImagesSection> {
  var _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final session = PremiseFormScope.of(context);
    final readOnly = ref.watch(premiseFormControllerProvider(session).select((s) => s.isReadOnly));
    final images = ref.watch(premiseFormControllerProvider(session).select((s) => s.censusImages));
    final controller = ref.read(premiseFormControllerProvider(session).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppImageField(
          label: 'Census Images',
          required: true,
          images: PremiseCensusImageMapper.toAppImageItems(images),
          readOnly: readOnly,
          isProcessing: _isSaving,
          maxImages: AppImageLimits.defaultMaxImages,
          onAdd: readOnly ? null : () => _pickImages(context, controller, images.length),
          onRemove: readOnly ? null : (index) => _removeImage(context, controller, images, index),
        ),
        const SizedBox(height: 6),
        Text(
          'Minimum ${AppImageLimits.premiseMinCensusImages} photos required to submit.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages(BuildContext context, PremiseFormController controller, int currentCount) async {
    final remaining = remainingImageSlots(currentCount: currentCount);
    if (remaining <= 0) {
      AppSnackbar.warning(context, 'Maximum ${AppImageLimits.defaultMaxImages} photos reached.');
      return;
    }

    final picked = await pickAppImageFiles(
      context,
      sheetTitle: 'Add Census Photo',
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
          fileName: 'census_${DateTime.now().millisecondsSinceEpoch}_$savedCount.jpg',
          subFolder: 'census_images',
        );

        if (!context.mounted) return;

        if (saved == null) continue;

        if (!controller.addCensusImage(PremiseCensusImageMapper.fromLocalCapture(localPath: saved.path))) {
          break;
        }
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

  Future<void> _removeImage(
    BuildContext context,
    PremiseFormController controller,
    List<PremiseCensusImage> images,
    int index,
  ) async {
    if (index < 0 || index >= images.length) return;
    final image = images[index];

    // Already uploaded — confirm before permanently deleting it from the
    // server, unlike a not-yet-uploaded local photo which is cheap to redo.
    if (image.id != null) {
      final confirmed = await confirmAppDialog(
        context: context,
        title: 'Delete this photo?',
        message: 'This photo has already been uploaded and will be permanently removed from the record.',
        confirmLabel: 'Delete',
        confirmStyle: AppDialogActionStyle.destructive,
      );
      if (!confirmed || !context.mounted) return;
    }

    setState(() => _isSaving = true);
    bool ok;
    try {
      ok = await controller.removeCensusImageAt(index);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    if (!context.mounted || ok) return;
    AppSnackbar.error(context, 'Failed to delete photo.');
  }
}
