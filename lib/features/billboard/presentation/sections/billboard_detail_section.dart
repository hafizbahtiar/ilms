import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_form_providers.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_providers.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

class BillboardDetailSection extends ConsumerWidget {
  const BillboardDetailSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = BillboardFormScope.of(context);
    final fields = ref.watch(billboardFormFieldsProvider(session));
    final readOnly = ref.watch(billboardFormControllerProvider(session).select((s) => s.isReadOnly));
    final details = ref.watch(billboardFormControllerProvider(session).select((s) => s.details));
    final controller = ref.read(billboardFormControllerProvider(session).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPickerField<GeneralModel>(
          label: 'Phase',
          controller: fields.phase,
          enabled: !readOnly,
          sheetSubtitle: 'Select phase',
          onTap: () => _pickPhase(context, ref, fields, controller),
        ),
        const SizedBox(height: 12),
        AppTextField(label: 'Description', controller: fields.description, readOnly: readOnly, maxLines: 3),
        const SizedBox(height: 12),
        AppPickerField<GeneralModel>(
          label: 'Billboard Type',
          controller: fields.billboardType,
          enabled: !readOnly,
          sheetSubtitle: 'Select billboard type',
          onTap: () => _pickBillboardType(context, ref, fields, controller),
        ),
        const SizedBox(height: 12),
        _YesNoRow(label: 'LED Board', value: details.isLedBoard, onChanged: readOnly ? null : controller.setLed),
        _YesNoRow(label: 'Light', value: details.isLight, onChanged: readOnly ? null : controller.setLight),
        _YesNoRow(label: 'Potential', value: details.isPotential, onChanged: readOnly ? null : controller.setPotential),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppPickerField<DateTime>(
                label: 'Hoarding Start Date',
                controller: fields.hoardingStartDate,
                enabled: !readOnly,
                suffixIcon: Icons.calendar_month_outlined,
                onTap: () => _pickDate(context, fields, controller, isStart: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppPickerField<DateTime>(
                label: 'Hoarding Complete Date',
                controller: fields.hoardingCompleteDate,
                enabled: !readOnly,
                suffixIcon: Icons.calendar_month_outlined,
                onTap: () => _pickDate(context, fields, controller, isStart: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickPhase(BuildContext context, WidgetRef ref, dynamic fields, dynamic controller) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Phase',
      loadOptions: () => ref.read(billboardPhasesProvider.future),
      label: generalLookupLabel,
      isSelected: (item) => fields.phase.text.trim() == generalLookupLabel(item).trim(),
      searchable: true,
      empty: const AppListEmptyConfig(
        icon: Icons.timeline_outlined,
        title: 'No phases found',
        subtitle: 'Lookup data may still be loading on the server. Try again later.',
      ),
    );
    if (picked == null) return;
    controller.selectPhase(picked);
  }

  Future<void> _pickBillboardType(BuildContext context, WidgetRef ref, dynamic fields, dynamic controller) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Billboard Type',
      loadOptions: () => ref.read(billboardTypesProvider.future),
      label: generalLookupLabel,
      isSelected: (item) => fields.billboardType.text.trim() == generalLookupLabel(item).trim(),
      searchable: true,
      empty: const AppListEmptyConfig(
        icon: Icons.campaign_outlined,
        title: 'No billboard types found',
        subtitle: 'Lookup data may still be loading on the server. Try again later.',
      ),
    );
    if (picked == null) return;
    controller.selectBillboardType(picked);
  }

  Future<void> _pickDate(BuildContext context, dynamic fields, dynamic controller, {required bool isStart}) async {
    final current = isStart ? fields.hoardingStartDate.text : fields.hoardingCompleteDate.text;
    final initialDate = DateTime.tryParse(current) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    final formatted = formatIsoDate(picked);
    if (isStart) {
      fields.hoardingStartDate.text = formatted;
      controller.setHoardingStartDate(formatted);
    } else {
      fields.hoardingCompleteDate.text = formatted;
      controller.setHoardingCompleteDate(formatted);
    }
  }
}

class _YesNoRow extends StatelessWidget {
  const _YesNoRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
