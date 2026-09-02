import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_address_search_controller.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

Future<bool?> showPremiseAddressSearchFilterSheet(BuildContext context, WidgetRef ref) {
  final snapshot = ref.read(premiseAddressSearchControllerProvider.notifier).snapshotFilter();

  return showAppBottomSheet<bool>(
    context: context,
    title: 'Advance Filter',
    subtitle: 'Narrow the premise address listing, then tap Apply.',
    preset: AppBottomSheetPreset.scrollable,
    isDismissible: false,
    itemCount: 4,
    trailing: IconButton(
      tooltip: 'Refresh lookups',
      onPressed: () async {
        await refreshAllGeneralLookups(ref);
        if (context.mounted) {
          AppSnackbar.success(context, 'Lookup data refreshed.');
        }
      },
      icon: const Icon(Icons.refresh_rounded),
    ),
    bottomBar: AppBottomSheetActionBar(
      onSecondary: () => ref.read(premiseAddressSearchControllerProvider.notifier).resetFilter(),
      onPrimary: () => Navigator.of(context).pop(true),
      secondaryLabel: 'Reset',
      primaryLabel: 'Apply',
    ),
    builder: (context, scrollController) {
      return _PremiseAddressSearchFilterBody(scrollController: scrollController);
    },
  ).then((applied) {
    if (applied != true) {
      ref.read(premiseAddressSearchControllerProvider.notifier).restoreFilter(snapshot);
    }
    return applied;
  });
}

class _PremiseAddressSearchFilterBody extends ConsumerWidget {
  const _PremiseAddressSearchFilterBody({this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(premiseAddressSearchControllerProvider.select((state) => state.filter));
    final controller = ref.read(premiseAddressSearchControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        _FilterSection(
          title: 'Parliament',
          value: generalLookupDisplay(filter.parliament),
          onClear: () => controller.setParliament(null),
          onTap: () => _pickParliament(context, ref, filter.parliament),
        ),
        _FilterSection(
          title: 'Area',
          value: generalLookupDisplay(filter.area),
          onClear: () => controller.setArea(null),
          onTap: () => _pickArea(context, ref, filter),
        ),
        _FilterSection(
          title: 'Street',
          value: generalLookupDisplay(filter.street),
          onClear: () => controller.setStreet(null),
          onTap: () => _pickStreet(context, ref, filter),
        ),
        _FilterSection(
          title: 'Building Name',
          value: generalLookupDisplay(filter.building),
          onClear: () => controller.setBuilding(null),
          onTap: () => _pickBuilding(context, ref, filter),
        ),
        const SizedBox(height: 8),
        Text(
          'Unit No. is searched from the main listing screen.',
          style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Future<void> _pickParliament(BuildContext context, WidgetRef ref, GeneralModel? selected) async {
    final options = await ref.read(generalParliamentsProvider(null).future);
    if (!context.mounted) return;
    final picked = await showAppOptionPicker<GeneralModel>(
      context: context,
      title: 'Parliament',
      options: options,
      label: generalLookupLabel,
      isSelected: (item) => item.code == selected?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) {
      ref.read(premiseAddressSearchControllerProvider.notifier).setParliament(picked);
    }
  }

  Future<void> _pickArea(BuildContext context, WidgetRef ref, PremiseAddressSearchFilterSelection filter) async {
    final parliament = filter.parliament;
    if (parliament?.code == null) {
      AppSnackbar.warning(context, 'Please select parliament first.');
      return;
    }
    final options = await ref.read(generalAreasByParliamentProvider(parliament!.code!).future);
    if (!context.mounted) return;
    final picked = await showAppOptionPicker<GeneralModel>(
      context: context,
      title: 'Area',
      options: options,
      label: generalLookupLabel,
      isSelected: (item) => item.code == filter.area?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) {
      ref.read(premiseAddressSearchControllerProvider.notifier).setArea(picked);
    }
  }

  Future<void> _pickStreet(BuildContext context, WidgetRef ref, PremiseAddressSearchFilterSelection filter) async {
    final area = filter.area;
    if (area?.code == null) {
      AppSnackbar.warning(context, 'Please select area first.');
      return;
    }
    final options = await ref.read(generalStreetsProvider(area!.code!).future);
    if (!context.mounted) return;
    final picked = await showAppOptionPicker<GeneralModel>(
      context: context,
      title: 'Street',
      options: options,
      label: generalLookupLabel,
      isSelected: (item) => item.code == filter.street?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) {
      ref.read(premiseAddressSearchControllerProvider.notifier).setStreet(picked);
    }
  }

  Future<void> _pickBuilding(BuildContext context, WidgetRef ref, PremiseAddressSearchFilterSelection filter) async {
    final street = filter.street;
    if (street?.code == null) {
      AppSnackbar.warning(context, 'Please select street first.');
      return;
    }
    final options = await ref.read(generalBuildingsProvider(street!.code!).future);
    if (!context.mounted) return;
    final picked = await showAppOptionPicker<GeneralModel>(
      context: context,
      title: 'Building Name',
      options: options,
      label: generalLookupLabel,
      isSelected: (item) => item.code == filter.building?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) {
      ref.read(premiseAddressSearchControllerProvider.notifier).setBuilding(picked);
    }
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.onTap, this.value, this.onClear});

  final String title;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (value != null && value!.isNotEmpty && onClear != null)
                TextButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
          const SizedBox(height: 6),
          Material(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Expanded(child: Text(value == null || value!.isEmpty ? 'Not selected' : value!)),
                    Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha: 0.35)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
