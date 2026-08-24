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
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/media/scanner/app_barcode_scanner_page.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

class CompanyContactSection extends ConsumerWidget {
  const CompanyContactSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final fields = ref.watch(premiseFormFieldsProvider(session));
    final formState = ref.watch(premiseFormControllerProvider(session));
    final readOnly = formState.isReadOnly;
    final controller = ref.read(premiseFormControllerProvider(session).notifier);

    return Form(
      key: fields.companyFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PremiseSubsectionTitle(title: 'Census Details'),
          AppTextField(label: 'Company Name', controller: fields.companyName, readOnly: readOnly, uppercase: true),
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
                sheetSubtitle: 'Select state',
                onTap: () => _pickState(context, ref, fields.state, controller),
              ),
              AppPickerField<GeneralModel>(
                label: 'Postcode',
                controller: fields.postcode,
                enabled: !readOnly && formState.companyStateCode != null,
                sheetSubtitle: formState.companyStateCode == null ? 'Select state first' : 'Select postcode',
                // Opens immediately and shows the sheet's own loading state
                // instead of pre-resolving the list first — otherwise a tap
                // that lands while the postcode list is still fetching for
                // the just-picked state silently does nothing at all.
                onTap: () => _pickPostcode(context, ref, fields.postcode, formState.companyStateCode!, controller),
              ),
              AppPickerField<GeneralModel>(
                label: 'Area',
                controller: fields.area,
                enabled: !readOnly && formState.companyStateCode != null,
                sheetSubtitle: 'Select area',
                onTap: () => _pickArea(
                  context,
                  ref,
                  fields.area,
                  formState.companyStateCode!,
                  formState.companyPostcode,
                  controller,
                ),
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
              AppTextField(
                label: 'Position',
                controller: fields.contactPersonPosition,
                readOnly: readOnly,
                uppercase: true,
              ),
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

Future<void> _pickState(
  BuildContext context,
  WidgetRef ref,
  TextEditingController fieldController,
  PremiseFormController controller,
) async {
  final picked = await showAppAsyncOptionPicker<GeneralModel>(
    context: context,
    title: 'State',
    loadOptions: () => ref.read(premiseStatesProvider.future),
    label: generalLookupLabel,
    isSelected: (item) => fieldController.text.trim() == generalLookupLabel(item).trim(),
    searchable: true,
    empty: const AppListEmptyConfig(
      icon: Icons.map_outlined,
      title: 'No states found',
      subtitle: 'Lookup data may still be loading on the server. Try again later.',
    ),
  );
  if (picked == null) return;
  controller.selectCompanyState(picked);
}

Future<void> _pickPostcode(
  BuildContext context,
  WidgetRef ref,
  TextEditingController fieldController,
  String stateCode,
  PremiseFormController controller,
) async {
  final picked = await showAppAsyncOptionPicker<GeneralModel>(
    context: context,
    title: 'Postcode',
    loadOptions: () => ref.read(premisePostcodesProvider(stateCode).future),
    label: generalPostcodeLabel,
    isSelected: (item) => fieldController.text.trim() == generalPostcodeLabel(item).trim(),
    searchable: true,
    empty: const AppListEmptyConfig(
      icon: Icons.mail_outline_rounded,
      title: 'No postcodes found',
      subtitle: 'Lookup data may still be loading on the server. Try again later.',
    ),
  );
  if (picked == null) return;
  controller.selectCompanyPostcode(picked);
}

Future<void> _pickArea(
  BuildContext context,
  WidgetRef ref,
  TextEditingController fieldController,
  String stateCode,
  String? postcode,
  PremiseFormController controller,
) async {
  final picked = await showAppAsyncOptionPicker<GeneralModel>(
    context: context,
    title: 'Area',
    loadOptions: () =>
        ref.read(premiseAreasProvider(GeneralAreaFilter(stateCode: stateCode, postcode: postcode)).future),
    label: generalLookupLabel,
    isSelected: (item) => fieldController.text.trim() == generalLookupLabel(item).trim(),
    searchable: true,
    empty: const AppListEmptyConfig(
      icon: Icons.map_outlined,
      title: 'No areas found',
      subtitle: 'Lookup data may still be loading on the server. Try again later.',
    ),
  );
  if (picked == null) return;
  controller.selectCompanyArea(picked);
}
