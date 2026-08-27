import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_address_listing.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_address_search_controller.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/utils/premise_form_focus.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_address_search_filter_sheet.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

/// Opens the legacy-style premise address catalog picker. Selected rows replace
/// the form's address list on Save (multi-select supported).
Future<void> showPremiseAddressSearchSheet(BuildContext context, {required PremiseFormSession session}) {
  final bodyKey = GlobalKey<_PremiseAddressSearchSheetBodyState>();

  return showAppBottomSheet<void>(
    context: context,
    title: 'Premise Address',
    subtitle: 'Select one or more addresses from the listing',
    preset: AppBottomSheetPreset.scrollable,
    isDismissible: false,
    bottomBar: AppBottomSheetActionBar(primaryLabel: 'Save', onPrimary: () => bodyKey.currentState?.save()),
    builder: (context, scrollController) {
      return _PremiseAddressSearchSheetBody(key: bodyKey, session: session, scrollController: scrollController);
    },
  ).unfocusPremiseFormOnComplete(context);
}

class _PremiseAddressSearchSheetBody extends ConsumerStatefulWidget {
  const _PremiseAddressSearchSheetBody({super.key, required this.session, this.scrollController});

  final PremiseFormSession session;
  final ScrollController? scrollController;

  @override
  ConsumerState<_PremiseAddressSearchSheetBody> createState() => _PremiseAddressSearchSheetBodyState();
}

class _PremiseAddressSearchSheetBodyState extends ConsumerState<_PremiseAddressSearchSheetBody> {
  late final TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _unitController = TextEditingController();
    widget.scrollController?.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeSearch());
  }

  void _initializeSearch() {
    final formState = ref.read(premiseFormControllerProvider(widget.session));
    final fields = ref.read(premiseFormFieldsProvider(widget.session));
    final companyAreaCode = lookupCodeFromDisplay(fields.area.text);
    final companyArea = companyAreaCode == null ? null : GeneralModel(code: companyAreaCode);

    ref
        .read(premiseAddressSearchControllerProvider.notifier)
        .initialize(
          initialAddresses: formState.addresses,
          companyArea: companyArea,
          companyStreet1: fields.street1.text.trim(),
          companyStreet2: fields.street2.text.trim(),
        );
  }

  void _onScroll() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      ref.read(premiseAddressSearchControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final applied = await showPremiseAddressSearchFilterSheet(context, ref);
    if (applied == true) {
      await ref.read(premiseAddressSearchControllerProvider.notifier).applyFilter();
    }
  }

  void save() {
    final search = ref.read(premiseAddressSearchControllerProvider);
    if (search.selected.isEmpty) {
      AppSnackbar.warning(context, 'Select at least one premise address.');
      return;
    }

    final existing = ref.read(premiseFormControllerProvider(widget.session)).addresses;
    final addresses = ref
        .read(premiseAddressSearchControllerProvider.notifier)
        .selectedAsDomain(existingAddresses: existing);

    ref.read(premiseFormControllerProvider(widget.session).notifier).setAddresses(addresses);
    AppSnackbar.success(context, '${addresses.length} address${addresses.length == 1 ? '' : 'es'} selected.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(premiseAddressSearchControllerProvider);
    final controller = ref.read(premiseAddressSearchControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppListView(
      controller: widget.scrollController,
      state: search.listState,
      itemCount: search.items.length + (search.isLoadingMore ? 1 : 0),
      padding: EdgeInsets.zero,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: .center,
            children: [
              Expanded(
                child: AppTextField(
                  hintText: 'Search Unit No.',
                  controller: _unitController,
                  onChanged: controller.setUnitQuery,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(tooltip: 'Advance filter', onPressed: _openFilter, icon: const Icon(Icons.filter_list)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
      footer: search.selected.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                '${search.selected.length} selected',
                style: textTheme.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
              ),
            )
          : null,
      itemBuilder: (context, index) {
        if (index >= search.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = search.items[index];
        return _AddressListingTile(
          item: item,
          selected: controller.isSelected(item),
          onChanged: (_) => controller.toggleSelection(item),
        );
      },
      empty: const AppListEmptyConfig(
        icon: Icons.location_on_outlined,
        title: 'No premise addresses found',
        subtitle: 'Try adjusting the filter or search unit number.',
      ),
      errorMessage: search.errorMessage,
      onRetry: controller.refresh,
    );
  }
}

class _AddressListingTile extends StatelessWidget {
  const _AddressListingTile({required this.item, required this.selected, required this.onChanged});

  final PremiseAddressListing item;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: CheckboxListTile(
          value: selected,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.trailing,
          title: Text(item.parliament ?? '-', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(item.unitNo ?? '-', style: textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                item.streetName ?? '-',
                style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
              ),
              if (item.postcode != null) ...[
                const SizedBox(height: 4),
                Text(item.postcode!, style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Legacy-style action sheet for an existing address row.
Future<void> showPremiseAddressActionSheet(
  BuildContext context, {
  required VoidCallback onPickLocation,
  required VoidCallback onSetAsCompanyAddress,
  required VoidCallback onDelete,
}) {
  return showAppBottomSheet<void>(
    context: context,
    preset: AppBottomSheetPreset.compact,
    title: 'Choose an Action',
    itemCount: 3,
    builder: (context, scrollController) {
      final cs = Theme.of(context).colorScheme;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.home_work_outlined),
            title: const Text('Set as Company Address'),
            onTap: () {
              Navigator.of(context).pop();
              onSetAsCompanyAddress();
            },
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Pick Location'),
            onTap: () {
              Navigator.of(context).pop();
              onPickLocation();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: cs.error),
            title: Text('Delete', style: TextStyle(color: cs.error)),
            onTap: () {
              Navigator.of(context).pop();
              onDelete();
            },
          ),
        ],
      );
    },
  );
}
