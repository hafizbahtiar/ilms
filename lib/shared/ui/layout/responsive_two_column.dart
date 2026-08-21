import 'package:flutter/material.dart';

/// Lays out [children] in two equal-width columns once the available width
/// reaches [breakpoint], or stacked in a single column below it.
class ResponsiveTwoColumn extends StatelessWidget {
  const ResponsiveTwoColumn({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing = 12,
    this.breakpoint = 600,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: spacing), children[i]],
            ],
          );
        }

        final columnWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [for (final child in children) SizedBox(width: columnWidth, child: child)],
        );
      },
    );
  }
}
