import 'package:flutter/material.dart';

/// Wrap grid for home module shortcuts — up to [maxColumns] buttons per row.
class HomeModuleGrid extends StatelessWidget {
  const HomeModuleGrid({
    super.key,
    required this.buttons,
    this.maxColumns = 4,
    this.gap = 12,
  });

  final List<Widget> buttons;
  final int maxColumns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = maxColumns.clamp(1, 4);
        final tileWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final button in buttons) SizedBox(width: tileWidth, child: button)],
        );
      },
    );
  }
}
