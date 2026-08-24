import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_face.dart';
import 'package:ilms/features/billboard/presentation/controllers/billboard_form_state.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_form_providers.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

/// Opens the add/edit sheet for a single [BillboardFace] (width/height/count).
/// Pass [index] and [initial] when editing an existing entry — the sheet
/// mutates the form controller directly (add/update/remove).
Future<void> showBillboardFaceDialog(
  BuildContext context, {
  required BillboardFormSession session,
  int? index,
  BillboardFace? initial,
}) {
  final isEdit = initial != null;
  final bodyKey = GlobalKey<_BillboardFaceDialogBodyState>();

  return showAppBottomSheet<void>(
    context: context,
    title: isEdit ? 'Edit Face' : 'Add Face',
    preset: AppBottomSheetPreset.compact,
    bottomBar: AppBottomSheetActionBar(
      onPrimary: () => bodyKey.currentState?.save(),
      onSecondary: isEdit ? () => bodyKey.currentState?.delete() : null,
      primaryLabel: isEdit ? 'Update' : 'Save',
      secondaryLabel: 'Delete',
      showSecondary: isEdit,
      secondaryDestructive: true,
    ),
    builder: (context, _) => _BillboardFaceDialogBody(key: bodyKey, session: session, index: index, initial: initial),
  );
}

class _BillboardFaceDialogBody extends ConsumerStatefulWidget {
  const _BillboardFaceDialogBody({super.key, required this.session, this.index, this.initial});

  final BillboardFormSession session;
  final int? index;
  final BillboardFace? initial;

  bool get isEdit => initial != null;

  @override
  ConsumerState<_BillboardFaceDialogBody> createState() => _BillboardFaceDialogBodyState();
}

class _BillboardFaceDialogBodyState extends ConsumerState<_BillboardFaceDialogBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _countController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _widthController = TextEditingController(text: initial?.width?.toString() ?? '');
    _heightController = TextEditingController(text: initial?.height?.toString() ?? '');
    _countController = TextEditingController(text: initial?.count?.toString() ?? '');
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void save() {
    final face = BillboardFace(
      id: widget.initial?.id,
      localId: widget.initial?.localId,
      width: int.tryParse(_widthController.text.trim()),
      height: int.tryParse(_heightController.text.trim()),
      count: int.tryParse(_countController.text.trim()),
    );

    final controller = ref.read(billboardFormControllerProvider(widget.session).notifier);
    if (widget.isEdit) {
      controller.updateFaceAt(widget.index!, face);
    } else {
      controller.addFace(face);
    }
    Navigator.of(context).pop();
  }

  Future<void> delete() async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Delete face?',
      message: 'This face will be removed from the form.',
      confirmLabel: 'Delete',
      confirmStyle: AppDialogActionStyle.destructive,
    );
    if (!confirmed || !mounted) return;

    ref.read(billboardFormControllerProvider(widget.session).notifier).removeFaceAt(widget.index!);
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
          AppTextField(
            label: 'Width (mm)',
            controller: _widthController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Height (mm)',
            controller: _heightController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Count',
            controller: _countController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }
}
