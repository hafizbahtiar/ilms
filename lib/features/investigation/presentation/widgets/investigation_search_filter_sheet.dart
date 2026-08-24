import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_search_filter.dart';
import 'package:ilms/features/investigation/presentation/controllers/investigation_list_controller.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

Future<bool?> showInvestigationSearchFilterSheet(BuildContext context, WidgetRef ref) {
  final controller = ref.read(investigationListControllerProvider(InvestigationListMode.search).notifier);
  final snapshot = controller.snapshotFilter();

  return showAppBottomSheet<bool>(
    context: context,
    title: 'All Filter',
    subtitle: 'Narrow results by investigation, applicant, or officer.',
    preset: AppBottomSheetPreset.scrollable,
    isDismissible: false,
    enableDrag: true,
    bottomBar: AppBottomSheetActionBar(
      onSecondary: controller.resetFilter,
      onPrimary: () => Navigator.of(context).pop(true),
      secondaryLabel: 'Reset',
      primaryLabel: 'Apply',
    ),
    builder: (context, scrollController) => _InvestigationSearchFilterBody(scrollController: scrollController),
  ).then((applied) {
    if (applied != true) {
      controller.restoreFilter(snapshot);
    }
    return applied;
  });
}

class _InvestigationSearchFilterBody extends ConsumerStatefulWidget {
  const _InvestigationSearchFilterBody({this.scrollController});

  final ScrollController? scrollController;

  @override
  ConsumerState<_InvestigationSearchFilterBody> createState() => _InvestigationSearchFilterBodyState();
}

class _InvestigationSearchFilterBodyState extends ConsumerState<_InvestigationSearchFilterBody> {
  late final Map<String, TextEditingController> _controllers;

  InvestigationSearchFilter get _filter =>
      ref.read(investigationListControllerProvider(InvestigationListMode.search)).filter;

  InvestigationListController get _controller =>
      ref.read(investigationListControllerProvider(InvestigationListMode.search).notifier);

  @override
  void initState() {
    super.initState();
    final filter = _filter;
    _controllers = {
      'investigationNo': TextEditingController(text: filter.investigationNo),
      'licenseNo': TextEditingController(text: filter.licenseNo),
      'identificationNo': TextEditingController(text: filter.identificationNo),
      'companyName': TextEditingController(text: filter.companyName),
      'registrationNo': TextEditingController(text: filter.registrationNo),
      'parliamentCode': TextEditingController(text: filter.parliamentCode),
      'areaCode': TextEditingController(text: filter.areaCode),
      'statusCode': TextEditingController(text: filter.statusCode),
      'officerName': TextEditingController(text: filter.officerName),
      'dateReceived': TextEditingController(text: filter.dateReceived),
      'investigationStartDateFrom': TextEditingController(text: filter.investigationStartDateFrom),
      'investigationStartDateTo': TextEditingController(text: filter.investigationStartDateTo),
      'businessTypeCode': TextEditingController(text: filter.businessTypeCode),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _apply(InvestigationSearchFilter Function(InvestigationSearchFilter) update) {
    _controller.setFilter(update(_filter));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        AppTextField(
          label: 'Investigation No.',
          controller: _controllers['investigationNo'],
          onChanged: (v) => _apply((f) => f.copyWith(investigationNo: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'License No.',
          controller: _controllers['licenseNo'],
          onChanged: (v) => _apply((f) => f.copyWith(licenseNo: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Identification No.',
          controller: _controllers['identificationNo'],
          onChanged: (v) => _apply((f) => f.copyWith(identificationNo: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Company Name',
          controller: _controllers['companyName'],
          onChanged: (v) => _apply((f) => f.copyWith(companyName: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Registration No.',
          controller: _controllers['registrationNo'],
          onChanged: (v) => _apply((f) => f.copyWith(registrationNo: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Parliament Code',
          controller: _controllers['parliamentCode'],
          onChanged: (v) => _apply((f) => f.copyWith(parliamentCode: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Area Code',
          controller: _controllers['areaCode'],
          onChanged: (v) => _apply((f) => f.copyWith(areaCode: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Status',
          controller: _controllers['statusCode'],
          onChanged: (v) => _apply((f) => f.copyWith(statusCode: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Officer Name',
          controller: _controllers['officerName'],
          onChanged: (v) => _apply((f) => f.copyWith(officerName: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Date Received',
          controller: _controllers['dateReceived'],
          readOnly: true,
          suffixIcon: Icons.calendar_month_outlined,
          onTap: () => _pickDate(_controllers['dateReceived']!, (v) => _apply((f) => f.copyWith(dateReceived: v))),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Start Date From',
                controller: _controllers['investigationStartDateFrom'],
                readOnly: true,
                suffixIcon: Icons.calendar_month_outlined,
                onTap: () => _pickDate(
                  _controllers['investigationStartDateFrom']!,
                  (v) => _apply((f) => f.copyWith(investigationStartDateFrom: v)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Start Date To',
                controller: _controllers['investigationStartDateTo'],
                readOnly: true,
                suffixIcon: Icons.calendar_month_outlined,
                onTap: () => _pickDate(
                  _controllers['investigationStartDateTo']!,
                  (v) => _apply((f) => f.copyWith(investigationStartDateTo: v)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Business Type Code',
          controller: _controllers['businessTypeCode'],
          onChanged: (v) => _apply((f) => f.copyWith(businessTypeCode: v)),
        ),
      ],
    );
  }

  Future<void> _pickDate(TextEditingController controller, ValueChanged<String> onPicked) async {
    final current = DateTime.tryParse(controller.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    final formatted =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    controller.text = formatted;
    onPicked(formatted);
  }
}
