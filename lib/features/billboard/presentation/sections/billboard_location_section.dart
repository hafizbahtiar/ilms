import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_form_providers.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_providers.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

class BillboardLocationSection extends ConsumerWidget {
  const BillboardLocationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = BillboardFormScope.of(context);
    final fields = ref.watch(billboardFormFieldsProvider(session));
    final readOnly = ref.watch(billboardFormControllerProvider(session).select((s) => s.isReadOnly));
    final location = ref.watch(billboardFormControllerProvider(session).select((s) => s.location));
    final controller = ref.read(billboardFormControllerProvider(session).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(label: 'Media Client Name', controller: fields.mediaClientName, readOnly: readOnly),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Media Client Tel',
          controller: fields.mediaClientTel,
          readOnly: readOnly,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        AppTextField(label: 'Unit', controller: fields.unit, readOnly: readOnly),
        const SizedBox(height: 12),
        AppTextField(label: 'Address', controller: fields.address, readOnly: readOnly, maxLines: 2),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Postal',
          controller: fields.postal,
          readOnly: readOnly,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        AppTextField(label: 'Building', controller: fields.building, readOnly: readOnly),
        const SizedBox(height: 12),
        AppPickerField<GeneralModel>(
          label: 'Parliament',
          controller: fields.parliament,
          enabled: !readOnly,
          sheetSubtitle: 'Select parliament',
          onTap: () => _pickParliament(context, ref, fields, controller),
        ),
        const SizedBox(height: 12),
        AppPickerField<GeneralModel>(
          label: 'Area',
          controller: fields.area,
          enabled: !readOnly,
          sheetSubtitle: 'Select area',
          onTap: () => _pickArea(context, ref, fields, controller, location.parliamentCode),
        ),
      ],
    );
  }

  Future<void> _pickParliament(BuildContext context, WidgetRef ref, dynamic fields, dynamic controller) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Parliament',
      loadOptions: () => ref.read(billboardParliamentsProvider(null).future),
      label: generalLookupLabel,
      isSelected: (item) => fields.parliament.text.trim() == generalLookupLabel(item).trim(),
      searchable: true,
      empty: const AppListEmptyConfig(
        icon: Icons.map_outlined,
        title: 'No parliaments found',
        subtitle: 'Lookup data may still be loading on the server. Try again later.',
      ),
    );
    if (picked == null) return;
    controller.selectParliament(picked);
  }

  Future<void> _pickArea(
    BuildContext context,
    WidgetRef ref,
    dynamic fields,
    dynamic controller,
    String? parliamentCode,
  ) async {
    if (parliamentCode == null || parliamentCode.isEmpty) {
      AppSnackbar.warning(context, 'Please select parliament first.');
      return;
    }
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Area',
      loadOptions: () => ref.read(billboardAreasByParliamentProvider(parliamentCode).future),
      label: generalLookupLabel,
      isSelected: (item) => fields.area.text.trim() == generalLookupLabel(item).trim(),
      searchable: true,
      empty: const AppListEmptyConfig(
        icon: Icons.location_city_outlined,
        title: 'No areas found',
        subtitle: 'Lookup data may still be loading on the server. Try again later.',
      ),
    );
    if (picked == null) return;
    controller.selectArea(picked);
  }
}
