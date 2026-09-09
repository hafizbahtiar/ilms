import 'package:flutter/material.dart';

/// Resets a rotated Google map back to north-up.
class AppMapRotationResetButton extends StatelessWidget {
  const AppMapRotationResetButton({super.key, required this.isRotated, required this.onReset});

  final bool isRotated;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    if (!isRotated) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: 'Reset rotation',
        onPressed: onReset,
        icon: Icon(Icons.explore_rounded, color: cs.primary),
      ),
    );
  }
}
