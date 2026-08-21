import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_section_header.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/layout/responsive_two_column.dart';
import 'package:ilms/shared/ui/media/scanner/app_barcode_scanner_page.dart';

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
    final areas =
        ref
            .watch(
              premiseAreasProvider(
                GeneralAreaFilter(stateCode: formState.companyStateCode, postcode: formState.companyPostcode),
              ),
            )
            .value ??
        const [];

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
            uppercase: true,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Register Number',
            controller: fields.registerNumber,
            readOnly: readOnly,
            uppercase: true,
            maxLength: 12,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Company Tel No.',
            controller: fields.companyTelNo,
            keyboardType: TextInputType.phone,
            readOnly: readOnly,
            uppercase: true,
            maxLength: 10,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Company Fax No.',
            controller: fields.companyFaxNo,
            keyboardType: TextInputType.phone,
            readOnly: readOnly,
            uppercase: true,
            maxLength: 10,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Sticker No.',
            controller: fields.stickerNo,
            readOnly: readOnly,
            uppercase: true,
            suffixWidget: readOnly
                ? null
                : IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () => _scanStickerNo(context, fields.stickerNo),
                  ),
          ),
          const SizedBox(height: 12),
          AppPickerField(
            label: 'Census Date',
            controller: fields.censusDate,
            enabled: !readOnly,
            suffixIcon: Icons.calendar_month_outlined,
            onTap: readOnly ? null : () => _pickCensusDate(context, fields.censusDate),
          ),
          const SizedBox(height: 20),
          const PremiseSubsectionTitle(title: 'Company Address'),
          ResponsiveTwoColumn(
            children: [
              AppTextField(label: 'Unit', controller: fields.unit, readOnly: readOnly, uppercase: true),
              AppTextField(label: 'Building', controller: fields.building, readOnly: readOnly, uppercase: true),
              AppTextField(label: 'Street 1', controller: fields.street1, readOnly: readOnly, uppercase: true),
              AppTextField(label: 'Street 2', controller: fields.street2, readOnly: readOnly, uppercase: true),
              AppPickerField<GeneralModel>(
                label: 'State',
                controller: fields.state,
                enabled: !readOnly,
                options: states,
                optionLabel: generalLookupLabel,
                sheetSubtitle: 'Select state',
                onOptionSelected: controller.selectCompanyState,
              ),
              AppPickerField<GeneralModel>(
                label: 'Postcode',
                controller: fields.postcode,
                enabled: !readOnly && formState.companyStateCode != null,
                options: postcodes,
                optionLabel: generalPostcodeLabel,
                sheetSubtitle: formState.companyStateCode == null ? 'Select state first' : 'Select postcode',
                onOptionSelected: controller.selectCompanyPostcode,
              ),
              AppPickerField<GeneralModel>(
                label: 'Area',
                controller: fields.area,
                enabled: !readOnly && formState.companyStateCode != null,
                options: areas,
                optionLabel: generalLookupLabel,
                sheetSubtitle: 'Select area',
                onOptionSelected: controller.selectCompanyArea,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const PremiseSubsectionTitle(title: 'Contact Person'),
          ResponsiveTwoColumn(
            children: [
              AppTextField(label: 'Name', controller: fields.contactPersonName, readOnly: readOnly, uppercase: true),
              AppTextField(
                label: 'Phone',
                controller: fields.contactPersonPhone,
                keyboardType: TextInputType.phone,
                readOnly: readOnly,
                uppercase: true,
              ),
              AppTextField(
                label: 'Email',
                controller: fields.contactPersonEmail,
                keyboardType: TextInputType.emailAddress,
                readOnly: readOnly,
              ),
              AppTextField(label: 'Position', controller: fields.contactPersonPosition, readOnly: readOnly, uppercase: true),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _pickCensusDate(BuildContext context, TextEditingController controller) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: parseDdMmYyyy(controller.text) ?? now,
    firstDate: DateTime(2000),
    lastDate: now,
  );
  if (picked == null) return;
  controller.text = formatDdMmYyyy(picked);
}

Future<void> _scanStickerNo(BuildContext context, TextEditingController controller) async {
  final code = await AppBarcodeScannerPage.open(
    context,
    title: 'Scan Sticker No.',
    subtitle: 'Align the sticker QR/barcode within the frame',
  );
  if (code == null || !context.mounted) return;
  controller.text = code;
}
