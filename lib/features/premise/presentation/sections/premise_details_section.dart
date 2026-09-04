import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

class PremiseDetailsSection extends ConsumerWidget {
  const PremiseDetailsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final fields = ref.watch(premiseFormFieldsProvider(session));
    final readOnly = ref.watch(premiseFormControllerProvider(session).select((s) => s.isReadOnly));
    final controller = ref.read(premiseFormControllerProvider(session).notifier);

    return Form(
      key: fields.detailsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(label: 'Trade Name', controller: fields.traderName, readOnly: readOnly, uppercase: true),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Business Type',
            controller: fields.businessType,
            enabled: !readOnly,
            sheetSubtitle: 'Select business type',
            onTap: () => _pickBusinessType(context, ref, fields.businessType, controller),
          ),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Premise Type',
            controller: fields.premiseType,
            enabled: !readOnly,
            sheetSubtitle: 'Select premise type',
            onTap: () => _pickPremiseType(context, ref, fields.premiseType, controller),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Measurement (Width)',
                  controller: fields.width,
                  readOnly: readOnly,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Measurement (Length)',
                  controller: fields.length,
                  readOnly: readOnly,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _pickBusinessType(
  BuildContext context,
  WidgetRef ref,
  TextEditingController fieldController,
  PremiseFormController controller,
) async {
  final picked = await showAppAsyncOptionPicker<GeneralModel>(
    context: context,
    title: 'Business Type',
    loadOptions: () => ref.read(premiseVisitBusinessTypesProvider.future),
    label: generalLookupLabel,
    isSelected: (item) => fieldController.text.trim() == generalLookupLabel(item).trim(),
    searchable: true,
    empty: const AppListEmptyConfig(
      icon: Icons.storefront_outlined,
      title: 'No business types found',
      subtitle: 'Lookup data may still be loading on the server. Try again later.',
    ),
  );
  if (picked == null) return;
  controller.selectBusinessType(picked);
}

Future<void> _pickPremiseType(
  BuildContext context,
  WidgetRef ref,
  TextEditingController fieldController,
  PremiseFormController controller,
) async {
  final picked = await showAppAsyncOptionPicker<GeneralModel>(
    context: context,
    title: 'Premise Type',
    loadOptions: () => ref.read(premisePremiseTypesProvider.future),
    label: generalLookupLabel,
    isSelected: (item) => fieldController.text.trim() == generalLookupLabel(item).trim(),
    searchable: true,
    empty: const AppListEmptyConfig(
      icon: Icons.storefront_outlined,
      title: 'No premise types found',
      subtitle: 'Lookup data may still be loading on the server. Try again later.',
    ),
  );
  if (picked == null) return;
  controller.selectPremiseType(picked);
}
