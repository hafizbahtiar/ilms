import 'package:flutter/material.dart';
import 'package:ilms/features/premise/presentation/utils/premise_form_focus.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

enum PremiseFormMoreChoice { markVacant }

Future<PremiseFormMoreChoice?> showPremiseFormMoreSheet(BuildContext context) {
  return showAppBottomSheet<PremiseFormMoreChoice>(
    context: context,
    title: 'More Options',
    preset: AppBottomSheetPreset.compact,
    itemCount: 1,
    builder: (context, _) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _MoreOptionTile(
            icon: Icons.storefront_outlined,
            label: 'Vacant Premise',
            onTap: () => Navigator.of(context).pop(PremiseFormMoreChoice.markVacant),
          ),
        ],
      );
    },
  ).unfocusPremiseFormOnComplete(context);
}

class _MoreOptionTile extends StatelessWidget {
  const _MoreOptionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: cs.onSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
