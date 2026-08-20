import 'package:flutter/material.dart';
import 'package:ilms/shared/constants/home_modules.dart';

/// Summary header card on module list pages.
class HomeModuleSummaryCard extends StatelessWidget {
  const HomeModuleSummaryCard({
    super.key,
    required this.module,
    required this.total,
    required this.verified,
  });

  final HomeModule module;
  final int total;
  final int verified;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [module.color.withValues(alpha: 0.16), module.color.withValues(alpha: 0.06)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: module.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: module.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(module.icon, size: 26, color: module.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  '$total records • $verified verified',
                  style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
