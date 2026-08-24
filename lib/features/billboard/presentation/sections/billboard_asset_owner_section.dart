import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_form_providers.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_providers.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';

class BillboardAssetOwnerSection extends ConsumerWidget {
  const BillboardAssetOwnerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = BillboardFormScope.of(context);
    final fields = ref.watch(billboardFormFieldsProvider(session));
    final readOnly = ref.watch(billboardFormControllerProvider(session).select((s) => s.isReadOnly));
    final controller = ref.read(billboardFormControllerProvider(session).notifier);

    return AppPickerField<GeneralModel>(
      label: 'Asset Owner',
      controller: fields.assetOwner,
      enabled: !readOnly,
      sheetSubtitle: 'Select asset owner',
      onTap: () => _pickAssetOwner(context, ref, fields, controller),
    );
  }

  Future<void> _pickAssetOwner(BuildContext context, WidgetRef ref, dynamic fields, dynamic controller) async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Asset Owner',
      loadOptions: () => ref.read(billboardAssetOwnersProvider.future),
      label: generalLookupLabel,
      isSelected: (item) => fields.assetOwner.text.trim() == generalLookupLabel(item).trim(),
      searchable: true,
      empty: const AppListEmptyConfig(
        icon: Icons.apartment_outlined,
        title: 'No asset owners found',
        subtitle: 'Lookup data may still be loading on the server. Try again later.',
      ),
    );
    if (picked == null) return;
    controller.selectAssetOwner(picked);
  }
}
