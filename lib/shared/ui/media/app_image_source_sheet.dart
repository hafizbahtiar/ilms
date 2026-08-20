import 'package:flutter/material.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

enum AppImageSourceChoice { camera, gallery }

/// Lets the user choose camera or gallery before picking an image.
Future<AppImageSourceChoice?> showAppImageSourceSheet(
  BuildContext context, {
  String title = 'Add Photo',
  String subtitle = 'Choose how you want to add an image',
}) {
  return showAppBottomSheet<AppImageSourceChoice>(
    context: context,
    title: title,
    subtitle: subtitle,
    preset: AppBottomSheetPreset.compact,
    itemCount: 2,
    builder: (context, _) {
      final cs = Theme.of(context).colorScheme;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _SourceOptionTile(
            icon: Icons.photo_camera_outlined,
            iconColor: cs.primary,
            iconBackground: cs.primaryContainer.withValues(alpha: 0.55),
            title: 'Camera',
            subtitle: 'Take a new photo',
            onTap: () => Navigator.of(context).pop(AppImageSourceChoice.camera),
          ),
          const SizedBox(height: 10),
          _SourceOptionTile(
            icon: Icons.photo_library_outlined,
            iconColor: cs.tertiary,
            iconBackground: cs.tertiaryContainer.withValues(alpha: 0.55),
            title: 'Gallery',
            subtitle: 'Choose one or more photos',
            onTap: () => Navigator.of(context).pop(AppImageSourceChoice.gallery),
          ),
        ],
      );
    },
  );
}

class _SourceOptionTile extends StatelessWidget {
  const _SourceOptionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.62))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
