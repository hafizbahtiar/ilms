import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_section_header.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

class CompanyContactSection extends ConsumerWidget {
  const CompanyContactSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final fields = ref.watch(premiseFormFieldsProvider(session));
    final formState = ref.watch(premiseFormControllerProvider(session));
    final readOnly = formState.isReadOnly;
    final controller = ref.read(premiseFormControllerProvider(session).notifier);
    final states = ref.watch(premiseStatesProvider).value ?? const [];
    final postcodes = ref.watch(premisePostcodesProvider(formState.companyStateCode)).value ?? const [];
    final areas = ref.watch(
      premiseAreasProvider(GeneralAreaFilter(stateCode: formState.companyStateCode, postcode: formState.companyPostcode)),
    ).value ?? const [];

    return Form(
      key: fields.companyFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PremiseSubsectionTitle(title: 'Census Details'),
          AppTextField(
            label: 'Company Name',
            controller: fields.companyName,
            readOnly: readOnly,
            required: true,
            uppercase: true,
            validator: _required('Company Name is required'),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Register Number',
            controller: fields.registerNumber,
            readOnly: readOnly,
            required: true,
            uppercase: true,
            maxLength: 12,
            validator: _required('Register Number is required'),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Company Tel No.',
            controller: fields.companyTelNo,
            keyboardType: TextInputType.phone,
            readOnly: readOnly,
            required: true,
            uppercase: true,
            maxLength: 10,
            validator: _required('Company Tel No. is required'),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Company Fax No.',
            controller: fields.companyFaxNo,
            keyboardType: TextInputType.phone,
            readOnly: readOnly,
            required: true,
            uppercase: true,
            maxLength: 10,
            validator: _required('Company Fax No. is required'),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Sticker No.',
            controller: fields.stickerNo,
            readOnly: readOnly,
            required: true,
            uppercase: true,
            validator: _required('Sticker No. is required'),
            suffixWidget: readOnly
                ? null
                : IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () => AppSnackbar.info(context, 'QR scanner coming soon.'),
                  ),
          ),
          const SizedBox(height: 12),
          AppPickerField(
            label: 'Census Date',
            controller: fields.censusDate,
            required: true,
            enabled: !readOnly,
            suffixIcon: Icons.calendar_month_outlined,
            validator: _required('Census Date is required'),
            onTap: () => AppSnackbar.info(context, 'Date picker coming soon.'),
          ),
          const SizedBox(height: 20),
          const PremiseSubsectionTitle(title: 'Company Address'),
          _twoColumn(context, [
            AppTextField(
              label: 'Unit',
              controller: fields.unit,
              readOnly: readOnly,
              required: true,
              uppercase: true,
              validator: _required('Unit is required'),
            ),
            AppTextField(
              label: 'Building',
              controller: fields.building,
              readOnly: readOnly,
              required: true,
              uppercase: true,
              validator: _required('Building is required'),
            ),
            AppTextField(
              label: 'Street 1',
              controller: fields.street1,
              readOnly: readOnly,
              required: true,
              uppercase: true,
              validator: _required('Street 1 is required'),
            ),
            AppTextField(
              label: 'Street 2',
              controller: fields.street2,
              readOnly: readOnly,
              required: true,
              uppercase: true,
              validator: _required('Street 2 is required'),
            ),
            AppPickerField<GeneralModel>(
              label: 'State',
              controller: fields.state,
              required: true,
              enabled: !readOnly,
              options: states,
              optionLabel: generalLookupLabel,
              sheetSubtitle: 'Select state',
              onOptionSelected: controller.selectCompanyState,
              validator: _required('State is required'),
            ),
            AppPickerField<GeneralModel>(
              label: 'Postcode',
              controller: fields.postcode,
              required: true,
              enabled: !readOnly && formState.companyStateCode != null,
              options: postcodes,
              optionLabel: generalPostcodeLabel,
              sheetSubtitle: formState.companyStateCode == null ? 'Select state first' : 'Select postcode',
              onOptionSelected: controller.selectCompanyPostcode,
              validator: _required('Postcode is required'),
            ),
            AppPickerField<GeneralModel>(
              label: 'Area',
              controller: fields.area,
              required: true,
              enabled: !readOnly && formState.companyStateCode != null,
              options: areas,
              optionLabel: generalLookupLabel,
              sheetSubtitle: 'Select area',
              onOptionSelected: controller.selectCompanyArea,
              validator: _required('Area is required'),
            ),
          ]),
          const SizedBox(height: 20),
          const PremiseSubsectionTitle(title: 'Contact Person'),
          _twoColumn(context, [
            AppTextField(
              label: 'Name',
              controller: fields.contactPersonName,
              readOnly: readOnly,
              required: true,
              uppercase: true,
              validator: _required('Name is required'),
            ),
            AppTextField(
              label: 'Phone',
              controller: fields.contactPersonPhone,
              keyboardType: TextInputType.phone,
              readOnly: readOnly,
              required: true,
              uppercase: true,
              validator: _required('Phone is required'),
            ),
            AppTextField(
              label: 'Email',
              controller: fields.contactPersonEmail,
              keyboardType: TextInputType.emailAddress,
              readOnly: readOnly,
              required: true,
              uppercase: false,
              validator: _required('Email is required'),
            ),
            AppTextField(
              label: 'Position',
              controller: fields.contactPersonPosition,
              readOnly: readOnly,
              required: true,
              uppercase: true,
              validator: _required('Position is required'),
            ),
          ]),
        ],
      ),
    );
  }
}

String? Function(String?) _required(String message) {
  return (value) => (value == null || value.trim().isEmpty) ? message : null;
}

Widget _twoColumn(BuildContext context, List<Widget> children) {
  final width = MediaQuery.sizeOf(context).width;
  final columns = width >= 600 ? 2 : 1;

  if (columns == 1) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 12), children[i]],
      ],
    );
  }

  return Wrap(
    spacing: 12,
    runSpacing: 12,
    children: children.map((child) => SizedBox(width: (width - 48 - 12) / 2, child: child)).toList(),
  );
}
