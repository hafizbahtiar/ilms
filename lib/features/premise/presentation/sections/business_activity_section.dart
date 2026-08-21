import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_business_activity_sheet.dart';

class BusinessActivitySection extends ConsumerWidget {
  const BusinessActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final readOnly = ref.watch(premiseFormControllerProvider(session).select((s) => s.isReadOnly));
    final activities = ref.watch(premiseFormControllerProvider(session).select((s) => s.businessActivities));
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (activities.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
            child: Text(
              'No business activities yet.',
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
            ),
          )
        else
          for (var i = 0; i < activities.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _BusinessActivityTile(
              activity: activities[i],
              onTap: readOnly
                  ? null
                  : () => showPremiseBusinessActivitySheet(context, session: session, index: i, initial: activities[i]),
            ),
          ],
        if (!readOnly) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showPremiseBusinessActivitySheet(context, session: session),
            icon: const Icon(Icons.store_outlined),
            label: const Text('Add Activity'),
          ),
        ],
      ],
    );
  }
}

class _BusinessActivityTile extends StatelessWidget {
  const _BusinessActivityTile({required this.activity, this.onTap});

  final PremiseBusinessActivity activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final description = activity.description?.trim();

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.store_outlined, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.businessTypeDesc ?? activity.businessType ?? '-',
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (activity.statusDesc != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        activity.statusDesc!,
                        style: textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.72)),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null) Icon(Icons.edit_outlined, color: cs.onSurface.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
