import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';
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

/// Opens the add/edit sheet for a single [PremiseRemark]. Pass [index] and
/// [initial] when editing an existing entry — the sheet mutates the form
/// controller directly (add/update/remove) rather than returning a result.
Future<void> showPremiseRemarkSheet(
  BuildContext context, {
  required PremiseFormSession session,
  int? index,
  PremiseRemark? initial,
}) {
  final isEdit = initial != null;
  final bodyKey = GlobalKey<_PremiseRemarkSheetBodyState>();

  return showAppBottomSheet<void>(
    context: context,
    title: isEdit ? 'Edit Remark' : 'Add Remark',
    preset: AppBottomSheetPreset.compact,
    bottomBar: AppBottomSheetActionBar(
      onPrimary: () => bodyKey.currentState?.save(),
      onSecondary: isEdit ? () => bodyKey.currentState?.delete() : null,
      primaryLabel: isEdit ? 'Update' : 'Save',
      secondaryLabel: 'Delete',
      showSecondary: isEdit,
      secondaryDestructive: true,
    ),
    builder: (context, _) => _PremiseRemarkSheetBody(key: bodyKey, session: session, index: index, initial: initial),
  ).unfocusPremiseFormOnComplete(context);
}

class _PremiseRemarkSheetBody extends ConsumerStatefulWidget {
  const _PremiseRemarkSheetBody({super.key, required this.session, this.index, this.initial});

  final PremiseFormSession session;
  final int? index;
  final PremiseRemark? initial;

  bool get isEdit => initial != null;

  @override
  ConsumerState<_PremiseRemarkSheetBody> createState() => _PremiseRemarkSheetBodyState();
}

class _PremiseRemarkSheetBodyState extends ConsumerState<_PremiseRemarkSheetBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _typeController;
  late final TextEditingController _descriptionController;
  GeneralModel? _selectedType;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _selectedType = initial == null
        ? null
        : GeneralModel(
            code: initial.code,
            desc: initial.remark,
            type: initial.remarkType,
            apiDisplay: initial.remarkDesc,
          );
    _typeController = TextEditingController(text: initial?.remarkDesc ?? '');
    _descriptionController = TextEditingController(text: initial?.description ?? '');
  }

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isOther => (_selectedType?.desc ?? '').toLowerCase() == 'other';

  Future<void> _pickType() async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Remark Type',
      loadOptions: () => ref.read(premiseRemarksProvider.future),
      label: generalLookupLabel,
      searchable: true,
      isSelected: (item) => _typeController.text.trim() == generalLookupLabel(item).trim(),
      empty: const AppListEmptyConfig(
        icon: Icons.sticky_note_2_outlined,
        title: 'No remark types found',
        subtitle: 'Lookup data may still be loading on the server. Try again later.',
      ),
    );
    if (picked == null) return;
    setState(() {
      _selectedType = picked;
      _typeController.text = generalLookupLabel(picked);
    });
  }

  void save() {
    final type = _selectedType;

    final remark = PremiseRemark(
      id: widget.initial?.id,
      localId: widget.initial?.localId,
      code: type?.code,
      remark: type?.desc,
      remarkType: type?.type,
      remarkDesc: type == null ? null : generalLookupLabel(type),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      createdAt: widget.initial?.createdAt,
    );

    final controller = ref.read(premiseFormControllerProvider(widget.session).notifier);
    if (widget.isEdit) {
      controller.updateRemarkAt(widget.index!, remark);
    } else {
      controller.addRemark(remark);
    }
    Navigator.of(context).pop();
  }

  Future<void> delete() async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Delete remark?',
      message: 'This remark will be removed from the form.',
      confirmLabel: 'Delete',
      confirmStyle: AppDialogActionStyle.destructive,
    );
    if (!confirmed || !mounted) return;

    ref.read(premiseFormControllerProvider(widget.session).notifier).removeRemarkAt(widget.index!);
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
            label: 'Remark Type',
            controller: _typeController,
            sheetSubtitle: 'Select remark type',
            onTap: _pickType,
          ),
          if (_isOther) ...[
            const SizedBox(height: 12),
            AppTextField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              uppercase: true,
            ),
          ],
        ],
      ),
    );
  }
}
