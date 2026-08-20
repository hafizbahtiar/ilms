import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/files/internal_storage_manager.dart';
import 'package:ilms/features/premise/data/mappers/premise_census_image_mapper.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/shared/constants/app_image_limits.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/forms/app_image_field.dart';
import 'package:ilms/shared/ui/media/app_image_picker.dart';

class CensusImagesSection extends ConsumerWidget {
  const CensusImagesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final readOnly = ref.watch(premiseFormControllerProvider(session).select((s) => s.isReadOnly));
    final images = ref.watch(premiseFormControllerProvider(session).select((s) => s.censusImages));
    final controller = ref.read(premiseFormControllerProvider(session).notifier);

    return AppImageField(
      label: 'Census Images',
      images: PremiseCensusImageMapper.toAppImageItems(images),
      readOnly: readOnly,
      maxImages: AppImageLimits.defaultMaxImages,
      onAdd: readOnly ? null : () => _pickImages(context, controller, images.length),
      onRemove: readOnly ? null : controller.removeCensusImageAt,
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

    var savedCount = 0;
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

    if (!context.mounted) return;

    if (savedCount == 0) {
      AppSnackbar.error(context, 'Failed to save the selected photos.');
    } else if (savedCount < picked.length) {
      AppSnackbar.warning(context, '$savedCount of ${picked.length} photos were saved.');
    }
  }
}
