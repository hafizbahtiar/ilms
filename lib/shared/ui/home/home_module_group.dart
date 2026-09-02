import 'package:flutter/material.dart';
import 'package:ilms/shared/ui/home/home_module_grid.dart';

/// Grouped home module section — header, optional prefix content, button grid, divider.
class HomeModuleGroup extends StatelessWidget {
  const HomeModuleGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.buttons,
    this.prefix,
    this.maxColumns = 4,
    this.noIcon = true,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> buttons;
  final Widget? prefix;
  final int maxColumns;
  final bool noIcon;

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty && prefix == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (noIcon == false) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (prefix != null) ...[const SizedBox(height: 12), prefix!],
        if (buttons.isNotEmpty) ...[
          const SizedBox(height: 12),
          HomeModuleGrid(maxColumns: maxColumns, buttons: buttons),
        ],
        const SizedBox(height: 8),
        Divider(height: 32, color: cs.outlineVariant),
      ],
    );
  }
}
