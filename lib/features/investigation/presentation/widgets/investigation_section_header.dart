import 'package:flutter/material.dart';

class InvestigationSectionHeader extends StatelessWidget {
  const InvestigationSectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
