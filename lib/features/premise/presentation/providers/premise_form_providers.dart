import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/data/mappers/premise_draft_mapper.dart';
import 'package:ilms/features/premise/data/mappers/premise_form_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_qr_data.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';
import 'package:ilms/features/premise/domain/exceptions/premise_exception.dart';
import 'package:ilms/features/premise/domain/entities/premise_draft_summary.dart';
import 'package:ilms/features/premise/domain/repositories/premise_draft_repository.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/providers/premise_detail_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_draft_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/features/premise/presentation/sections/premise_form_sections.dart';
import 'package:ilms/shared/constants/app_image_limits.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/shared/models/general_model.dart';

/// Result of a successful [PremiseFormController.submit] — enough for the
/// page to drive the post-submit photo upload sheet.
class PremiseSubmitOutcome {
  const PremiseSubmitOutcome({
    required this.visitNo,
    required this.process,
    required this.allCensusImages,
    required this.pendingImages,
  });

  final String visitNo;

  /// `'create'` or `'update'` — matches what `/create-photo` expects.
  final String process;

  /// Full census image list (server + local) — used to assign per-type seq
  /// numbers that continue past already-uploaded photos in edit mode.
  final List<PremiseCensusImage> allCensusImages;
  final List<PremiseCensusImage> pendingImages;
}

class PremiseFormController extends FamilyNotifier<PremiseFormState, PremiseFormSession> {
  late final PremiseFormFields fields;
  PremiseDraftPayloadModel _baselinePayload = PremiseDraftMapper.emptyPayload();

  /// Set when [submit] fails for a reason other than a blocked required
  /// section (e.g. a thrown [PremiseException]) — read by the page right
  /// after `submit()` resolves so it can show the real error instead of the
  /// generic "complete the required sections" message.
  String? lastSubmitError;

  /// Set when [submit] succeeds — the page reads this to know whether to
  /// show the photo upload sheet (showing upload progress needs a
  /// BuildContext, which the controller doesn't have).
  PremiseSubmitOutcome? lastSubmitOutcome;

  @override
  PremiseFormState build(PremiseFormSession session) {
    fields = PremiseFormFields();
    ref.onDispose(fields.dispose);
    return PremiseFormState(mode: session.mode, localDraftId: session.localDraftId);
  }

  PremiseFormFields get formFields => fields;

  PremiseDraftPayloadModel _currentPayload() {
    return PremiseDraftMapper.toPayload(fields: fields, state: state);
  }

  bool get hasUnsavedChanges => !PremiseDraftMapper.payloadsEqual(_baselinePayload, _currentPayload());

  bool get hasDraftContent => !PremiseDraftMapper.isEmptyPayload(_currentPayload());

  void _syncBaseline() {
    _baselinePayload = _currentPayload();
  }

  /// Returns `false` only when a server-backed session (opened via
  /// [PremiseFormSession.visitNo]) failed to load — the page uses that to
  /// bail out instead of showing a form with nothing in it.
  Future<bool> initialize(PremiseFormSession session) async {
    if (session.localDraftId != null) {
      await _loadDraft(session.localDraftId!);
      return true;
    }

    if (session.visitNo != null) {
      // A pending local unsaved edit for this exact record takes priority
      // over a fresh server fetch — otherwise re-opening the same item
      // after saving locally silently discarded the saved edit and always
      // showed the server's (now stale) copy again.
      final existingEdit = await ref.read(premiseDraftRepositoryProvider).loadEditSession(session.visitNo!);
      if (existingEdit != null) {
        return _resumeEditSession(existingEdit);
      }
      return _loadFromServer(session.visitNo!, mode: session.mode);
    }

    if (session.mode == PremiseFormMode.create) {
      _syncBaseline();
    }
    return true;
  }

  Future<bool> _resumeEditSession(PremiseDraftLoadResult loaded) async {
    state = state.copyWith(isDraftLoading: true);
    PremiseDraftMapper.applyPayload(
      fields: fields,
      payload: loaded.payload,
      currentState: state,
      updateState: (next) => state = next,
    );
    state = state.copyWith(
      isDraftLoading: false,
      mode: PremiseFormMode.edit,
      localDraftId: loaded.localDraftId,
      visitNo: loaded.visitNo,
      draftType: loaded.draftType,
    );
    _syncBaseline();
    return true;
  }

  /// Loads an existing premise straight from `/api/premiseCensus/detail` —
  /// used when opening a search/list result directly (view/edit), as opposed
  /// to resuming a local draft.
  Future<bool> _loadFromServer(String visitNo, {required PremiseFormMode mode}) async {
    state = state.copyWith(isDraftLoading: true);
    try {
      final payload = await ref.read(premiseDetailRepositoryProvider).getDetail(visitNo);
      PremiseDraftMapper.applyPayload(
        fields: fields,
        payload: payload,
        currentState: state,
        updateState: (next) => state = next,
      );
      state = state.copyWith(isDraftLoading: false, mode: mode, visitNo: visitNo);
      _syncBaseline();
      return true;
    } catch (e, st) {
      dev.log(
        'Failed to load premise detail for $visitNo: $e',
        name: 'PremiseFormController',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(isDraftLoading: false);
      return false;
    }
  }

  /// Switches an in-progress "view" session into edit mode in place —
  /// mirrors legacy's app-bar Edit action, keeping the loaded fields intact
  /// instead of re-fetching or re-navigating.
  void switchToEditMode() {
    if (state.mode != PremiseFormMode.view) return;
    state = state.copyWith(mode: PremiseFormMode.edit);
  }

  Future<void> _loadDraft(int localDraftId) async {
    state = state.copyWith(isDraftLoading: true);
    final loaded = await ref.read(premiseDraftRepositoryProvider).loadDraft(localDraftId);
    if (loaded == null) {
      state = state.copyWith(isDraftLoading: false);
      return;
    }

    PremiseDraftMapper.applyPayload(
      fields: fields,
      payload: loaded.payload,
      currentState: state,
      updateState: (next) => state = next,
    );

    state = state.copyWith(
      localDraftId: loaded.localDraftId,
      isDraftLoading: false,
      mode: PremiseFormMode.draft,
      visitNo: loaded.visitNo,
      draftType: loaded.draftType,
    );
    _syncBaseline();
  }

  void setActiveSection(int index) {
    if (index == state.activeSectionIndex) return;
    if (index < 0 || index >= premiseFormSections.length) return;
    state = state.copyWith(activeSectionIndex: index);
  }

  bool addCensusImage(PremiseCensusImage image, {int maxImages = AppImageLimits.defaultMaxImages}) {
    if (state.isReadOnly) return false;
    if (state.censusImages.length >= maxImages) return false;
    state = state.copyWith(censusImages: [...state.censusImages, image]);
    return true;
  }

  /// Removes the image at [index]. If it's already been uploaded (has a
  /// server `id`), deletes it via the API first — returns `false` and
  /// leaves the image in place if that call fails, so the caller can show
  /// an error without silently losing the photo from the record.
  Future<bool> removeCensusImageAt(int index) async {
    if (state.isReadOnly) return false;
    if (index < 0 || index >= state.censusImages.length) return false;

    final image = state.censusImages[index];
    final serverId = image.id;
    if (serverId != null) {
      try {
        await ref.read(premiseRepositoryProvider).deletePhoto(imageId: serverId.toString());
      } catch (_) {
        return false;
      }
    }

    final next = [...state.censusImages]..removeAt(index);
    state = state.copyWith(censusImages: next);
    return true;
  }

  void addRemark(PremiseRemark remark) {
    if (state.isReadOnly) return;
    state = state.copyWith(remarks: [...state.remarks, remark]);
  }

  void updateRemarkAt(int index, PremiseRemark remark) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.remarks.length) return;
    final next = [...state.remarks];
    next[index] = remark;
    state = state.copyWith(remarks: next);
  }

  void removeRemarkAt(int index) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.remarks.length) return;
    final next = [...state.remarks]..removeAt(index);
    state = state.copyWith(remarks: next);
  }

  void addLicense(PremiseLicense license) {
    if (state.isReadOnly) return;
    state = state.copyWith(licenses: [...state.licenses, license]);
  }

  void updateLicenseAt(int index, PremiseLicense license) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.licenses.length) return;
    final next = [...state.licenses];
    next[index] = license;
    state = state.copyWith(licenses: next);
  }

  void removeLicenseAt(int index) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.licenses.length) return;
    final next = [...state.licenses]..removeAt(index);
    state = state.copyWith(licenses: next);
  }

  void setAddresses(List<PremiseAddress> addresses) {
    if (state.isReadOnly) return;
    state = state.copyWith(addresses: addresses);
  }

  void addAddress(PremiseAddress address) {
    if (state.isReadOnly) return;
    state = state.copyWith(addresses: [...state.addresses, address]);
  }

  void updateAddressAt(int index, PremiseAddress address) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.addresses.length) return;
    final next = [...state.addresses];
    next[index] = address;
    state = state.copyWith(addresses: next);
  }

  void removeAddressAt(int index) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.addresses.length) return;
    final next = [...state.addresses]..removeAt(index);
    state = state.copyWith(addresses: next);
  }

  void addBusinessActivity(PremiseBusinessActivity activity) {
    if (state.isReadOnly) return;
    state = state.copyWith(businessActivities: [...state.businessActivities, activity]);
  }

  void updateBusinessActivityAt(int index, PremiseBusinessActivity activity) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.businessActivities.length) return;
    final next = [...state.businessActivities];
    next[index] = activity;
    state = state.copyWith(businessActivities: next);
  }

  void removeBusinessActivityAt(int index) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.businessActivities.length) return;
    final next = [...state.businessActivities]..removeAt(index);
    state = state.copyWith(businessActivities: next);
  }

  /// Adds or updates (by [localId]) a business activity mirrored from a
  /// license item's "Save to Business Activity" flag — re-saving the same
  /// license item updates its existing mirror instead of duplicating it.
  /// Returns the localId used (existing one if updated, freshly assigned if added).
  int upsertMirroredBusinessActivity({required int? localId, required PremiseBusinessActivity activity}) {
    final existingIndex = localId == null ? -1 : state.businessActivities.indexWhere((a) => a.localId == localId);
    if (existingIndex != -1) {
      updateBusinessActivityAt(existingIndex, activity.copyWith(localId: localId));
      return localId!;
    }

    final newLocalId = state.businessActivities.fold<int>(0, (max, a) => (a.localId ?? 0) > max ? a.localId! : max) + 1;
    addBusinessActivity(activity.copyWith(localId: newLocalId));
    return newLocalId;
  }

  /// Marks the visit as a vacant premise (legacy `fillVacantDefaults`):
  /// company/contact/trader fields are known-N/A, while the address and
  /// business/premise type are cleared so the surveyor enters the real
  /// values for the vacant unit instead of carrying over the previous entry.
  void markVacant() {
    if (state.isReadOnly) return;

    const na = 'N/A';
    fields.companyName.text = na;
    fields.registerNumber.text = na;
    fields.companyTelNo.text = na;
    fields.companyFaxNo.text = na;
    fields.contactPersonName.text = na;
    fields.contactPersonPhone.text = na;
    fields.contactPersonEmail.text = na;
    fields.contactPersonPosition.text = na;
    fields.traderName.text = na;

    fields.unit.clear();
    fields.building.clear();
    fields.street1.clear();
    fields.street2.clear();
    fields.postcode.clear();
    fields.area.clear();
    fields.businessType.clear();
    fields.premiseType.clear();

    state = state.copyWith(isVacant: true, draftType: PremiseDraftType.vacant, clearCompanyPostcode: true);
  }

  void selectVisitStatus(GeneralModel item) {
    if (state.isReadOnly) return;
    state = state.copyWith(visitStatus: item.code, visitStatusDesc: generalLookupLabel(item));
  }

  Future<bool> saveDraft({bool silent = false}) async {
    if (state.isReadOnly) return false;

    if (!hasDraftContent) {
      if (state.localDraftId != null) {
        await deleteDraft();
      }
      return true;
    }

    if (!silent) {
      state = state.copyWith(isDraftSaving: true);
    }
    try {
      final payload = PremiseDraftMapper.toPayload(fields: fields, state: state);
      final id = await ref
          .read(premiseDraftRepositoryProvider)
          .saveDraft(
            localDraftId: state.localDraftId,
            payload: payload,
            companyName: PremiseDraftMapper.displayCompanyName(fields),
            traderName: PremiseDraftMapper.displayTraderName(fields),
            // Preserves the link back to the server record this session was
            // opened from (view/edit flow) — omitting it silently dropped
            // that link on every save.
            visitNo: state.visitNo,
            // Edits to an existing, already-synced record are not the same
            // thing as an unfinished new-entry draft — kept out of the
            // Drafts list (watchDrafts already filters isEditSession).
            isEditSession: state.mode == PremiseFormMode.edit,
            draftType: state.draftType,
          );
      state = state.copyWith(
        localDraftId: id,
        isDraftSaving: silent ? state.isDraftSaving : false,
        // An edit session stays "edit" — collapsing it into PremiseFormMode
        // .draft would relabel it as an unfinished new entry internally,
        // undermining the isEditSession distinction above.
        mode: state.mode == PremiseFormMode.edit ? state.mode : PremiseFormMode.draft,
      );
      _syncBaseline();
      return true;
    } catch (e, st) {
      // Previously swallowed with no trace at all, so every failure here
      // looked identical from the outside — always "Failed to save draft."
      // with nothing in the logs to say why.
      dev.log('saveDraft() failed: $e', name: 'PremiseFormController', error: e, stackTrace: st);
      if (!silent) {
        state = state.copyWith(isDraftSaving: false);
      }
      return false;
    }
  }

  void selectCompanyState(GeneralModel item) {
    if (state.isReadOnly) return;
    applyGeneralLookupSelection(controller: fields.state, item: item);
    fields.postcode.clear();
    fields.area.clear();
    state = state.copyWith(companyStateCode: item.code, clearCompanyPostcode: true);
  }

  void selectCompanyPostcode(GeneralModel item) {
    if (state.isReadOnly) return;
    applyGeneralLookupSelection(controller: fields.postcode, item: item, label: generalPostcodeLabel);
    fields.area.clear();
    state = state.copyWith(companyPostcode: item.code);
  }

  void selectCompanyArea(GeneralModel item) {
    if (state.isReadOnly) return;
    applyGeneralLookupSelection(controller: fields.area, item: item);
  }

  /// Prefills Company & Contact from a license QR lookup — mirrors legacy
  /// `_mapQrToInputModel` mapping of holder name and registration no.
  void applyCompanyFromLicenseQr(PremiseLicenseQrData data) {
    if (state.isReadOnly) return;

    final holder = data.licenseHolderName?.trim();
    if (holder != null && holder.isNotEmpty) {
      fields.companyName.text = holder;
    }

    final regNo = data.companyRegistrationNo?.trim();
    if (regNo != null && regNo.isNotEmpty) {
      fields.registerNumber.text = regNo;
    }
  }

  /// Copies a selected premise address into the Company Address fields
  /// (Section 1) — used by the "Set as Company Address" action on address tiles.
  Future<void> applyCompanyAddressFromPremise(PremiseAddress address) async {
    if (state.isReadOnly) return;

    fields.unit.text = address.unitNo ?? '';
    fields.building.text = address.building ?? '';
    fields.street1.text = address.streetName ?? '';
    fields.street2.clear();

    final repository = ref.read(generalLookupRepositoryProvider);

    if (address.state != null && address.state!.trim().isNotEmpty) {
      final states = await repository.getStates();
      final stateItem =
          _lookupByCode(states, address.state!.trim()) ?? GeneralModel(code: address.state, desc: address.state);
      selectCompanyState(stateItem);
    }

    if (address.postcode != null && address.postcode!.trim().isNotEmpty && state.companyStateCode != null) {
      final postcodes = await repository.getPostcodes(stateCode: state.companyStateCode);
      final postcodeItem =
          _lookupByCode(postcodes, address.postcode!.trim()) ??
          GeneralModel(code: address.postcode, desc: address.postcode);
      selectCompanyPostcode(postcodeItem);
    }

    if (address.area != null && address.area!.trim().isNotEmpty && state.companyStateCode != null) {
      final areas = await repository.getAreas(stateCode: state.companyStateCode, postcode: state.companyPostcode);
      final areaCode = address.area!.trim();
      final areaItem =
          _lookupByCode(areas, areaCode) ??
          _lookupByDesc(areas, areaCode) ??
          GeneralModel(code: areaCode, desc: areaCode);
      selectCompanyArea(areaItem);
    }
  }

  GeneralModel? _lookupByCode(List<GeneralModel> items, String code) {
    for (final item in items) {
      if (item.code == code) return item;
    }
    return null;
  }

  GeneralModel? _lookupByDesc(List<GeneralModel> items, String desc) {
    final normalized = desc.toLowerCase();
    for (final item in items) {
      if (item.desc?.toLowerCase() == normalized) return item;
    }
    return null;
  }

  void selectBusinessType(GeneralModel item) {
    if (state.isReadOnly) return;
    applyGeneralLookupSelection(controller: fields.businessType, item: item);
  }

  void selectPremiseType(GeneralModel item) {
    if (state.isReadOnly) return;
    applyGeneralLookupSelection(controller: fields.premiseType, item: item);
  }

  Future<void> deleteDraft() async {
    final draftId = state.localDraftId;
    if (draftId != null) {
      await ref.read(premiseDraftRepositoryProvider).deleteDraft(draftId);
    }
    // `localDraftId: null` alone is a no-op — copyWith's null-coalescing
    // pattern can't distinguish "clear this" from "leave unchanged" without
    // the explicit flag.
    state = state.copyWith(clearLocalDraftId: true);
    _syncBaseline();
  }

  /// Deletes the pending local edit for this record and reloads the current
  /// server version in its place, discarding any unsaved local changes and
  /// returning to read-only view mode.
  Future<bool> discardEditSession() async {
    if (state.mode != PremiseFormMode.edit) return false;

    final visitNo = state.visitNo;
    final draftId = state.localDraftId;
    if (draftId != null) {
      await ref.read(premiseDraftRepositoryProvider).deleteDraft(draftId);
    }
    state = state.copyWith(clearLocalDraftId: true);

    if (visitNo == null) return true;
    return _loadFromServer(visitNo, mode: PremiseFormMode.view);
  }

  Future<bool> saveDraftOnExit() async {
    if (!hasDraftContent) {
      if (state.localDraftId != null) {
        await deleteDraft();
      }
      return true;
    }
    return saveDraft(silent: true);
  }

  Future<bool> submit() async {
    if (state.isReadOnly || state.isSubmitting) return false;
    lastSubmitError = null;

    final minImages = AppImageLimits.premiseMinCensusImages;
    if (state.censusImages.length < minImages) {
      lastSubmitError = 'Please add at least $minImages census photos before submitting.';
      final imagesIndex = premiseFormSections.indexWhere((section) => section.id == 'images');
      if (imagesIndex != -1) {
        state = state.copyWith(activeSectionIndex: imagesIndex);
      }
      return false;
    }

    if (state.visitStatus == null || state.visitStatus!.isEmpty) {
      lastSubmitError = 'Please choose a visit status before submitting.';
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final form = PremiseFormMapper.fromPresentation(
        fields: fields,
        censusImages: state.censusImages,
        remarks: state.remarks,
        licenses: state.licenses,
        businessActivities: state.businessActivities,
        addresses: state.addresses,
        localDraftId: state.localDraftId,
        visitStatus: state.visitStatus,
        visitStatusDesc: state.visitStatusDesc,
        // A resumed draft that already succeeded once (visitNo set, photos
        // still pending) must submit as an UPDATE — otherwise this would
        // create a duplicate premise record on the server every retry.
        visitNo: state.visitNo,
      );
      final repository = ref.read(premiseRepositoryProvider);
      final result = form.isUpdate ? await repository.submitUpdate(form) : await repository.submitCreate(form);

      final pendingImages = state.censusImages.where((image) => image.isLocalOnly).toList();

      // Keep the local draft row alive (unsynced) with the server visitNo
      // attached — `finalizeSubmit` only marks it synced once photo upload
      // (driven by the page's sheet) actually finishes. If the user bails
      // with photos still pending, this is what keeps the draft "tightly
      // linked" to the now-created premise record instead of orphaning it.
      final draftId = state.localDraftId;
      if (draftId != null) {
        final payload = PremiseDraftMapper.toPayload(fields: fields, state: state);
        await ref
            .read(premiseDraftRepositoryProvider)
            .saveDraft(
              localDraftId: draftId,
              payload: payload,
              companyName: PremiseDraftMapper.displayCompanyName(fields),
              traderName: PremiseDraftMapper.displayTraderName(fields),
              visitNo: result.visitNo,
              draftType: state.draftType,
            );
      }

      lastSubmitOutcome = PremiseSubmitOutcome(
        visitNo: result.visitNo,
        process: form.isUpdate ? 'update' : 'create',
        allCensusImages: state.censusImages,
        pendingImages: pendingImages,
      );

      state = state.copyWith(isSubmitting: false, visitNo: result.visitNo);
      return true;
    } catch (e, st) {
      // Was previously surfaced by the caller as "Please complete the
      // required sections." — same as a blocked-section failure — so a
      // network/mapping bug looked identical to a missing field. Now
      // exposed via `lastSubmitError` so the page can show the real cause.
      dev.log('submit() threw after validation passed: $e', name: 'PremiseFormController', error: e, stackTrace: st);
      lastSubmitError = e is PremiseException ? e.message : 'Failed to submit premise census.';
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }

  /// Called by the page once it knows the photo-upload outcome for the
  /// [PremiseSubmitOutcome] from the preceding [submit] call. Only marks the
  /// local draft synced (removing it from the resumable Drafts list) once
  /// every photo actually uploaded — otherwise the draft stays as [submit]
  /// left it: unsynced, with `visitNo` attached, ready to resume.
  Future<void> finalizeSubmit({required bool allUploaded}) async {
    if (!allUploaded) return;
    final draftId = state.localDraftId;
    if (draftId == null) return;
    await ref.read(premiseDraftRepositoryProvider).markDraftSynced(draftId);
  }
}

final premiseFormControllerProvider =
    NotifierProvider.family<PremiseFormController, PremiseFormState, PremiseFormSession>(PremiseFormController.new);

final premiseFormFieldsProvider = Provider.family<PremiseFormFields, PremiseFormSession>((ref, session) {
  ref.watch(premiseFormControllerProvider(session));
  return ref.read(premiseFormControllerProvider(session).notifier).formFields;
});

class PremiseFormScope extends InheritedWidget {
  const PremiseFormScope({super.key, required this.session, required super.child});

  final PremiseFormSession session;

  static PremiseFormSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PremiseFormScope>();
    assert(scope != null, 'PremiseFormScope not found in widget tree.');
    return scope!.session;
  }

  @override
  bool updateShouldNotify(PremiseFormScope oldWidget) => session != oldWidget.session;
}
