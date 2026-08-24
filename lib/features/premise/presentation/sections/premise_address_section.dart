import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/utils/premise_address_location.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_address_sheet.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/map/app_location_picker_page.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

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
            onPressed: () => showPremiseAddressSheet(context, session: session),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add Address'),
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

    final action = await showAppBottomSheet<_AddressAction>(
      context: context,
      preset: AppBottomSheetPreset.compact,
      title: 'Premise Address',
      subtitle: 'Choose an action for this address',
      itemCount: 3,
      builder: (context, scrollController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Address'),
              onTap: () => Navigator.of(context).pop(_AddressAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Pick Location on Map'),
              onTap: () => Navigator.of(context).pop(_AddressAction.pickLocation),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () => Navigator.of(context).pop(_AddressAction.delete),
            ),
          ],
        );
      },
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case _AddressAction.edit:
        await showPremiseAddressSheet(context, session: session, index: index, initial: address);
      case _AddressAction.pickLocation:
        await _pickAddressLocation(context, ref, session: session, index: index, address: address);
      case _AddressAction.delete:
        await _deleteAddress(context, ref, session: session, index: index);
    }
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

enum _AddressAction { edit, pickLocation, delete }

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address, this.onTap});

  final PremiseAddress address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasLocation = premiseAddressHasLocation(address);

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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            line.isEmpty ? '-' : line,
                            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
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
                    if (address.postcode != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        address.postcode!,
                        style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
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
