import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_form_providers.dart';
import 'package:ilms/features/investigation/presentation/widgets/investigation_minute_history_sheet.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

/// The only section with real validation — investigation date, time, and
/// minutes text are all mandatory. Also surfaces the read-only historical
/// minute list via a sub-sheet.
class InvestigationMinutesSection extends ConsumerWidget {
  const InvestigationMinutesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = InvestigationFormScope.of(context);
    final fields = ref.watch(investigationFormFieldsProvider(session));
    final readOnly = ref.watch(investigationFormControllerProvider(session).select((s) => s.isReadOnly));
    final minutes = ref.watch(investigationFormControllerProvider(session).select((s) => s.minutes));
    final controller = ref.read(investigationFormControllerProvider(session).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history_outlined),
          title: const Text('Minute History'),
          subtitle: Text('${minutes.length} record${minutes.length == 1 ? '' : 's'}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showInvestigationMinuteHistorySheet(context, minutes),
        ),
        const Divider(height: 32),
        AppTextField(
          label: 'Investigation Date',
          controller: fields.minutesDate,
          readOnly: true,
          enabled: !readOnly,
          required: true,
          suffixIcon: Icons.calendar_month_outlined,
          onTap: readOnly ? null : () => _pickDate(context, fields, controller),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Investigation Time',
          controller: fields.minutesTime,
          readOnly: true,
          enabled: !readOnly,
          required: true,
          suffixIcon: Icons.access_time_outlined,
          onTap: readOnly ? null : () => _pickTime(context, fields, controller),
        ),
        const SizedBox(height: 12),
        AppTextField(label: 'Prepared By', controller: fields.minutesPreparedBy, readOnly: readOnly),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Minutes',
          controller: fields.minutesText,
          readOnly: readOnly,
          required: true,
          maxLines: 5,
          onChanged: (_) {},
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, dynamic fields, dynamic controller) async {
    final current = DateTime.tryParse(fields.minutesDate.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    final formatted =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    fields.minutesDate.text = formatted;
    controller.setMinutesDate(picked);
  }

  Future<void> _pickTime(BuildContext context, dynamic fields, dynamic controller) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked == null || !context.mounted) return;

    final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    fields.minutesTime.text = formatted;
    controller.setMinutesTime(formatted);
  }
}
