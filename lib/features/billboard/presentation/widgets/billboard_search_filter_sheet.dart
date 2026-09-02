import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/presentation/controllers/billboard_list_controller.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_providers.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

Future<bool?> showBillboardSearchFilterSheet(BuildContext context, WidgetRef ref) {
  final controller = ref.read(billboardListControllerProvider.notifier);
  final snapshot = controller.snapshotFilter();

  return showAppBottomSheet<bool>(
    context: context,
    title: 'All Filter',
    subtitle: 'Narrow results by type, date, owner, or address.',
    preset: AppBottomSheetPreset.scrollable,
    isDismissible: false,
    enableDrag: true,
    bottomBar: AppBottomSheetActionBar(
      onSecondary: controller.resetFilter,
      onPrimary: () => Navigator.of(context).pop(true),
      secondaryLabel: 'Reset',
      primaryLabel: 'Apply',
    ),
    builder: (context, scrollController) => _BillboardSearchFilterBody(scrollController: scrollController),
  ).then((applied) {
    if (applied != true) {
      controller.restoreFilter(snapshot);
    }
    return applied;
  });
}

class _BillboardSearchFilterBody extends ConsumerStatefulWidget {
  const _BillboardSearchFilterBody({this.scrollController});

  final ScrollController? scrollController;

  @override
  ConsumerState<_BillboardSearchFilterBody> createState() => _BillboardSearchFilterBodyState();
}

class _BillboardSearchFilterBodyState extends ConsumerState<_BillboardSearchFilterBody> {
  late final TextEditingController _mediaOwnerController;
  late final TextEditingController _mediaOwnerClientController;
  late final TextEditingController _streetController;
  late final TextEditingController _dateRangeController;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(billboardListControllerProvider).filter;
    _mediaOwnerController = TextEditingController(text: filter.mediaOwner);
    _mediaOwnerClientController = TextEditingController(text: filter.mediaOwnerClient);
    _streetController = TextEditingController(text: filter.street);
    _dateRangeController = TextEditingController(text: filter.dateRangeLabel);
  }

  @override
  void dispose() {
    _mediaOwnerController.dispose();
    _mediaOwnerClientController.dispose();
    _streetController.dispose();
    _dateRangeController.dispose();
    super.dispose();
  }

  BillboardListController get _controller => ref.read(billboardListControllerProvider.notifier);

  Future<void> _pickDateRange() async {
    final filter = ref.read(billboardListControllerProvider).filter;
    final current = filter.dateRange ?? BillboardSearchFilterSelection.defaultDateRange();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: current,
    );
    if (picked == null) return;
    _controller.setDateRange(picked);
    _dateRangeController.text = ref.read(billboardListControllerProvider).filter.dateRangeLabel;
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(billboardListControllerProvider.select((state) => state.filter));

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
          hintText: 'All dates',
          suffixIcon: Icons.calendar_month_outlined,
          onTap: _pickDateRange,
        ),
        const SizedBox(height: 12),
        _LookupFilterRow(
          title: 'Billboard Type',
          value: generalLookupDisplay(filter.billType),
          onClear: () => _controller.setBillType(null),
          onTap: () => _pickBillType(filter.billType),
        ),
        _LookupFilterRow(
          title: 'LED Board',
          value: generalLookupDisplay(filter.ledBoard),
          onClear: () => _controller.setLedBoard(null),
          onTap: () => _pickYesNo(filter.ledBoard, onPicked: _controller.setLedBoard),
        ),
        AppTextField(label: 'Media Owner', controller: _mediaOwnerController, onChanged: _controller.setMediaOwner),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Media Owner Client',
          controller: _mediaOwnerClientController,
          onChanged: _controller.setMediaOwnerClient,
        ),
        const SizedBox(height: 12),
        AppTextField(label: 'Street', controller: _streetController, onChanged: _controller.setStreet),
        const SizedBox(height: 12),
        _LookupFilterRow(
          title: 'Parliament',
          value: generalLookupDisplay(filter.parliament),
          onClear: () => _controller.setParliament(null),
          onTap: () => _pickParliament(filter.parliament),
        ),
        _LookupFilterRow(
          title: 'Phase',
          value: generalLookupDisplay(filter.phase),
          onClear: () => _controller.setPhase(null),
          onTap: () => _pickPhase(filter.phase),
        ),
        _LookupFilterRow(
          title: 'Asset Owner',
          value: generalLookupDisplay(filter.assetOwner),
          onClear: () => _controller.setAssetOwner(null),
          onTap: () => _pickAssetOwner(filter.assetOwner),
        ),
      ],
    );
  }

  Future<void> _pickBillType(GeneralModel? selected) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Billboard Type',
      loadOptions: () => ref.read(billboardTypesProvider.future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == selected?.code,
      searchable: true,
    );
    if (picked != null) _controller.setBillType(picked);
  }

  Future<void> _pickYesNo(GeneralModel? selected, {required ValueChanged<GeneralModel?> onPicked}) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'LED Board',
      loadOptions: () => ref.read(generalYesNoProvider.future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == selected?.code,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickParliament(GeneralModel? selected) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Parliament',
      loadOptions: () => ref.read(billboardParliamentsProvider(null).future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == selected?.code,
      searchable: true,
    );
    if (picked != null) _controller.setParliament(picked);
  }

  Future<void> _pickPhase(GeneralModel? selected) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Phase',
      loadOptions: () => ref.read(billboardPhasesProvider.future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == selected?.code,
      searchable: true,
    );
    if (picked != null) _controller.setPhase(picked);
  }

  Future<void> _pickAssetOwner(GeneralModel? selected) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Asset Owner',
      loadOptions: () => ref.read(billboardAssetOwnersProvider.future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == selected?.code,
      searchable: true,
    );
    if (picked != null) _controller.setAssetOwner(picked);
  }
}

class _LookupFilterRow extends StatelessWidget {
  const _LookupFilterRow({required this.title, required this.onTap, required this.onClear, this.value});

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
