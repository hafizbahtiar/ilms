import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

class PremiseDetailsSection extends ConsumerWidget {
  const PremiseDetailsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = PremiseFormScope.of(context);
    final fields = ref.watch(premiseFormFieldsProvider(mode));
    final readOnly = ref.watch(premiseFormControllerProvider(mode).select((s) => s.isReadOnly));
    final businessTypes = ref.watch(premiseBusinessTypesProvider).value ?? const [];
    final premiseTypes = ref.watch(premisePremiseTypesProvider).value ?? const [];

    return Form(
      key: fields.detailsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Trade Name',
            controller: fields.traderName,
            readOnly: readOnly,
            required: true,
            uppercase: true,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Trade Name is required' : null,
          ),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Business Type',
            controller: fields.businessType,
            required: true,
            enabled: !readOnly,
            options: businessTypes,
            optionLabel: _lookupLabel,
            sheetSubtitle: 'Select business type',
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Business Type is required' : null,
          ),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Premise Type',
            controller: fields.premiseType,
            required: true,
            enabled: !readOnly,
            options: premiseTypes,
            optionLabel: _lookupLabel,
            sheetSubtitle: 'Select premise type',
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Premise Type is required' : null,
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

String _lookupLabel(GeneralModel option) => option.desc ?? option.code ?? '';
