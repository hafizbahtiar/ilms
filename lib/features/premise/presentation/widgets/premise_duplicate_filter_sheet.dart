import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_duplicate_controller.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

Future<bool?> showPremiseDuplicateFilterSheet(BuildContext context, WidgetRef ref) {
  final snapshot = ref.read(premiseDuplicateControllerProvider.notifier).snapshotFilter();

  return showAppBottomSheet<bool>(
    context: context,
    title: 'All Filter',
    subtitle: 'Fill in the premise details or address criteria, then tap Apply.',
    preset: AppBottomSheetPreset.scrollable,
    isDismissible: false,
    enableDrag: true,
    itemCount: 9,
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
      onSecondary: () => ref.read(premiseDuplicateControllerProvider.notifier).resetFilter(),
      onPrimary: () => Navigator.of(context).pop(true),
      secondaryLabel: 'Reset',
      primaryLabel: 'Apply',
    ),
    builder: (context, scrollController) {
      return _PremiseDuplicateFilterBody(scrollController: scrollController);
    },
  ).then((applied) {
    if (applied != true) {
      ref.read(premiseDuplicateControllerProvider.notifier).restoreFilter(snapshot);
    }
    return applied;
  });
}

class _PremiseDuplicateFilterBody extends ConsumerStatefulWidget {
  const _PremiseDuplicateFilterBody({this.scrollController});

  final ScrollController? scrollController;

  @override
  ConsumerState<_PremiseDuplicateFilterBody> createState() => _PremiseDuplicateFilterBodyState();
}

class _PremiseDuplicateFilterBodyState extends ConsumerState<_PremiseDuplicateFilterBody> {
  late final TextEditingController _companyController;
  late final TextEditingController _traderController;
  late final TextEditingController _licenseNoController;
  late final TextEditingController _licenseFileController;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(premiseDuplicateControllerProvider).filter;
    _companyController = TextEditingController(text: filter.companyName);
    _traderController = TextEditingController(text: filter.traderName);
    _licenseNoController = TextEditingController(text: filter.licenseNo);
    _licenseFileController = TextEditingController(text: filter.licenseFileNo);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _traderController.dispose();
    _licenseNoController.dispose();
    _licenseFileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(premiseDuplicateControllerProvider.select((state) => state.filter));
    final controller = ref.read(premiseDuplicateControllerProvider.notifier);

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        AppTextField(label: 'Company Name', controller: _companyController, onChanged: controller.setCompanyName),
        const SizedBox(height: 12),
        AppTextField(label: 'Trader Name', controller: _traderController, onChanged: controller.setTraderName),
        const SizedBox(height: 12),
        AppTextField(label: 'License No.', controller: _licenseNoController, onChanged: controller.setLicenseNo),
        const SizedBox(height: 12),
        AppTextField(
          label: 'License File No.',
          controller: _licenseFileController,
          onChanged: controller.setLicenseFileNo,
        ),
        const SizedBox(height: 16),
        Text('Premise Address', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _FilterSection(
          title: 'Parliament',
          value: filter.parliament?.desc,
          onClear: () => controller.setParliament(null),
          onTap: () => _pickParliament(context, ref, filter.parliament),
        ),
        _FilterSection(
          title: 'Area',
          value: filter.area?.desc,
          onClear: () => controller.setArea(null),
          onTap: () => _pickArea(context, ref, filter),
        ),
        _FilterSection(
          title: 'Street',
          value: filter.street?.desc,
          onClear: () => controller.setStreet(null),
          onTap: () => _pickStreet(context, ref, filter),
        ),
        _FilterSection(
          title: 'Building Name',
          value: filter.building?.desc,
          onClear: () => controller.setBuilding(null),
          onTap: () => _pickBuilding(context, ref, filter),
        ),
        _FilterSection(
          title: 'Unit No.',
          value: filter.unitNo?.desc,
          onClear: () => controller.setUnitNo(null),
          onTap: () => _pickUnit(context, ref, filter),
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
      label: (item) => item.desc ?? item.code ?? '-',
      isSelected: (item) => item.code == selected?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) {
      ref.read(premiseDuplicateControllerProvider.notifier).setParliament(picked);
    }
  }

  Future<void> _pickArea(BuildContext context, WidgetRef ref, PremiseDuplicateFilterSelection filter) async {
    final parliament = filter.parliament;
    if (parliament?.code == null) {
      AppSnackbar.warning(context, 'Please select parliament');
      return;
    }
    final options = await ref.read(generalAreasByParliamentProvider(parliament!.code!).future);
    if (!context.mounted) return;
    final picked = await showAppOptionPicker<GeneralModel>(
      context: context,
      title: 'Area',
      options: options,
      label: (item) => item.desc ?? item.code ?? '-',
      isSelected: (item) => item.code == filter.area?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) {
      ref.read(premiseDuplicateControllerProvider.notifier).setArea(picked);
    }
  }

  Future<void> _pickStreet(BuildContext context, WidgetRef ref, PremiseDuplicateFilterSelection filter) async {
    final area = filter.area;
    if (area?.code == null) {
      AppSnackbar.warning(context, 'Please select area');
      return;
    }
    final options = await ref.read(generalStreetsProvider(area!.code!).future);
    if (!context.mounted) return;
    final picked = await showAppOptionPicker<GeneralModel>(
      context: context,
      title: 'Street',
      options: options,
      label: (item) => item.desc ?? item.code ?? '-',
      isSelected: (item) => item.code == filter.street?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) {
      ref.read(premiseDuplicateControllerProvider.notifier).setStreet(picked);
    }
  }

  Future<void> _pickBuilding(BuildContext context, WidgetRef ref, PremiseDuplicateFilterSelection filter) async {
    final street = filter.street;
    if (street?.code == null) {
      AppSnackbar.warning(context, 'Please select street');
      return;
    }
    final options = await ref.read(generalBuildingsProvider(street!.code!).future);
    if (!context.mounted) return;
    final picked = await showAppOptionPicker<GeneralModel>(
      context: context,
      title: 'Building Name',
      options: options,
      label: (item) => item.desc ?? item.code ?? '-',
      isSelected: (item) => item.code == filter.building?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) {
      ref.read(premiseDuplicateControllerProvider.notifier).setBuilding(picked);
    }
  }

  Future<void> _pickUnit(BuildContext context, WidgetRef ref, PremiseDuplicateFilterSelection filter) async {
    final building = filter.building;
    final street = filter.street;
    if (building?.code == null && street?.code == null) {
      AppSnackbar.warning(context, 'Please select building or street');
      return;
    }
    final options = await ref.read(
      generalUnitsProvider(GeneralUnitFilter(buildingCode: building?.code, streetCode: street?.code)).future,
    );
    if (!context.mounted) return;
    final picked = await showAppOptionPicker<GeneralModel>(
      context: context,
      title: 'Unit No.',
      options: options,
      label: (item) => item.desc ?? item.code ?? '-',
      isSelected: (item) => item.code == filter.unitNo?.code,
      preset: AppBottomSheetPreset.compact,
    );
    if (picked != null) {
      ref.read(premiseDuplicateControllerProvider.notifier).setUnitNo(picked);
    }
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.onTap, required this.onClear, this.value});

  final String title;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasValue = value != null && value!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (hasValue) TextButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
          Material(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.home_outlined, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hasValue ? value! : 'Not Selected',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                          color: cs.onSurface.withValues(alpha: hasValue ? 0.92 : 0.55),
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.35)),
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
