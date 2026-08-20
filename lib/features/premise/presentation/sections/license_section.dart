import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';

class LicenseSection extends ConsumerWidget {
  const LicenseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = PremiseFormScope.of(context);
    final readOnly = ref.watch(premiseFormControllerProvider(mode).select((s) => s.isReadOnly));
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'No license records yet.',
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
          ),
        ),
        if (!readOnly) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => AppSnackbar.info(context, 'License form coming soon.'),
            icon: const Icon(Icons.badge_outlined),
            label: const Text('Add License'),
          ),
        ],
      ],
    );
  }
}
