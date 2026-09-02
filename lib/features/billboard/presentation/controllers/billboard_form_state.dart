import 'package:flutter/material.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_asset_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_details.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_face.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_gps.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_license.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_location.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_media_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_photo.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_remark.dart';

enum BillboardFormMode { create, draft, view, edit }

extension BillboardFormModeX on BillboardFormMode {
  bool get isReadOnly => this == BillboardFormMode.view;

  static BillboardFormMode fromQuery(String? value) {
    return switch (value) {
      'draft' => BillboardFormMode.draft,
      'view' => BillboardFormMode.view,
      'edit' => BillboardFormMode.edit,
      _ => BillboardFormMode.create,
    };
  }
}

@immutable
class BillboardFormSession {
  const BillboardFormSession({required this.mode, this.localDraftId, this.instanceKey, this.billboardNo});

  final BillboardFormMode mode;

  /// Local draft row id to resume from — distinct from [billboardNo], which
  /// loads straight from the server.
  final int? localDraftId;

  /// Distinguishes fresh "New Entry" opens so Riverpod does not reuse stale form state.
  final String? instanceKey;

  /// Server billboard number to load from `/api/billboardCensus/detail` when
  /// opening an existing record directly from a search/list result.
  final String? billboardNo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillboardFormSession &&
          other.mode == mode &&
          other.localDraftId == localDraftId &&
          other.instanceKey == instanceKey &&
          other.billboardNo == billboardNo;

  @override
  int get hashCode => Object.hash(mode, localDraftId, instanceKey, billboardNo);
}

class BillboardFormState {
  const BillboardFormState({
    required this.mode,
    this.localDraftId,
    this.activeSectionIndex = 0,
    this.isSubmitting = false,
    this.isLoading = false,
    this.isDraftSaving = false,
    this.billboardNo,
    this.details = const BillboardDetails(),
    this.location = const BillboardLocation(),
    this.gps = const BillboardGps(),
    this.mediaOwner = const BillboardMediaOwner(),
    this.assetOwner = const BillboardAssetOwner(),
    this.license = const BillboardLicense(),
    this.remark = const BillboardRemark(),
    this.faces = const [],
    this.photos = const [],
  });

  final BillboardFormMode mode;
  final int? localDraftId;
  final int activeSectionIndex;
  final bool isSubmitting;

  /// True while loading an existing record or a local draft (view/edit/draft).
  final bool isLoading;

  final bool isDraftSaving;

  /// Server-assigned billboard number, set once a create/update succeeds.
  final String? billboardNo;

  final BillboardDetails details;
  final BillboardLocation location;
  final BillboardGps gps;
  final BillboardMediaOwner mediaOwner;
  final BillboardAssetOwner assetOwner;
  final BillboardLicense license;
  final BillboardRemark remark;
  final List<BillboardFace> faces;
  final List<BillboardPhoto> photos;

  bool get isReadOnly => mode.isReadOnly;

  BillboardFormState copyWith({
    BillboardFormMode? mode,
    int? localDraftId,
    bool clearLocalDraftId = false,
    int? activeSectionIndex,
    bool? isSubmitting,
    bool? isLoading,
    bool? isDraftSaving,
    String? billboardNo,
    BillboardDetails? details,
    BillboardLocation? location,
    BillboardGps? gps,
    BillboardMediaOwner? mediaOwner,
    BillboardAssetOwner? assetOwner,
    BillboardLicense? license,
    BillboardRemark? remark,
    List<BillboardFace>? faces,
    List<BillboardPhoto>? photos,
  }) {
    return BillboardFormState(
      mode: mode ?? this.mode,
      localDraftId: clearLocalDraftId ? null : (localDraftId ?? this.localDraftId),
      activeSectionIndex: activeSectionIndex ?? this.activeSectionIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
      isDraftSaving: isDraftSaving ?? this.isDraftSaving,
      billboardNo: billboardNo ?? this.billboardNo,
      details: details ?? this.details,
      location: location ?? this.location,
      gps: gps ?? this.gps,
      mediaOwner: mediaOwner ?? this.mediaOwner,
      assetOwner: assetOwner ?? this.assetOwner,
      license: license ?? this.license,
      remark: remark ?? this.remark,
      faces: faces ?? this.faces,
      photos: photos ?? this.photos,
    );
  }
}

/// Text controllers for every text/picker field across the 9 billboard
/// sections, grouped by section (mirrors [PremiseFormFields]'s layout).
class BillboardFormFields {
  BillboardFormFields() {
    // Details
    phase = TextEditingController();
    description = TextEditingController();
    billboardType = TextEditingController();
    hoardingStartDate = TextEditingController();
    hoardingCompleteDate = TextEditingController();

    // Location
    mediaClientName = TextEditingController();
    mediaClientTel = TextEditingController();
    unit = TextEditingController();
    address = TextEditingController();
    postal = TextEditingController();
    building = TextEditingController();
    parliament = TextEditingController();
    area = TextEditingController();

    // Media owner
    mediaOwnerName = TextEditingController();
    mediaOwnerTel = TextEditingController();

    // Asset owner
    assetOwner = TextEditingController();

    // License
    licenseFileNo = TextEditingController();

    // Remarks
    otherRemarkText = TextEditingController();
  }

  late final TextEditingController phase;
  late final TextEditingController description;
  late final TextEditingController billboardType;
  late final TextEditingController hoardingStartDate;
  late final TextEditingController hoardingCompleteDate;

  late final TextEditingController mediaClientName;
  late final TextEditingController mediaClientTel;
  late final TextEditingController unit;
  late final TextEditingController address;
  late final TextEditingController postal;
  late final TextEditingController building;
  late final TextEditingController parliament;
  late final TextEditingController area;

  late final TextEditingController mediaOwnerName;
  late final TextEditingController mediaOwnerTel;

  late final TextEditingController assetOwner;

  late final TextEditingController licenseFileNo;

  late final TextEditingController otherRemarkText;

  void dispose() {
    for (final controller in [
      phase,
      description,
      billboardType,
      hoardingStartDate,
      hoardingCompleteDate,
      mediaClientName,
      mediaClientTel,
      unit,
      address,
      postal,
      building,
      parliament,
      area,
      mediaOwnerName,
      mediaOwnerTel,
      assetOwner,
      licenseFileNo,
      otherRemarkText,
    ]) {
      controller.dispose();
    }
  }
}
