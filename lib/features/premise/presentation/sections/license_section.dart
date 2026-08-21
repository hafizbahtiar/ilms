import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_license_sheet.dart';

class LicenseSection extends ConsumerWidget {
  const LicenseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final readOnly = ref.watch(premiseFormControllerProvider(session).select((s) => s.isReadOnly));
    final licenses = ref.watch(premiseFormControllerProvider(session).select((s) => s.licenses));
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (licenses.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
            child: Text(
              'No license records yet.',
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
            ),
          )
        else
          for (var i = 0; i < licenses.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _LicenseTile(
              license: licenses[i],
              onTap: readOnly
                  ? null
                  : () => showPremiseLicenseSheet(context, session: session, index: i, initial: licenses[i]),
            ),
          ],
        if (!readOnly) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showPremiseLicenseSheet(context, session: session),
            icon: const Icon(Icons.badge_outlined),
            label: const Text('Add License'),
          ),
        ],
      ],
    );
  }
}

class _LicenseTile extends StatelessWidget {
  const _LicenseTile({required this.license, this.onTap});

  final PremiseLicense license;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final validFrom = license.validFrom;
    final validTo = license.validTo;
    final hasPeriod = (validFrom?.isNotEmpty ?? false) || (validTo?.isNotEmpty ?? false);

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
              Icon(Icons.badge_outlined, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      license.licenseNo ?? '-',
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      license.licenseFileNo ?? '-',
                      style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.72)),
                    ),
                    if (license.statusDesc != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        license.statusDesc!,
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (hasPeriod) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${validFrom ?? '-'} — ${validTo ?? '-'}',
                        style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${license.businessActivities.length} business activity(s)  •  '
                      'Total: RM ${license.totalAmount.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
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
