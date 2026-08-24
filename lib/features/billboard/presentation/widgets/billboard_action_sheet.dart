import 'package:flutter/material.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

enum BillboardAction { view, update }

/// Tile tap action sheet — View or Update an existing billboard record.
Future<BillboardAction?> showBillboardActionSheet(BuildContext context) {
  return showAppBottomSheet<BillboardAction>(
    context: context,
    title: 'Billboard Record',
    subtitle: 'Choose an action for this record.',
    preset: AppBottomSheetPreset.compact,
    itemCount: 2,
    builder: (context, _) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.visibility_outlined,
            title: 'View',
            subtitle: 'Open this record in read-only mode',
            onTap: () => Navigator.of(context).pop(BillboardAction.view),
          ),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.edit_outlined,
            title: 'Update',
            subtitle: 'Edit this record',
            onTap: () => Navigator.of(context).pop(BillboardAction.update),
          ),
        ],
      );
    },
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
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
