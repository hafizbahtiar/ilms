import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/utils/premise_form_focus.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

/// Opens the add/edit sheet for a single [PremiseBusinessActivity]. Pass
/// [index] and [initial] when editing an existing entry — the sheet mutates
/// the form controller directly (add/update/remove) rather than returning a
/// result.
Future<void> showPremiseBusinessActivitySheet(
  BuildContext context, {
  required PremiseFormSession session,
  int? index,
  PremiseBusinessActivity? initial,
}) {
  final isEdit = initial != null;
  final bodyKey = GlobalKey<_PremiseBusinessActivitySheetBodyState>();

  return showAppBottomSheet<void>(
    context: context,
    title: isEdit ? 'Edit Business Activity' : 'Add Business Activity',
    preset: AppBottomSheetPreset.compact,
    bottomBar: AppBottomSheetActionBar(
      onPrimary: () => bodyKey.currentState?.save(),
      onSecondary: isEdit ? () => bodyKey.currentState?.delete() : null,
      primaryLabel: isEdit ? 'Update' : 'Save',
      secondaryLabel: 'Delete',
      showSecondary: isEdit,
      secondaryDestructive: true,
    ),
    builder: (context, _) =>
        _PremiseBusinessActivitySheetBody(key: bodyKey, session: session, index: index, initial: initial),
  ).unfocusPremiseFormOnComplete(context);
}

class _PremiseBusinessActivitySheetBody extends ConsumerStatefulWidget {
  const _PremiseBusinessActivitySheetBody({super.key, required this.session, this.index, this.initial});

  final PremiseFormSession session;
  final int? index;
  final PremiseBusinessActivity? initial;

  bool get isEdit => initial != null;

  @override
  ConsumerState<_PremiseBusinessActivitySheetBody> createState() => _PremiseBusinessActivitySheetBodyState();
}

class _PremiseBusinessActivitySheetBodyState extends ConsumerState<_PremiseBusinessActivitySheetBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessTypeController;
  late final TextEditingController _statusController;
  late final TextEditingController _descriptionController;
  GeneralModel? _selectedBusinessType;
  GeneralModel? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _selectedBusinessType = initial == null
        ? null
        : GeneralModel(code: initial.businessType, apiDisplay: initial.businessTypeDesc);
    _selectedStatus = initial == null ? null : GeneralModel(code: initial.status, apiDisplay: initial.statusDesc);

    _businessTypeController = TextEditingController(text: initial?.businessTypeDesc ?? '');
    _statusController = TextEditingController(text: initial?.statusDesc ?? '');
    _descriptionController = TextEditingController(text: initial?.description ?? '');
  }

  @override
  void dispose() {
    _businessTypeController.dispose();
    _statusController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void save() {
    final businessType = _selectedBusinessType;
    final status = _selectedStatus;

    final activity = PremiseBusinessActivity(
      id: widget.initial?.id,
      localId: widget.initial?.localId,
      businessType: businessType?.code,
      businessTypeDesc: businessType == null ? null : generalLookupLabel(businessType),
      status: status?.code,
      statusDesc: status == null ? null : generalLookupLabel(status),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    final controller = ref.read(premiseFormControllerProvider(widget.session).notifier);
    if (widget.isEdit) {
      controller.updateBusinessActivityAt(widget.index!, activity);
    } else {
      controller.addBusinessActivity(activity);
    }
    Navigator.of(context).pop();
  }

  Future<void> delete() async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Delete business activity?',
      message: 'This business activity will be removed from the form.',
      confirmLabel: 'Delete',
      confirmStyle: AppDialogActionStyle.destructive,
    );
    if (!confirmed || !mounted) return;

    ref.read(premiseFormControllerProvider(widget.session).notifier).removeBusinessActivityAt(widget.index!);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          AppPickerField<GeneralModel>(
            label: 'Business Type',
            controller: _businessTypeController,
            sheetSubtitle: 'Select business type',
            onTap: _pickBusinessType,
          ),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Status',
            controller: _statusController,
            sheetSubtitle: 'Select status',
            onTap: _pickStatus,
          ),
          const SizedBox(height: 12),
          AppTextField(label: 'Description', controller: _descriptionController, maxLines: 3, uppercase: true),
        ],
      ),
    );
  }

  Future<void> _pickBusinessType() async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Business Type',
      loadOptions: () => ref.read(premiseBusinessTypesProvider.future),
      label: generalLookupLabel,
      isSelected: (item) => _businessTypeController.text.trim() == generalLookupLabel(item).trim(),
      empty: const AppListEmptyConfig(
        icon: Icons.storefront_outlined,
        title: 'No business types found',
        subtitle: 'Lookup data may still be loading on the server. Try again later.',
      ),
    );
    if (picked == null) return;
    setState(() {
      _selectedBusinessType = picked;
      _businessTypeController.text = generalLookupLabel(picked);
    });
  }

  Future<void> _pickStatus() async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Status',
      loadOptions: () => ref.read(premiseBusinessActivityStatusesProvider.future),
      label: generalLookupLabel,
      isSelected: (item) => _statusController.text.trim() == generalLookupLabel(item).trim(),
      empty: const AppListEmptyConfig(
        icon: Icons.task_alt_outlined,
        title: 'No statuses found',
        subtitle: 'Lookup data may still be loading on the server. Try again later.',
      ),
    );
    if (picked == null) return;
    setState(() {
      _selectedStatus = picked;
      _statusController.text = generalLookupLabel(picked);
    });
  }
}
