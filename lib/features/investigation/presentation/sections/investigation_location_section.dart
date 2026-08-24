import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_form_providers.dart';

/// Read-only — parliament/area are fixed by the case record (officers
/// cannot edit political/geographic classification from the app).
class InvestigationLocationSection extends ConsumerWidget {
  const InvestigationLocationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = InvestigationFormScope.of(context);
    final location = ref.watch(investigationFormControllerProvider(session).select((s) => s.location));
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Widget row(String label, String? value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 2),
            Text(
              (value == null || value.trim().isEmpty) ? '-' : value,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row('Parliament', location.parliamentDesc ?? location.parliamentCode),
        row('Area', location.areaDesc ?? location.areaCode),
      ],
    );
  }
}
