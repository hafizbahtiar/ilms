import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/utils/premise_form_focus.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';
import 'package:ilms/shared/ui/sheets/app_option_picker_sheet.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

/// Opens the add/edit sheet for a single [PremiseAddress]. Pass [index] and
/// [initial] when editing an existing entry — the sheet mutates the form
/// controller directly (add/update/remove) rather than returning a result.
Future<void> showPremiseAddressSheet(
  BuildContext context, {
  required PremiseFormSession session,
  int? index,
  PremiseAddress? initial,
}) {
  final isEdit = initial != null;
  final bodyKey = GlobalKey<_PremiseAddressSheetBodyState>();

  return showAppBottomSheet<void>(
    context: context,
    title: isEdit ? 'Edit Address' : 'Add Address',
    preset: AppBottomSheetPreset.scrollable,
    bottomBar: AppBottomSheetActionBar(
      onPrimary: () => bodyKey.currentState?.save(),
      onSecondary: isEdit ? () => bodyKey.currentState?.delete() : null,
      primaryLabel: isEdit ? 'Update' : 'Save',
      secondaryLabel: 'Delete',
      showSecondary: isEdit,
      secondaryDestructive: true,
    ),
    builder: (context, scrollController) => _PremiseAddressSheetBody(
      key: bodyKey,
      session: session,
      index: index,
      initial: initial,
      scrollController: scrollController,
    ),
  ).unfocusPremiseFormOnComplete(context);
}

class _PremiseAddressSheetBody extends ConsumerStatefulWidget {
  const _PremiseAddressSheetBody({super.key, required this.session, this.index, this.initial, this.scrollController});

  final PremiseFormSession session;
  final int? index;
  final PremiseAddress? initial;
  final ScrollController? scrollController;

  bool get isEdit => initial != null;

  @override
  ConsumerState<_PremiseAddressSheetBody> createState() => _PremiseAddressSheetBodyState();
}

class _PremiseAddressSheetBodyState extends ConsumerState<_PremiseAddressSheetBody> {
  final _formKey = GlobalKey<FormState>();
  final _parliamentController = TextEditingController();
  final _areaController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  late final TextEditingController _unitNoController;
  late final TextEditingController _floorController;
  late final TextEditingController _blockNoController;
  late final TextEditingController _postcodeController;

  GeneralModel? _parliament;
  GeneralModel? _area;
  GeneralModel? _street;
  GeneralModel? _building;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _unitNoController = TextEditingController(text: initial?.unitNo ?? '');
    _floorController = TextEditingController(text: initial?.floor ?? '');
    _blockNoController = TextEditingController(text: initial?.blockNo ?? '');
    _postcodeController = TextEditingController(text: initial?.postcode ?? '');

    if (initial?.parliament != null) {
      _parliament = GeneralModel(code: initial!.parliament);
      _parliamentController.text = initial.parliament!;
    }
    if (initial?.area != null) {
      _area = GeneralModel(code: initial!.area);
      _areaController.text = initial.area!;
    }
    if (initial?.streetName != null) _streetController.text = initial!.streetName!;
    if (initial?.building != null) _buildingController.text = initial!.building!;
  }

  @override
  void dispose() {
    _parliamentController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _unitNoController.dispose();
    _floorController.dispose();
    _blockNoController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  Future<void> _pickParliament() async {
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Parliament',
      loadOptions: () => ref.read(generalParliamentsProvider(null).future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == _parliament?.code,
      preset: AppBottomSheetPreset.scrollable,
      empty: const AppListEmptyConfig(
        icon: Icons.location_city_outlined,
        title: 'No parliaments found',
        subtitle: 'Lookup data may still be loading on the server. Try again later.',
      ),
    ).unfocusPremiseFormOnComplete(context);
    if (picked == null) return;
    setState(() {
      _parliament = picked;
      _parliamentController.text = generalLookupLabel(picked);
      _area = null;
      _areaController.clear();
      _street = null;
      _streetController.clear();
      _building = null;
      _buildingController.clear();
    });
  }

  Future<void> _pickArea() async {
    final parliamentCode = _parliament?.code;
    if (parliamentCode == null) {
      AppSnackbar.warning(context, 'Please select parliament first.');
      return;
    }
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Area',
      loadOptions: () => ref.read(generalAreasByParliamentProvider(parliamentCode).future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == _area?.code,
      preset: AppBottomSheetPreset.scrollable,
      empty: AppListEmptyConfig(
        icon: Icons.map_outlined,
        title: 'No areas found',
        subtitle: 'There are no areas under ${_parliamentController.text.trim()}. Try another parliament.',
      ),
    ).unfocusPremiseFormOnComplete(context);
    if (picked == null) return;
    setState(() {
      _area = picked;
      _areaController.text = generalLookupLabel(picked);
      _street = null;
      _streetController.clear();
      _building = null;
      _buildingController.clear();
    });
  }

  Future<void> _pickStreet() async {
    final areaCode = _area?.code;
    if (areaCode == null) {
      AppSnackbar.warning(context, 'Please select area first.');
      return;
    }
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Street',
      loadOptions: () => ref.read(generalStreetsProvider(areaCode).future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == _street?.code,
      preset: AppBottomSheetPreset.scrollable,
      empty: AppListEmptyConfig(
        icon: Icons.signpost_outlined,
        title: 'No streets found',
        subtitle: 'There are no streets under ${_areaController.text.trim()}. Try another area.',
      ),
    ).unfocusPremiseFormOnComplete(context);
    if (picked == null) return;
    setState(() {
      _street = picked;
      _streetController.text = generalLookupLabel(picked);
      _building = null;
      _buildingController.clear();
    });
  }

  Future<void> _pickBuilding() async {
    final streetCode = _street?.code;
    if (streetCode == null) {
      AppSnackbar.warning(context, 'Please select street first.');
      return;
    }
    final picked = await showAppAsyncOptionPicker<GeneralModel>(
      context: context,
      title: 'Building Name',
      loadOptions: () => ref.read(generalBuildingsProvider(streetCode).future),
      label: generalLookupLabel,
      isSelected: (item) => item.code == _building?.code,
      preset: AppBottomSheetPreset.scrollable,
      empty: AppListEmptyConfig(
        icon: Icons.apartment_outlined,
        title: 'No buildings found',
        subtitle: 'There are no buildings under ${_streetController.text.trim()}. Try another street.',
      ),
    ).unfocusPremiseFormOnComplete(context);
    if (picked == null) return;
    setState(() {
      _building = picked;
      _buildingController.text = generalLookupLabel(picked);
    });
  }

  void save() {
    final address = PremiseAddress(
      localId: widget.initial?.localId,
      premiseAddressId: widget.initial?.premiseAddressId,
      visitPremiseAddressId: widget.initial?.visitPremiseAddressId,
      unitNo: _unitNoController.text.trim(),
      floor: _floorController.text.trim().isEmpty ? null : _floorController.text.trim(),
      blockNo: _blockNoController.text.trim().isEmpty ? null : _blockNoController.text.trim(),
      building: _building?.code ?? _buildingController.text.trim(),
      streetName: _street?.code ?? _streetController.text.trim(),
      area: _area?.code,
      parliament: _parliament?.code,
      postcode: _postcodeController.text.trim().isEmpty ? null : _postcodeController.text.trim(),
    );

    final controller = ref.read(premiseFormControllerProvider(widget.session).notifier);
    if (widget.isEdit) {
      controller.updateAddressAt(widget.index!, address);
    } else {
      controller.addAddress(address);
    }
    Navigator.of(context).pop();
  }

  Future<void> delete() async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Delete address?',
      message: 'This address will be removed from the form.',
      confirmLabel: 'Delete',
      confirmStyle: AppDialogActionStyle.destructive,
    );
    if (!confirmed || !mounted) return;

    ref.read(premiseFormControllerProvider(widget.session).notifier).removeAddressAt(widget.index!);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        controller: widget.scrollController,
        children: [
          const SizedBox(height: 10),
          AppPickerField<GeneralModel>(
            label: 'Parliament',
            controller: _parliamentController,
            onTap: _pickParliament,
          ),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Area',
            controller: _areaController,
            onTap: _pickArea,
          ),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Street',
            controller: _streetController,
            onTap: _pickStreet,
          ),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Building Name',
            controller: _buildingController,
            onTap: _pickBuilding,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Unit No.',
            controller: _unitNoController,
            uppercase: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: AppTextField(label: 'Floor', controller: _floorController, uppercase: true)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(label: 'Block No.', controller: _blockNoController, uppercase: true)),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Postcode',
            controller: _postcodeController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
