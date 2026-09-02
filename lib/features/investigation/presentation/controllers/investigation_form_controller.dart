import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_business_activity.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minutes_entry.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_photo.dart';
import 'package:ilms/features/investigation/domain/exceptions/investigation_exception.dart';
import 'package:ilms/features/investigation/presentation/controllers/investigation_form_state.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_draft_providers.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_providers.dart';
import 'package:ilms/features/investigation/presentation/sections/investigation_form_sections.dart';

class InvestigationFormController extends FamilyNotifier<InvestigationFormState, InvestigationFormSession> {
  late final InvestigationFormFields fields;

  /// Set when [submit] fails — read by the page right after `submit()`
  /// resolves so it can show the real error message.
  String? lastSubmitError;

  @override
  InvestigationFormState build(InvestigationFormSession session) {
    fields = InvestigationFormFields();
    ref.onDispose(fields.dispose);
    return InvestigationFormState(mode: session.mode);
  }

  InvestigationFormFields get formFields => fields;

  /// Loads the server record, then overlays a local edit-session draft if
  /// one exists for this investigation. Returns `false` only when the
  /// server record itself failed to load.
  Future<bool> initialize(InvestigationFormSession session) async {
    state = state.copyWith(isLoading: true);
    try {
      final details = await ref.read(investigationDetailRepositoryProvider).getDetail(session.investigationNo);
      final draft = await ref.read(investigationDraftRepositoryProvider).getDraft(session.investigationNo);

      if (draft != null) {
        _applyDetails(draft, mode: session.mode, resumedFromDraft: true);
      } else {
        _applyDetails(details, mode: session.mode, resumedFromDraft: false);
      }
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      dev.log(
        'Failed to load investigation detail for ${session.investigationNo}: $e',
        name: 'InvestigationFormController',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  void _applyDetails(
    InvestigationDetails details, {
    required InvestigationFormMode mode,
    required bool resumedFromDraft,
  }) {
    fields.premisePosition.text = details.premiseDetails.premisePosition ?? '';
    fields.premiseLeft.text = details.premiseDetails.premiseLeft ?? '';
    fields.premiseRight.text = details.premiseDetails.premiseRight ?? '';
    fields.premiseAbove.text = details.premiseDetails.premiseAbove ?? '';
    fields.premiseBelow.text = details.premiseDetails.premiseBelow ?? '';
    fields.buildingType.text = details.premiseDetails.buildingType ?? '';
    fields.level.text = details.premiseDetails.level ?? '';
    fields.buildingStatus.text = details.premiseDetails.buildingStatus ?? '';
    fields.premiseLength.text = details.premiseDetails.premiseLength ?? '';
    fields.premiseWidth.text = details.premiseDetails.premiseWidth ?? '';
    fields.similarPremisesCount.text = details.premiseDetails.similarPremisesCount ?? '';

    fields.floorLength.text = details.businessActivity.floorLength ?? '';
    fields.floorWidth.text = details.businessActivity.floorWidth ?? '';
    fields.openingTime.text = details.businessActivity.openingTime ?? '';
    fields.closingTime.text = details.businessActivity.closingTime ?? '';

    fields.chairCount.text = details.pollutionDisturbance.chairCount ?? '';
    fields.tableCount.text = details.pollutionDisturbance.tableCount ?? '';
    fields.stallCount.text = details.pollutionDisturbance.stallCount ?? '';
    fields.machineCount.text = details.pollutionDisturbance.machineCount ?? '';
    fields.hairSalonChairCount.text = details.pollutionDisturbance.hairSalonChairCount ?? '';
    fields.roomCount.text = details.pollutionDisturbance.roomCount ?? '';
    fields.studentCount.text = details.pollutionDisturbance.studentCount ?? '';
    fields.petrolLiters.text = details.pollutionDisturbance.petrolLiters ?? '';
    fields.dieselLiters.text = details.pollutionDisturbance.dieselLiters ?? '';
    fields.gasLiters.text = details.pollutionDisturbance.gasLiters ?? '';
    fields.otherActivities.text = details.pollutionDisturbance.otherActivities ?? '';

    fields.advertisementLocation.text = details.advertisement.location ?? '';
    fields.advertisementNonCompliantReason.text = details.advertisement.nonCompliantReason ?? '';

    final entry = details.minutesEntry;
    fields.minutesDate.text = entry.investigationDate == null ? '' : _formatDate(entry.investigationDate!);
    fields.minutesTime.text = entry.investigationTime ?? '';
    fields.minutesPreparedBy.text = entry.preparedBy ?? '';
    fields.minutesText.text = entry.minutes ?? '';

    state = state.copyWith(
      mode: mode,
      isResumedFromDraft: resumedFromDraft,
      applicant: details.applicant,
      location: details.location,
      premiseDetails: details.premiseDetails,
      businessActivity: details.businessActivity,
      pollutionDisturbance: details.pollutionDisturbance,
      advertisement: details.advertisement,
      photos: details.photos,
      minutes: details.minutes,
      minutesEntry: details.minutesEntry,
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Switches an in-progress "view" session into edit mode in place.
  void switchToEditMode() {
    if (state.mode != InvestigationFormMode.view) return;
    state = state.copyWith(mode: InvestigationFormMode.edit);
  }

  void setActiveSection(int index) {
    if (index == state.activeSectionIndex) return;
    if (index < 0 || index >= investigationFormSections.length) return;
    state = state.copyWith(activeSectionIndex: index);
  }

  // ---- Maklumat Premis ----

  void setPremiseModification(bool value) {
    if (state.isReadOnly) return;
    state = state.copyWith(premiseDetails: state.premiseDetails.copyWith(premiseModification: value));
  }

  void selectPremisePosition(String value) {
    if (state.isReadOnly) return;
    state = state.copyWith(premiseDetails: state.premiseDetails.copyWith(premisePosition: value));
  }

  void selectBuildingType(String value) {
    if (state.isReadOnly) return;
    state = state.copyWith(premiseDetails: state.premiseDetails.copyWith(buildingType: value));
  }

  void selectLevel(String value) {
    if (state.isReadOnly) return;
    state = state.copyWith(premiseDetails: state.premiseDetails.copyWith(level: value));
  }

  void selectBuildingStatus(String value) {
    if (state.isReadOnly) return;
    state = state.copyWith(premiseDetails: state.premiseDetails.copyWith(buildingStatus: value));
  }

  // ---- Pollution / Disturbance ----

  void setPlacingFurniture(bool value) {
    if (state.isReadOnly) return;
    state = state.copyWith(pollutionDisturbance: state.pollutionDisturbance.copyWith(placingFurniture: value));
  }

  // ---- Advertisement ----

  void setAdvertisementDisplayed(bool value) {
    if (state.isReadOnly) return;
    state = state.copyWith(advertisement: state.advertisement.copyWith(displayed: value));
  }

  void setAdvertisementCompliant(bool value) {
    if (state.isReadOnly) return;
    state = state.copyWith(advertisement: state.advertisement.copyWith(compliant: value));
  }

  void setMalayLanguage(bool value) {
    if (state.isReadOnly) return;
    state = state.copyWith(advertisement: state.advertisement.copyWith(malayLanguage: value));
  }

  void setSizeCompliant(bool value) {
    if (state.isReadOnly) return;
    state = state.copyWith(advertisement: state.advertisement.copyWith(sizeCompliant: value));
  }

  void setSpellingCompliant(bool value) {
    if (state.isReadOnly) return;
    state = state.copyWith(advertisement: state.advertisement.copyWith(spellingCompliant: value));
  }

  // ---- Photos ----

  void addPhoto(InvestigationPhoto photo) {
    if (state.isReadOnly) return;
    state = state.copyWith(photos: [...state.photos, photo]);
  }

  void removePhotoAt(int index) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.photos.length) return;
    final next = [...state.photos]..removeAt(index);
    state = state.copyWith(photos: next);
  }

  // ---- Minutes ----

  void setMinutesDate(DateTime date) {
    if (state.isReadOnly) return;
    state = state.copyWith(minutesEntry: state.minutesEntry.copyWith(investigationDate: date));
  }

  void setMinutesTime(String value) {
    if (state.isReadOnly) return;
    state = state.copyWith(minutesEntry: state.minutesEntry.copyWith(investigationTime: value));
  }

  bool get isMinutesValid => _buildMinutesEntry().isValid;

  InvestigationMinutesEntry _buildMinutesEntry() {
    return state.minutesEntry.copyWith(
      investigationTime: fields.minutesTime.text,
      preparedBy: fields.minutesPreparedBy.text,
      minutes: fields.minutesText.text,
    );
  }

  // ---- Draft (Save & Exit) ----

  InvestigationDetails _snapshot() {
    return InvestigationDetails(
      investigationNo: arg.investigationNo,
      applicant: state.applicant,
      location: state.location,
      premiseDetails: state.premiseDetails.copyWith(
        premisePosition: fields.premisePosition.text,
        premiseLeft: fields.premiseLeft.text,
        premiseRight: fields.premiseRight.text,
        premiseAbove: fields.premiseAbove.text,
        premiseBelow: fields.premiseBelow.text,
        buildingType: fields.buildingType.text,
        level: fields.level.text,
        buildingStatus: fields.buildingStatus.text,
        premiseLength: fields.premiseLength.text,
        premiseWidth: fields.premiseWidth.text,
        similarPremisesCount: fields.similarPremisesCount.text,
      ),
      businessActivity: InvestigationBusinessActivity(
        floorLength: fields.floorLength.text,
        floorWidth: fields.floorWidth.text,
        openingTime: fields.openingTime.text,
        closingTime: fields.closingTime.text,
      ),
      pollutionDisturbance: state.pollutionDisturbance.copyWith(
        chairCount: fields.chairCount.text,
        tableCount: fields.tableCount.text,
        stallCount: fields.stallCount.text,
        machineCount: fields.machineCount.text,
        hairSalonChairCount: fields.hairSalonChairCount.text,
        roomCount: fields.roomCount.text,
        studentCount: fields.studentCount.text,
        petrolLiters: fields.petrolLiters.text,
        dieselLiters: fields.dieselLiters.text,
        gasLiters: fields.gasLiters.text,
        otherActivities: fields.otherActivities.text,
      ),
      advertisement: state.advertisement.copyWith(
        location: fields.advertisementLocation.text,
        nonCompliantReason: fields.advertisementNonCompliantReason.text,
      ),
      photos: state.photos,
      minutes: state.minutes,
      minutesEntry: _buildMinutesEntry().copyWith(
        investigationDate: DateTime.tryParse(fields.minutesDate.text) ?? state.minutesEntry.investigationDate,
      ),
    );
  }

  Future<void> saveDraft() async {
    await ref.read(investigationDraftRepositoryProvider).saveDraft(_snapshot());
  }

  Future<void> discardDraft() async {
    await ref.read(investigationDraftRepositoryProvider).discardDraft(arg.investigationNo);
  }

  // ---- Submit ----

  Future<bool> submit() async {
    if (state.isReadOnly || state.isSubmitting) return false;
    lastSubmitError = null;
    state = state.copyWith(isSubmitting: true);

    try {
      final details = _snapshot();
      final repository = ref.read(investigationRepositoryProvider);
      await repository.update(details);

      final newPhotos = details.photos.where((p) => p.bytes != null).toList();
      for (var i = 0; i < newPhotos.length; i++) {
        final photo = newPhotos[i];
        await repository.uploadPhoto(
          investigationNo: details.investigationNo,
          sequence: photo.sequence ?? (details.photos.length + i),
          bytes: photo.bytes!,
        );
      }

      await ref.read(investigationDraftRepositoryProvider).discardDraft(arg.investigationNo);

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e, st) {
      dev.log('submit() failed: $e', name: 'InvestigationFormController', error: e, stackTrace: st);
      lastSubmitError = e is InvestigationException ? e.message : 'Failed to submit investigation.';
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}
