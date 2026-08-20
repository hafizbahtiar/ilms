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

class PremiseFormState {
  const PremiseFormState({
    required this.mode,
    this.activeSectionIndex = 0,
    this.isSubmitting = false,
    this.censusImages = const [],
  });

  final PremiseFormMode mode;
  final int activeSectionIndex;
  final bool isSubmitting;
  final List<PremiseCensusImage> censusImages;

  bool get isReadOnly => mode.isReadOnly;

  PremiseFormState copyWith({
    PremiseFormMode? mode,
    int? activeSectionIndex,
    bool? isSubmitting,
    List<PremiseCensusImage>? censusImages,
  }) {
    return PremiseFormState(
      mode: mode ?? this.mode,
      activeSectionIndex: activeSectionIndex ?? this.activeSectionIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      censusImages: censusImages ?? this.censusImages,
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
