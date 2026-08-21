import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/api_response_helper.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_qr_data.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/utils/premise_form_focus.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_license_qr_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/media/scanner/app_barcode_scanner_page.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

/// Opens the add/edit sheet for a single [PremiseLicense]. Pass [index] and
/// [initial] when editing an existing entry — the sheet mutates the form
/// controller directly (add/update/remove) rather than returning a result.
Future<void> showPremiseLicenseSheet(
  BuildContext context, {
  required PremiseFormSession session,
  int? index,
  PremiseLicense? initial,
}) {
  final isEdit = initial != null;
  final bodyKey = GlobalKey<_PremiseLicenseSheetBodyState>();

  return showAppBottomSheet<void>(
    context: context,
    title: isEdit ? 'Edit License' : 'Add License',
    preset: AppBottomSheetPreset.scrollable,
    bottomBar: AppBottomSheetActionBar(
      onPrimary: () => bodyKey.currentState?.save(),
      onSecondary: isEdit ? () => bodyKey.currentState?.delete() : null,
      primaryLabel: isEdit ? 'Update' : 'Save',
      secondaryLabel: 'Delete',
      showSecondary: isEdit,
      secondaryDestructive: true,
    ),
    builder: (context, scrollController) => _PremiseLicenseSheetBody(
      key: bodyKey,
      session: session,
      index: index,
      initial: initial,
      scrollController: scrollController,
    ),
  ).unfocusPremiseFormOnComplete(context);
}

class _PremiseLicenseSheetBody extends ConsumerStatefulWidget {
  const _PremiseLicenseSheetBody({super.key, required this.session, this.index, this.initial, this.scrollController});

  final PremiseFormSession session;
  final int? index;
  final PremiseLicense? initial;
  final ScrollController? scrollController;

  bool get isEdit => initial != null;

  @override
  ConsumerState<_PremiseLicenseSheetBody> createState() => _PremiseLicenseSheetBodyState();
}

class _PremiseLicenseSheetBodyState extends ConsumerState<_PremiseLicenseSheetBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _licenseNoController;
  late final TextEditingController _licenseFileNoController;
  late final TextEditingController _statusController;
  late final TextEditingController _validFromController;
  late final TextEditingController _validToController;
  GeneralModel? _selectedStatus;
  DateTime? _validFrom;
  DateTime? _validTo;
  var _isScanningQr = false;

  // Sub-form for composing one business activity, then "Add to list".
  final _actBusinessTypeController = TextEditingController();
  final _actStatusController = TextEditingController();
  final _actDescriptionController = TextEditingController();
  final _actAmountController = TextEditingController(text: '0.00');
  GeneralModel? _actSelectedBusinessType;
  GeneralModel? _actSelectedStatus;
  var _actSaveToBusiness = false;

  late List<PremiseLicenseActivity> _items;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _selectedStatus = initial == null
        ? null
        : GeneralModel(code: initial.status, apiDisplay: initial.statusDesc, desc: initial.statusDesc);
    _validFrom = parseDdMmYyyy(initial?.validFrom);
    _validTo = parseDdMmYyyy(initial?.validTo);
    _items = List.of(initial?.businessActivities ?? const []);

    _licenseNoController = TextEditingController(text: initial?.licenseNo ?? '');
    _licenseFileNoController = TextEditingController(text: initial?.licenseFileNo ?? '');
    _statusController = TextEditingController(text: initial?.statusDesc ?? '');
    _validFromController = TextEditingController(text: formatDdMmYyyy(_validFrom));
    _validToController = TextEditingController(text: formatDdMmYyyy(_validTo));
  }

  @override
  void dispose() {
    _licenseNoController.dispose();
    _licenseFileNoController.dispose();
    _statusController.dispose();
    _validFromController.dispose();
    _validToController.dispose();
    _actBusinessTypeController.dispose();
    _actStatusController.dispose();
    _actDescriptionController.dispose();
    _actAmountController.dispose();
    super.dispose();
  }

  void _selectStatus(GeneralModel item) => setState(() => _selectedStatus = item);

  Future<void> _pickDate({required bool isFrom}) async {
    final initialDate = (isFrom ? _validFrom : _validTo) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _validFrom = picked;
        _validFromController.text = formatDdMmYyyy(picked);
      } else {
        _validTo = picked;
        _validToController.text = formatDdMmYyyy(picked);
      }
    });
  }

  /// Scans a license QR/barcode and prefills the fields below instead of
  /// requiring the surveyor to type them in by hand.
  Future<void> _scanQr() async {
    final code = await AppBarcodeScannerPage.open(
      context,
      title: 'Scan License QR',
      subtitle: 'Align the license QR/barcode within the frame',
    );
    if (code == null || !mounted) return;

    if (code.length > 2048) {
      AppSnackbar.error(context, 'QR code value is too long.');
      return;
    }

    setState(() => _isScanningQr = true);
    try {
      final data = await ref.read(premiseLicenseQrRepositoryProvider).fetchByLink(code);
      if (!mounted) return;
      _applyQrData(data);
    } on ApiResponseException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Failed to fetch license data from QR code.');
    } finally {
      if (mounted) setState(() => _isScanningQr = false);
    }
  }

  /// Mirrors legacy `PremisLicenseController.populateFromQr`: fills in only
  /// the fields the QR payload actually has, and only applies the date range
  /// when both ends parse — a malformed QR date must not leave one field set
  /// without the other.
  void _applyQrData(PremiseLicenseQrData data) {
    setState(() {
      final fileNo = data.licenseFileNo;
      if (fileNo != null && fileNo.isNotEmpty) {
        _licenseFileNoController.text = fileNo;
      }

      final status = data.licenseStatus;
      if (status != null && status.isNotEmpty) {
        _selectedStatus = GeneralModel(code: status, desc: status);
        _statusController.text = status;
      }

      final dateFrom = parseDdMmYyyy(data.licenseDateFrom);
      final dateTo = parseDdMmYyyy(data.licenseDateTo);
      if (dateFrom != null && dateTo != null) {
        _validFrom = dateFrom;
        _validTo = dateTo;
        _validFromController.text = formatDdMmYyyy(dateFrom);
        _validToController.text = formatDdMmYyyy(dateTo);
      }
    });
  }

  bool get _canAddItem => true;

  void _addItem() {
    final businessType = _actSelectedBusinessType;
    final status = _actSelectedStatus;

    final newItem = PremiseLicenseActivity(
      businessType: businessType?.code,
      businessTypeDesc: businessType == null ? null : generalLookupLabel(businessType),
      status: status?.code,
      statusDesc: status == null ? null : generalLookupLabel(status),
      description: _actDescriptionController.text.trim().isEmpty ? null : _actDescriptionController.text.trim(),
      amount: _actAmountController.text.trim().isEmpty ? null : _actAmountController.text.trim(),
      saveToBusiness: _actSaveToBusiness,
    );

    // Same business type + description + amount counts as a duplicate — the
    // pembanci can still add the same type at a *different* amount.
    final isDuplicate = _items.any(
      (existing) =>
          existing.businessType == newItem.businessType &&
          (existing.description ?? '').toLowerCase() == (newItem.description ?? '').toLowerCase() &&
          (existing.amount ?? '') == (newItem.amount ?? ''),
    );
    if (isDuplicate) {
      AppSnackbar.warning(context, 'This business activity already exists in the list.');
      return;
    }

    setState(() {
      _items = [..._items, newItem];
      _actSelectedBusinessType = null;
      _actSelectedStatus = null;
      _actBusinessTypeController.clear();
      _actStatusController.clear();
      _actDescriptionController.clear();
      _actAmountController.text = '0.00';
      _actSaveToBusiness = false;
    });
  }

  void _removeItem(int index) {
    setState(() => _items = [..._items]..removeAt(index));
  }

  void _toggleItemSaveBusiness(int index) {
    setState(() {
      final next = [..._items];
      next[index] = next[index].copyWith(saveToBusiness: !next[index].saveToBusiness);
      _items = next;
    });
  }

  /// Upserts every item flagged `saveToBusiness` into the Business Activity
  /// section (mirrors already-linked items instead of duplicating them),
  /// then writes the resulting link back onto each item.
  void _mirrorFlaggedToBusiness() {
    final controller = ref.read(premiseFormControllerProvider(widget.session).notifier);
    final next = [..._items];

    for (var i = 0; i < next.length; i++) {
      final item = next[i];
      if (!item.saveToBusiness) continue;

      final localId = controller.upsertMirroredBusinessActivity(
        localId: item.businessActivityLocalId,
        activity: PremiseBusinessActivity(
          businessType: item.businessType,
          businessTypeDesc: item.businessTypeDesc,
          status: item.status,
          statusDesc: item.statusDesc,
          description: item.description,
        ),
      );
      next[i] = item.copyWith(businessActivityLocalId: localId);
    }

    _items = next;
  }

  void save() {
    final status = _selectedStatus;

    _mirrorFlaggedToBusiness();

    final license = PremiseLicense(
      id: widget.initial?.id,
      localId: widget.initial?.localId,
      licenseNo: _licenseNoController.text.trim(),
      licenseFileNo: _licenseFileNoController.text.trim(),
      validFrom: formatDdMmYyyy(_validFrom),
      validTo: formatDdMmYyyy(_validTo),
      status: status?.code,
      statusDesc: status == null ? null : generalLookupLabel(status),
      businessActivities: _items,
    );

    final controller = ref.read(premiseFormControllerProvider(widget.session).notifier);
    if (widget.isEdit) {
      controller.updateLicenseAt(widget.index!, license);
    } else {
      controller.addLicense(license);
    }
    Navigator.of(context).pop();
  }

  Future<void> delete() async {
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Delete license?',
      message: 'This license will be removed from the form.',
      confirmLabel: 'Delete',
      confirmStyle: AppDialogActionStyle.destructive,
    );
    if (!confirmed || !mounted) return;

    ref.read(premiseFormControllerProvider(widget.session).notifier).removeLicenseAt(widget.index!);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statuses = ref.watch(premiseBusinessLicenseStatusesProvider).value ?? const <GeneralModel>[];
    final businessTypes = ref.watch(premiseBusinessTypesProvider).value ?? const <GeneralModel>[];

    return Form(
      key: _formKey,
      child: ListView(
        controller: widget.scrollController,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('License Detail', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              IconButton(
                icon: _isScanningQr
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.qr_code_scanner),
                tooltip: 'Scan QR code',
                onPressed: _isScanningQr ? null : _scanQr,
              ),
            ],
          ),
          const SizedBox(height: 4),
          AppTextField(
            label: 'License No.',
            controller: _licenseNoController,
            uppercase: true,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'License File No.',
            controller: _licenseFileNoController,
            uppercase: true,
          ),
          const SizedBox(height: 12),
          AppPickerField<GeneralModel>(
            label: 'Status',
            controller: _statusController,
            options: statuses,
            optionLabel: generalLookupLabel,
            sheetSubtitle: 'Select license status',
            onOptionSelected: _selectStatus,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppPickerField<DateTime>(
                  label: 'Valid From',
                  controller: _validFromController,
                  suffixIcon: Icons.calendar_month_outlined,
                  onTap: () => _pickDate(isFrom: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppPickerField<DateTime>(
                  label: 'Valid To',
                  controller: _validToController,
                  suffixIcon: Icons.calendar_month_outlined,
                  onTap: () => _pickDate(isFrom: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Business Activities', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text(
                '${_items.length} added',
                style: textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_items.isEmpty)
            Text(
              'No business activity added yet. Fill the fields below and tap Add to list.',
              style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
            )
          else
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _LicenseActivityCard(
                item: _items[i],
                onDelete: () => _removeItem(i),
                onToggleSaveToBusiness: () => _toggleItemSaveBusiness(i),
              ),
            ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPickerField<GeneralModel>(
                  label: 'Business Type',
                  controller: _actBusinessTypeController,
                  options: businessTypes,
                  optionLabel: generalLookupLabel,
                  sheetSubtitle: 'Select business type',
                  onOptionSelected: (item) => setState(() => _actSelectedBusinessType = item),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Description',
                  controller: _actDescriptionController,
                  uppercase: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                AppPickerField<GeneralModel>(
                  label: 'Status',
                  controller: _actStatusController,
                  options: statuses,
                  optionLabel: generalLookupLabel,
                  sheetSubtitle: 'Select status',
                  onOptionSelected: (item) => setState(() => _actSelectedStatus = item),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Amount (RM)',
                  controller: _actAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  onChanged: (_) => setState(() {}),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Save to Business Activity', style: textTheme.bodySmall),
                      ),
                      Switch.adaptive(
                        value: _actSaveToBusiness,
                        onChanged: (v) => setState(() => _actSaveToBusiness = v),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _canAddItem ? _addItem : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Add to list'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _LicenseActivityCard extends StatelessWidget {
  const _LicenseActivityCard({required this.item, required this.onDelete, required this.onToggleSaveToBusiness});

  final PremiseLicenseActivity item;
  final VoidCallback onDelete;
  final VoidCallback onToggleSaveToBusiness;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              item.businessTypeDesc ?? item.businessType ?? '-',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${item.statusDesc ?? item.status ?? '-'}  •  ${item.description ?? '-'}  •  RM ${item.amount ?? '0.00'}',
              style: textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: cs.error),
              onPressed: onDelete,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(child: Text('Save to Business Activity', style: textTheme.bodySmall)),
                Switch.adaptive(value: item.saveToBusiness, onChanged: (_) => onToggleSaveToBusiness()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
