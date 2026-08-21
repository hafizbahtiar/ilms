import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_address_sheet.dart';

class PremiseAddressSection extends ConsumerWidget {
  const PremiseAddressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final readOnly = ref.watch(premiseFormControllerProvider(session).select((s) => s.isReadOnly));
    final addresses = ref.watch(premiseFormControllerProvider(session).select((s) => s.addresses));
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (addresses.isEmpty)
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
                  'No premise address added yet.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < addresses.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _AddressTile(
              address: addresses[i],
              onTap: readOnly
                  ? null
                  : () => showPremiseAddressSheet(context, session: session, index: i, initial: addresses[i]),
            ),
          ],
        if (!readOnly) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showPremiseAddressSheet(context, session: session),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add Address'),
          ),
        ],
      ],
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address, this.onTap});

  final PremiseAddress address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final line = [
      address.unitNo,
      address.building,
      address.streetName,
    ].where((v) => v != null && v.isNotEmpty).join(', ');

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
              Icon(Icons.location_on_outlined, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.isEmpty ? '-' : line,
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (address.postcode != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        address.postcode!,
                        style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
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
