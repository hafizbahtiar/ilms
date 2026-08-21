import 'package:flutter/material.dart';

/// Pinned bottom action row for filter / form sheets (legacy `BottomActionBar`).
class AppBottomSheetActionBar extends StatelessWidget {
  const AppBottomSheetActionBar({
    super.key,
    required this.onPrimary,
    this.onSecondary,
    this.primaryLabel = 'Apply',
    this.secondaryLabel = 'Reset',
    this.showSecondary = true,
    this.primaryEnabled = true,
    this.secondaryEnabled = true,
    this.secondaryDestructive = false,
  });

  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final String secondaryLabel;
  final bool showSecondary;
  final bool primaryEnabled;
  final bool secondaryEnabled;

  /// Colors the secondary button as a destructive action (e.g. "Delete")
  /// instead of the default neutral "Reset" styling.
  final bool secondaryDestructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.55))),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Row(
            children: [
              if (showSecondary && onSecondary != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: secondaryEnabled ? onSecondary : null,
                    style: secondaryDestructive
                        ? OutlinedButton.styleFrom(
                            foregroundColor: cs.error,
                            side: BorderSide(color: cs.error.withValues(alpha: 0.55)),
                          )
                        : null,
                    child: Text(secondaryLabel),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(onPressed: primaryEnabled ? onPrimary : null, child: Text(primaryLabel)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
