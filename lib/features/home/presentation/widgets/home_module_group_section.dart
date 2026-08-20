import 'package:flutter/material.dart';
import 'package:ilms/features/home/domain/entities/home_module_group.dart';
import 'package:ilms/features/home/domain/entities/home_module_item.dart';
import 'package:ilms/features/home/presentation/widgets/home_module_item_button.dart';

class HomeModuleGroupSection extends StatelessWidget {
  const HomeModuleGroupSection({
    super.key,
    required this.group,
    required this.onItemTap,
    this.columns = 3,
    this.gap = 12,
  });

  final HomeModuleGroup group;
  final void Function(HomeModuleItem item) onItemTap;
  final int columns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final items = group.items;

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: group.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(group.icon, size: 18, color: group.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                group.title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final item in items)
                  SizedBox(
                    width: width,
                    child: HomeModuleItemButton(
                      item: item,
                      accentColor: group.color,
                      onTap: () => onItemTap(item),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Divider(height: 32, color: cs.outlineVariant.withValues(alpha: 0.35)),
      ],
    );
  }
}
