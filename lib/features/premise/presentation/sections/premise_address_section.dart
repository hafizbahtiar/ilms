import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';

class PremiseAddressSection extends ConsumerWidget {
  const PremiseAddressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final fields = ref.watch(premiseFormFieldsProvider(session));
    final readOnly = ref.watch(premiseFormControllerProvider(session).select((s) => s.isReadOnly));
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: fields.addressFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Icon(Icons.location_on_outlined, size: 40, color: cs.primary.withValues(alpha: 0.7)),
                const SizedBox(height: 12),
                Text(
                  'No premise address added',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add at least one address before submitting.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          if (!readOnly) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => AppSnackbar.info(context, 'Address search coming soon.'),
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Add Address'),
            ),
          ],
        ],
      ),
    );
  }
}
