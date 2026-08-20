import 'package:flutter/material.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';

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
  const PremiseFormSession({required this.mode, this.localDraftId, this.instanceKey});

  final PremiseFormMode mode;
  final int? localDraftId;

  /// Distinguishes fresh "New Entry" opens so Riverpod does not reuse stale form state.
  final String? instanceKey;

  bool get isTransient =>
      mode == PremiseFormMode.create || mode == PremiseFormMode.draft || mode == PremiseFormMode.duplicate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiseFormSession &&
          other.mode == mode &&
          other.localDraftId == localDraftId &&
          other.instanceKey == instanceKey;

  @override
  int get hashCode => Object.hash(mode, localDraftId, instanceKey);
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
    this.companyStateCode,
    this.companyPostcode,
  });

  final PremiseFormMode mode;
  final int? localDraftId;
  final int activeSectionIndex;
  final bool isSubmitting;
  final bool isDraftSaving;
  final bool isDraftLoading;
  final List<PremiseCensusImage> censusImages;
  final String? companyStateCode;
  final String? companyPostcode;

  bool get isReadOnly => mode.isReadOnly;

  PremiseFormState copyWith({
    PremiseFormMode? mode,
    int? localDraftId,
    int? activeSectionIndex,
    bool? isSubmitting,
    bool? isDraftSaving,
    bool? isDraftLoading,
    List<PremiseCensusImage>? censusImages,
    String? companyStateCode,
    String? companyPostcode,
    bool clearCompanyPostcode = false,
  }) {
    return PremiseFormState(
      mode: mode ?? this.mode,
      localDraftId: localDraftId ?? this.localDraftId,
      activeSectionIndex: activeSectionIndex ?? this.activeSectionIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDraftSaving: isDraftSaving ?? this.isDraftSaving,
      isDraftLoading: isDraftLoading ?? this.isDraftLoading,
      censusImages: censusImages ?? this.censusImages,
      companyStateCode: companyStateCode ?? this.companyStateCode,
      companyPostcode: clearCompanyPostcode ? null : (companyPostcode ?? this.companyPostcode),
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
