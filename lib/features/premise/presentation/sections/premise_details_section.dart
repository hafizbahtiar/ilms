import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

class PremiseDetailsSection extends ConsumerWidget {
  const PremiseDetailsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final fields = ref.watch(premiseFormFieldsProvider(session));
    final readOnly = ref.watch(premiseFormControllerProvider(session).select((s) => s.isReadOnly));
    final businessTypes = ref.watch(premiseBusinessTypesProvider).value ?? const [];
    final premiseTypes = ref.watch(premisePremiseTypesProvider).value ?? const [];
    final controller = ref.read(premiseFormControllerProvider(session).notifier);

    return Form(
      key: fields.detailsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Trade Name',
            controller: fields.traderName,
            readOnly: readOnly,
            uppercase: true,
          ),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Business Type',
            controller: fields.businessType,
            enabled: !readOnly,
            options: businessTypes,
            optionLabel: generalLookupLabel,
            sheetSubtitle: 'Select business type',
            onOptionSelected: controller.selectBusinessType,
          ),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Premise Type',
            controller: fields.premiseType,
            enabled: !readOnly,
            options: premiseTypes,
            optionLabel: generalLookupLabel,
            sheetSubtitle: 'Select premise type',
            onOptionSelected: controller.selectPremiseType,
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
