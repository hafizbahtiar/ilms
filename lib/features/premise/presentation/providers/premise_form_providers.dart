import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/data/mappers/premise_draft_mapper.dart';
import 'package:ilms/features/premise/data/mappers/premise_form_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/providers/premise_draft_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_providers.dart';
import 'package:ilms/features/premise/presentation/sections/premise_form_sections.dart';
import 'package:ilms/shared/constants/app_image_limits.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';

class PremiseFormController extends FamilyNotifier<PremiseFormState, PremiseFormSession> {
  late final PremiseFormFields fields;
  PremiseDraftPayloadModel _baselinePayload = PremiseDraftMapper.emptyPayload();

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

  Future<void> initialize(PremiseFormSession session) async {
    if (session.localDraftId != null) {
      await _loadDraft(session.localDraftId!);
      return;
    }

    if (session.mode == PremiseFormMode.create) {
      _syncBaseline();
    }
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

  void removeCensusImageAt(int index) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.censusImages.length) return;
    final next = [...state.censusImages]..removeAt(index);
    state = state.copyWith(censusImages: next);
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
      final id = await ref.read(premiseDraftRepositoryProvider).saveDraft(
            localDraftId: state.localDraftId,
            payload: payload,
            companyName: PremiseDraftMapper.displayCompanyName(fields),
            traderName: PremiseDraftMapper.displayTraderName(fields),
          );
      state = state.copyWith(
        localDraftId: id,
        isDraftSaving: silent ? state.isDraftSaving : false,
        mode: PremiseFormMode.draft,
      );
      _syncBaseline();
      return true;
    } catch (_) {
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
    state = state.copyWith(localDraftId: null);
    _syncBaseline();
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

    final validators = [
      fields.companyFormKey,
      fields.detailsFormKey,
    ];

    var firstInvalid = -1;
    for (var i = 0; i < validators.length; i++) {
      final valid = validators[i].currentState?.validate() ?? false;
      if (!valid && firstInvalid == -1) firstInvalid = i;
    }

    if (firstInvalid != -1) {
      state = state.copyWith(activeSectionIndex: firstInvalid);
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final form = PremiseFormMapper.fromPresentation(
        fields: fields,
        censusImages: state.censusImages,
        localDraftId: state.localDraftId,
      );
      final repository = ref.read(premiseRepositoryProvider);
      final result = form.isUpdate ? await repository.submitUpdate(form) : await repository.submitCreate(form);

      if (result.pendingImageUploads > 0) {
        await repository.uploadPendingImages(
          visitNo: result.visitNo,
          form: form.copyWith(visitNo: result.visitNo),
          process: form.isUpdate ? 'update' : 'create',
        );
      }

      final draftId = state.localDraftId;
      if (draftId != null) {
        await ref.read(premiseDraftRepositoryProvider).markDraftSynced(draftId);
      }

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

final premiseFormControllerProvider =
    NotifierProvider.family<PremiseFormController, PremiseFormState, PremiseFormSession>(
  PremiseFormController.new,
);

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
