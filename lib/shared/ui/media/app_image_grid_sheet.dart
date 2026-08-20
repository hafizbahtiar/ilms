import 'package:flutter/material.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/media/app_image_source.dart';
import 'package:ilms/shared/ui/media/app_image_viewer_page.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

/// Shows all [images] in a scrollable grid inside a bottom sheet.
Future<void> showAppImageGridSheet(
  BuildContext context, {
  required List<AppImageItem> images,
  String title = 'All Photos',
  String? subtitle,
  int crossAxisCount = 3,
}) {
  if (images.isEmpty) return Future<void>.value();

  return showAppBottomSheet<void>(
    context: context,
    title: title,
    subtitle: subtitle ?? '${images.length} photos',
    preset: AppBottomSheetPreset.scrollable,
    itemCount: images.length,
    builder: (context, scrollController) {
      return GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 8,top: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return _GridImageTile(
            item: images[index],
            index: index,
            onTap: () {
              Navigator.of(context).pop();
              showAppImageViewer(context, images: images, initialIndex: index);
            },
          );
        },
      );
    },
  );
}

class _GridImageTile extends StatelessWidget {
  const _GridImageTile({required this.item, required this.index, required this.onTap});

  final AppImageItem item;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImageSource.thumbnail(item),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
