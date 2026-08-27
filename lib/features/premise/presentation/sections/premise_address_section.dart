import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/utils/premise_address_location.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_address_search_sheet.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/map/app_location_picker_page.dart';

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
                Text('No premise address added', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'Tap Add to pick addresses from the listing.',
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
              onTap: () => _handleAddressTap(
                context,
                ref,
                session: session,
                index: i,
                address: addresses[i],
                readOnly: readOnly,
              ),
            ),
          ],
        if (!readOnly) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showPremiseAddressSearchSheet(context, session: session),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ],
    );
  }

  Future<void> _handleAddressTap(
    BuildContext context,
    WidgetRef ref, {
    required PremiseFormSession session,
    required int index,
    required PremiseAddress address,
    required bool readOnly,
  }) async {
    if (readOnly) {
      await _viewAddressLocation(context, address);
      return;
    }

    await showPremiseAddressActionSheet(
      context,
      onSetAsCompanyAddress: () => _setAsCompanyAddress(context, ref, session: session, address: address),
      onPickLocation: () => _pickAddressLocation(context, ref, session: session, index: index, address: address),
      onDelete: () => _deleteAddress(context, ref, session: session, index: index),
    );
  }

  Future<void> _setAsCompanyAddress(
    BuildContext context,
    WidgetRef ref, {
    required PremiseFormSession session,
    required PremiseAddress address,
  }) async {
    await ref.read(premiseFormControllerProvider(session).notifier).applyCompanyAddressFromPremise(address);
    if (!context.mounted) return;
    AppSnackbar.success(context, 'Company address updated from this premise address.');
  }

  Future<void> _viewAddressLocation(BuildContext context, PremiseAddress address) async {
    final initial = latLngFromPremiseAddress(address);
    await AppLocationPickerPage.open(context, title: 'Premise Location', initialCenter: initial, viewOnly: true);
  }

  Future<void> _pickAddressLocation(
    BuildContext context,
    WidgetRef ref, {
    required PremiseFormSession session,
    required int index,
    required PremiseAddress address,
  }) async {
    final picked = await AppLocationPickerPage.open(
      context,
      title: 'Pick Premise Location',
      initialCenter: latLngFromPremiseAddress(address),
    );
    if (picked == null || !context.mounted) return;

    ref
        .read(premiseFormControllerProvider(session).notifier)
        .updateAddressAt(index, premiseAddressWithCoordinates(address, picked));
  }

  Future<void> _deleteAddress(
    BuildContext context,
    WidgetRef ref, {
    required PremiseFormSession session,
    required int index,
  }) async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Delete address?',
      message: 'This address will be removed from the form.',
      confirmLabel: 'Delete',
      confirmStyle: AppDialogActionStyle.destructive,
    );
    if (!confirmed || !context.mounted) return;

    ref.read(premiseFormControllerProvider(session).notifier).removeAddressAt(index);
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
    final hasLocation = premiseAddressHasLocation(address);

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
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: cs.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Premise Address',
                            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (hasLocation) ...[
                          Icon(Icons.check_circle, size: 16, color: cs.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            'Located',
                            style: textTheme.labelSmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(label: 'Unit', value: address.unitNo),
                    _DetailRow(label: 'Street', value: address.streetName),
                    _DetailRow(label: 'State', value: address.state),
                    if (address.postcode != null) _DetailRow(label: 'Postcode', value: address.postcode),
                    if (hasLocation) ...[
                      const SizedBox(height: 4),
                      Text(
                        formatPremiseCoordinates(address),
                        style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null) Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodySmall)),
          Expanded(
            child: Text(
              value == null || value!.isEmpty ? '-' : value!,
              textAlign: TextAlign.right,
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
