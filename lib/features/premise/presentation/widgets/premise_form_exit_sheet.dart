import 'package:flutter/material.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

enum PremiseFormExitChoice { saveAndExit, deleteDraft, exitWithoutSaving }

Future<PremiseFormExitChoice?> showPremiseFormExitSheet(BuildContext context, {required bool showDeleteDraft}) {
  final itemCount = showDeleteDraft ? 3 : 2;

  return showAppBottomSheet<PremiseFormExitChoice>(
    context: context,
    title: 'Leave this form?',
    subtitle: 'You have unsaved changes. What would you like to do?',
    preset: AppBottomSheetPreset.compact,
    itemCount: itemCount,
    builder: (context, _) {
      final cs = Theme.of(context).colorScheme;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _ExitActionTile(
            icon: Icons.save_outlined,
            label: 'Save & exit',
            onTap: () => Navigator.of(context).pop(PremiseFormExitChoice.saveAndExit),
          ),
          if (showDeleteDraft) ...[
            const SizedBox(height: 8),
            _ExitActionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete draft',
              foregroundColor: cs.error,
              onTap: () => Navigator.of(context).pop(PremiseFormExitChoice.deleteDraft),
            ),
          ],
          const SizedBox(height: 8),
          _ExitActionTile(
            icon: Icons.logout_rounded,
            label: 'Exit without saving',
            onTap: () => Navigator.of(context).pop(PremiseFormExitChoice.exitWithoutSaving),
          ),
        ],
      );
    },
  );
}

class _ExitActionTile extends StatelessWidget {
  const _ExitActionTile({required this.icon, required this.label, required this.onTap, this.foregroundColor});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = foregroundColor ?? cs.onSurface;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
