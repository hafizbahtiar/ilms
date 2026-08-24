import 'package:flutter/material.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_form_sections.dart';

class BillboardFormTabBar extends StatelessWidget {
  const BillboardFormTabBar({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
    required this.tabKeys,
    this.tabScrollController,
  });

  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final List<GlobalKey> tabKeys;
  final ScrollController? tabScrollController;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
        ),
        child: SingleChildScrollView(
          controller: tabScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              for (var i = 0; i < billboardFormSections.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                _TabChip(
                  key: tabKeys[i],
                  label: billboardFormSections[i].tabLabel,
                  selected: i == activeIndex,
                  onTap: () => onTabSelected(i),
                  textTheme: textTheme,
                  colorScheme: cs,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerLow;
    final fg = selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface.withValues(alpha: 0.75);
    final labelStyle = textTheme.labelLarge!.copyWith(
      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      color: fg,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              style: labelStyle,
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
