import 'package:flutter/material.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_draft_summary.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';

enum PremiseFormMode { create, draft, view, edit, duplicate }

extension PremiseFormModeX on PremiseFormMode {
  bool get isReadOnly => this == PremiseFormMode.view;

  static PremiseFormMode fromQuery(String? value) {
    return switch (value) {
      'draft' => PremiseFormMode.draft,
      'view' => PremiseFormMode.view,
      'edit' => PremiseFormMode.edit,
      'duplicate' => PremiseFormMode.duplicate,
      _ => PremiseFormMode.create,
    };
  }
}

@immutable
class PremiseFormSession {
  const PremiseFormSession({
    required this.mode,
    this.localDraftId,
    this.instanceKey,
    this.isVacantIntent = false,
    this.visitNo,
  });

  final PremiseFormMode mode;
  final int? localDraftId;

  /// Distinguishes fresh "New Entry" opens so Riverpod does not reuse stale form state.
  final String? instanceKey;

  /// Set when this session was opened via the "Vacant" quick-add option —
  /// the page auto-applies [PremiseFormController.markVacant] once the
  /// session finishes initializing, instead of requiring the surveyor to
  /// find it under More → Mark Vacant.
  final bool isVacantIntent;

  /// Server visit number to load straight from `/api/premiseCensus/detail`
  /// when opening an existing record directly from a search/list result —
  /// distinct from [localDraftId], which loads from the local drafts table.
  final String? visitNo;

  bool get isTransient =>
      mode == PremiseFormMode.create || mode == PremiseFormMode.draft || mode == PremiseFormMode.duplicate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiseFormSession &&
          other.mode == mode &&
          other.localDraftId == localDraftId &&
          other.instanceKey == instanceKey &&
          other.visitNo == visitNo;

  @override
  int get hashCode => Object.hash(mode, localDraftId, instanceKey, visitNo);
}

class PremiseFormState {
  const PremiseFormState({
    required this.mode,
    this.localDraftId,
    this.activeSectionIndex = 0,
    this.isSubmitting = false,
    this.isDraftSaving = false,
    this.isDraftLoading = false,
    this.censusImages = const [],
    this.remarks = const [],
    this.licenses = const [],
    this.businessActivities = const [],
    this.addresses = const [],
    this.companyStateCode,
    this.companyPostcode,
    this.isVacant = false,
    this.draftType = PremiseDraftType.newEntry,
    this.visitStatus,
    this.visitStatusDesc,
    this.visitNo,
  });

  final PremiseFormMode mode;
  final int? localDraftId;

  /// Server-assigned visit number, set once a create/update actually
  /// succeeds. Even if photo upload then fails and the user bails, this
  /// stays on the (still-unsynced) local draft so a later resume submits as
  /// an UPDATE instead of creating a duplicate premise record.
  final String? visitNo;
  final int activeSectionIndex;
  final bool isSubmitting;
  final bool isDraftSaving;
  final bool isDraftLoading;
  final List<PremiseCensusImage> censusImages;
  final List<PremiseRemark> remarks;
  final List<PremiseLicense> licenses;
  final List<PremiseBusinessActivity> businessActivities;
  final List<PremiseAddress> addresses;
  final String? companyStateCode;
  final String? companyPostcode;
  final bool isVacant;

  /// How this draft was created — preserved from the loaded row (or set by
  /// [markVacant]) and passed back unchanged on every save, so it isn't lost
  /// after the first autosave. Never re-derived from [isVacant] alone: that
  /// would silently relabel a "duplicate" draft as "newEntry" on next save.
  final PremiseDraftType draftType;

  /// Picked via the "Choose Visit Status" step right before submit.
  final String? visitStatus;
  final String? visitStatusDesc;

  bool get isReadOnly => mode.isReadOnly;

  PremiseFormState copyWith({
    PremiseFormMode? mode,
    int? localDraftId,
    int? activeSectionIndex,
    bool? isSubmitting,
    bool? isDraftSaving,
    bool? isDraftLoading,
    List<PremiseCensusImage>? censusImages,
    List<PremiseRemark>? remarks,
    List<PremiseLicense>? licenses,
    List<PremiseBusinessActivity>? businessActivities,
    List<PremiseAddress>? addresses,
    String? companyStateCode,
    String? companyPostcode,
    bool clearCompanyPostcode = false,
    bool clearLocalDraftId = false,
    bool? isVacant,
    PremiseDraftType? draftType,
    String? visitStatus,
    String? visitStatusDesc,
    String? visitNo,
  }) {
    return PremiseFormState(
      mode: mode ?? this.mode,
      localDraftId: clearLocalDraftId ? null : (localDraftId ?? this.localDraftId),
      activeSectionIndex: activeSectionIndex ?? this.activeSectionIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDraftSaving: isDraftSaving ?? this.isDraftSaving,
      isDraftLoading: isDraftLoading ?? this.isDraftLoading,
      censusImages: censusImages ?? this.censusImages,
      remarks: remarks ?? this.remarks,
      licenses: licenses ?? this.licenses,
      businessActivities: businessActivities ?? this.businessActivities,
      addresses: addresses ?? this.addresses,
      companyStateCode: companyStateCode ?? this.companyStateCode,
      companyPostcode: clearCompanyPostcode ? null : (companyPostcode ?? this.companyPostcode),
      isVacant: isVacant ?? this.isVacant,
      draftType: draftType ?? this.draftType,
      visitStatus: visitStatus ?? this.visitStatus,
      visitStatusDesc: visitStatusDesc ?? this.visitStatusDesc,
      visitNo: visitNo ?? this.visitNo,
    );
  }
}

/// Text controllers grouped by legacy premis section (for now).
class PremiseFormFields {
  PremiseFormFields() {
    // Company & contact — legacy PremisCompDetailsSection
    companyName = TextEditingController();
    registerNumber = TextEditingController();
    companyTelNo = TextEditingController();
    companyFaxNo = TextEditingController();
    stickerNo = TextEditingController();
    censusDate = TextEditingController();
    unit = TextEditingController();
    building = TextEditingController();
    street1 = TextEditingController();
    street2 = TextEditingController();
    state = TextEditingController();
    postcode = TextEditingController();
    area = TextEditingController();
    contactPersonName = TextEditingController();
    contactPersonPhone = TextEditingController();
    contactPersonEmail = TextEditingController();
    contactPersonPosition = TextEditingController();

    // Premise details — legacy PremisDetailSection
    traderName = TextEditingController();
    businessType = TextEditingController();
    premiseType = TextEditingController();
    width = TextEditingController();
    length = TextEditingController();
  }

  late final TextEditingController companyName;
  late final TextEditingController registerNumber;
  late final TextEditingController companyTelNo;
  late final TextEditingController companyFaxNo;
  late final TextEditingController stickerNo;
  late final TextEditingController censusDate;
  late final TextEditingController unit;
  late final TextEditingController building;
  late final TextEditingController street1;
  late final TextEditingController street2;
  late final TextEditingController state;
  late final TextEditingController postcode;
  late final TextEditingController area;
  late final TextEditingController contactPersonName;
  late final TextEditingController contactPersonPhone;
  late final TextEditingController contactPersonEmail;
  late final TextEditingController contactPersonPosition;

  late final TextEditingController traderName;
  late final TextEditingController businessType;
  late final TextEditingController premiseType;
  late final TextEditingController width;
  late final TextEditingController length;

  final companyFormKey = GlobalKey<FormState>();
  final detailsFormKey = GlobalKey<FormState>();
  final addressFormKey = GlobalKey<FormState>();

  void dispose() {
    for (final controller in [
      companyName,
      registerNumber,
      companyTelNo,
      companyFaxNo,
      stickerNo,
      censusDate,
      unit,
      building,
      street1,
      street2,
      state,
      postcode,
      area,
      contactPersonName,
      contactPersonPhone,
      contactPersonEmail,
      contactPersonPosition,
      traderName,
      businessType,
      premiseType,
      width,
      length,
    ]) {
      controller.dispose();
    }
  }
}
