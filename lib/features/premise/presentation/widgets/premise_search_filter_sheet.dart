import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_list_controller.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

Future<bool?> showPremiseSearchFilterSheet(BuildContext context, WidgetRef ref, PremiseListTab tab) {
  final snapshot = ref.read(premiseSearchControllerProvider(tab).notifier).snapshotFilter();

  return showAppBottomSheet<bool>(
    context: context,
    title: 'All Filter',
    subtitle: 'Narrow results by date, phase, company, license, or address.',
    preset: AppBottomSheetPreset.scrollable,
    isDismissible: false,
    enableDrag: true,
    trailing: IconButton(
      tooltip: 'Refresh lookups',
      onPressed: () async {
        await refreshAllGeneralLookups(ref);
        if (context.mounted) AppSnackbar.success(context, 'Lookup data refreshed.');
      },
      icon: const Icon(Icons.refresh_rounded),
    ),
    bottomBar: AppBottomSheetActionBar(
      onSecondary: () => ref.read(premiseSearchControllerProvider(tab).notifier).resetFilter(),
      onPrimary: () => Navigator.of(context).pop(true),
      secondaryLabel: 'Reset',
      primaryLabel: 'Apply',
    ),
    builder: (context, scrollController) {
      return _PremiseSearchFilterBody(tab: tab, scrollController: scrollController);
    },
  ).then((applied) {
    if (applied != true) {
      ref.read(premiseSearchControllerProvider(tab).notifier).restoreFilter(snapshot);
    }
    return applied;
  });
}

class _PremiseSearchFilterBody extends ConsumerStatefulWidget {
  const _PremiseSearchFilterBody({required this.tab, this.scrollController});

  final PremiseListTab tab;
  final ScrollController? scrollController;

  @override
  ConsumerState<_PremiseSearchFilterBody> createState() => _PremiseSearchFilterBodyState();
}

class _PremiseSearchFilterBodyState extends ConsumerState<_PremiseSearchFilterBody> {
  late final TextEditingController _companyController;
  late final TextEditingController _traderController;
  late final TextEditingController _licenseNoController;
  late final TextEditingController _licenseFileController;
  late final TextEditingController _dateRangeController;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(premiseSearchControllerProvider(widget.tab)).filter;
    _companyController = TextEditingController(text: filter.companyName);
    _traderController = TextEditingController(text: filter.traderName);
    _licenseNoController = TextEditingController(text: filter.licenseNo);
    _licenseFileController = TextEditingController(text: filter.licenseFileNo);
    _dateRangeController = TextEditingController(text: filter.dateRangeLabel);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _traderController.dispose();
    _licenseNoController.dispose();
    _licenseFileController.dispose();
    _dateRangeController.dispose();
    super.dispose();
  }

  PremiseListController get _controller => ref.read(premiseSearchControllerProvider(widget.tab).notifier);

  Future<void> _pickDateRange() async {
    final filter = ref.read(premiseSearchControllerProvider(widget.tab)).filter;
    final current = filter.dateRange ?? PremiseSearchFilterSelection.defaultDateRange();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: current,
    );
    if (picked == null) return;
    _controller.setDateRange(picked);
    _dateRangeController.text = ref.read(premiseSearchControllerProvider(widget.tab)).filter.dateRangeLabel;
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(premiseSearchControllerProvider(widget.tab).select((state) => state.filter));

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        Text('Advance Search', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Date Range',
          controller: _dateRangeController,
          readOnly: true,
          suffixIcon: Icons.calendar_month_outlined,
          onTap: _pickDateRange,
        ),
        const SizedBox(height: 12),
        _LookupFilterSection(
          title: 'Phase',
          value: generalLookupDisplay(filter.phase),
          onClear: () => _controller.setPhase(null),
          onTap: () => _pickPhase(context, filter.phase),
        ),
        AppTextField(label: 'Company Name', controller: _companyController, onChanged: _controller.setCompanyName),
        const SizedBox(height: 12),
        AppTextField(label: 'Trade Name', controller: _traderController, onChanged: _controller.setTraderName),
        const SizedBox(height: 12),
        AppTextField(label: 'License No.', controller: _licenseNoController, onChanged: _controller.setLicenseNo),
        const SizedBox(height: 12),
        AppTextField(
          label: 'License File No.',
          controller: _licenseFileController,
          onChanged: _controller.setLicenseFileNo,
        ),
        const SizedBox(height: 16),
        Text('Premise Address', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _LookupFilterSection(
          title: 'Parliament',
          value: generalLookupDisplay(filter.parliament),
          onClear: () => _controller.setParliament(null),
          onTap: () => _pickParliament(context, filter.parliament),
        ),
        _LookupFilterSection(
          title: 'Area',
          value: generalLookupDisplay(filter.area),
          onClear: () => _controller.setArea(null),
          onTap: () => _pickArea(context, filter),
        ),
        _LookupFilterSection(
          title: 'Street',
          value: generalLookupDisplay(filter.street),
          onClear: () => _controller.setStreet(null),
          onTap: () => _pickStreet(context, filter),
        ),
        _LookupFilterSection(
          title: 'Building Name',
          value: generalLookupDisplay(filter.building),
          onClear: () => _controller.setBuilding(null),
          onTap: () => _pickBuilding(context, filter),
        ),
        _LookupFilterSection(
          title: 'Unit No.',
          value: generalLookupDisplay(filter.unitNo),
          onClear: () => _controller.setUnitNo(null),
          onTap: () => _pickUnit(context, filter),
        ),
      ],
    );
  }

  Future<void> _pickPhase(BuildContext context, GeneralModel? selected) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Phase',
      loadOptions: () => ref.read(premisePhasesProvider.future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == selected?.code,
      preset: AppBottomSheetPreset.scrollable,
    );
    if (picked != null) _controller.setPhase(picked);
  }

  Future<void> _pickParliament(BuildContext context, GeneralModel? selected) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Parliament',
      loadOptions: () => ref.read(generalParliamentsProvider(null).future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == selected?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) _controller.setParliament(picked);
  }

  Future<void> _pickArea(BuildContext context, PremiseSearchFilterSelection filter) async {
    final parliamentCode = filter.parliament?.code;
    if (parliamentCode == null) {
      AppSnackbar.warning(context, 'Please select parliament first.');
      return;
    }
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Area',
      loadOptions: () => ref.read(generalAreasByParliamentProvider(parliamentCode).future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == filter.area?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) _controller.setArea(picked);
  }

  Future<void> _pickStreet(BuildContext context, PremiseSearchFilterSelection filter) async {
    final areaCode = filter.area?.code;
    if (areaCode == null) {
      AppSnackbar.warning(context, 'Please select area first.');
      return;
    }
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Street',
      loadOptions: () => ref.read(generalStreetsProvider(areaCode).future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == filter.street?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) _controller.setStreet(picked);
  }

  Future<void> _pickBuilding(BuildContext context, PremiseSearchFilterSelection filter) async {
    final streetCode = filter.street?.code;
    if (streetCode == null) {
      AppSnackbar.warning(context, 'Please select street first.');
      return;
    }
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Building Name',
      loadOptions: () => ref.read(generalBuildingsProvider(streetCode).future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == filter.building?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
    );
    if (picked != null) _controller.setBuilding(picked);
  }

  Future<void> _pickUnit(BuildContext context, PremiseSearchFilterSelection filter) async {
    if (filter.building?.code == null && filter.street?.code == null) {
      AppSnackbar.warning(context, 'Please select building or street first.');
      return;
    }
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Unit No.',
      loadOptions: () => ref.read(
        generalUnitsProvider(GeneralUnitFilter(buildingCode: filter.building?.code, streetCode: filter.street?.code))
            .future,
      ),
      label: generalLookupLabel,
      isSelected: (item) => item.code == filter.unitNo?.code,
      preset: AppBottomSheetPreset.scrollable,
      searchable: true,
      empty: const AppListEmptyConfig(
        icon: Icons.search_off_outlined,
        title: 'No Unit No. found',
        subtitle: 'Nothing matches the current street or building. Try a different selection above.',
      ),
    );
    if (picked != null) _controller.setUnitNo(picked);
  }
}

class _LookupFilterSection extends StatelessWidget {
  const _LookupFilterSection({required this.title, required this.onTap, required this.onClear, this.value});

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
                    Icon(Icons.tune_rounded, color: cs.primary),
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
