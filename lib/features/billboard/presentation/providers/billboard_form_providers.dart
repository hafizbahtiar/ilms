import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_asset_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_face.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_gps.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_license.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_media_owner.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_photo.dart';
import 'package:ilms/features/billboard/domain/exceptions/billboard_exception.dart';
import 'package:ilms/features/billboard/presentation/controllers/billboard_form_state.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_providers.dart';
import 'package:ilms/features/billboard/presentation/sections/billboard_form_sections.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:latlong2/latlong.dart';

class BillboardFormController extends FamilyNotifier<BillboardFormState, BillboardFormSession> {
  late final BillboardFormFields fields;

  /// Set when [submit] fails — read by the page right after `submit()`
  /// resolves so it can show the real error message.
  String? lastSubmitError;

  @override
  BillboardFormState build(BillboardFormSession session) {
    fields = BillboardFormFields();
    ref.onDispose(fields.dispose);
    return BillboardFormState(mode: session.mode, billboardNo: session.billboardNo);
  }

  BillboardFormFields get formFields => fields;

  /// Returns `false` only when a server-backed session (opened via
  /// [BillboardFormSession.billboardNo]) failed to load — the page uses that
  /// to bail out instead of showing a form with nothing in it.
  Future<bool> initialize(BillboardFormSession session) async {
    final billboardNo = session.billboardNo;
    if (billboardNo == null) return true;

    state = state.copyWith(isLoading: true);
    try {
      final form = await ref.read(billboardDetailRepositoryProvider).getDetail(billboardNo);
      _applyForm(form, mode: session.mode);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e, st) {
      dev.log(
        'Failed to load billboard detail for $billboardNo: $e',
        name: 'BillboardFormController',
        error: e,
        stackTrace: st,
      );
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  void _applyForm(BillboardForm form, {required BillboardFormMode mode}) {
    fields.phase.text = form.details.phaseDesc ?? form.details.phaseCode ?? '';
    fields.description.text = form.details.description ?? '';
    fields.billboardType.text = form.details.billboardTypeDesc ?? form.details.billboardTypeCode ?? '';
    fields.hordingStartDate.text = form.details.hordingStartDate ?? '';
    fields.hordingCompleteDate.text = form.details.hordingCompleteDate ?? '';

    fields.mediaClientName.text = form.location.mediaClientName ?? '';
    fields.mediaClientTel.text = form.location.mediaClientTel ?? '';
    fields.unit.text = form.location.unit ?? '';
    fields.address.text = form.location.address ?? '';
    fields.postal.text = form.location.postal ?? '';
    fields.building.text = form.location.building ?? '';
    fields.parliament.text = form.location.parliamentDesc ?? form.location.parliamentCode ?? '';
    fields.area.text = form.location.areaDesc ?? form.location.areaCode ?? '';

    fields.mediaOwnerName.text = form.mediaOwner.name ?? '';
    fields.mediaOwnerTel.text = form.mediaOwner.tel ?? '';

    fields.assetOwner.text = form.assetOwner.desc ?? form.assetOwner.code ?? '';

    fields.licenseFileNo.text = form.license.fileNo ?? '';

    fields.otherRemarkText.text = form.remark.otherText ?? '';

    state = state.copyWith(
      mode: mode,
      billboardNo: form.billboardNo,
      details: form.details,
      location: form.location,
      gps: form.gps,
      mediaOwner: form.mediaOwner,
      assetOwner: form.assetOwner,
      license: form.license,
      remark: form.remark,
      faces: form.faces,
      photos: form.photos,
    );
  }

  /// Switches an in-progress "view" session into edit mode in place —
  /// mirrors premise's app-bar Edit action.
  void switchToEditMode() {
    if (state.mode != BillboardFormMode.view) return;
    state = state.copyWith(mode: BillboardFormMode.edit);
  }

  void setActiveSection(int index) {
    if (index == state.activeSectionIndex) return;
    if (index < 0 || index >= billboardFormSections.length) return;
    state = state.copyWith(activeSectionIndex: index);
  }

  // ---- Details section ----

  void selectPhase(GeneralModel item) {
    if (state.isReadOnly) return;
    state = state.copyWith(
      details: state.details.copyWith(phaseCode: item.code, phaseDesc: item.desc),
    );
  }

  void selectBillboardType(GeneralModel item) {
    if (state.isReadOnly) return;
    state = state.copyWith(
      details: state.details.copyWith(billboardTypeCode: item.code, billboardTypeDesc: item.desc),
    );
  }

  void setLed(bool value) {
    if (state.isReadOnly) return;
    state = state.copyWith(details: state.details.copyWith(isLedBoard: value));
  }

  void setLight(bool value) {
    if (state.isReadOnly) return;
    state = state.copyWith(details: state.details.copyWith(isLight: value));
  }

  void setPotential(bool value) {
    if (state.isReadOnly) return;
    state = state.copyWith(details: state.details.copyWith(isPotential: value));
  }

  void setHordingStartDate(String value) {
    if (state.isReadOnly) return;
    state = state.copyWith(details: state.details.copyWith(hordingStartDate: value));
  }

  void setHordingCompleteDate(String value) {
    if (state.isReadOnly) return;
    state = state.copyWith(details: state.details.copyWith(hordingCompleteDate: value));
  }

  // ---- Location section ----

  void selectParliament(GeneralModel item) {
    if (state.isReadOnly) return;
    fields.area.clear();
    state = state.copyWith(
      location: state.location.copyWith(parliamentCode: item.code, parliamentDesc: item.desc, clearArea: true),
    );
  }

  void selectArea(GeneralModel item) {
    if (state.isReadOnly) return;
    state = state.copyWith(
      location: state.location.copyWith(areaCode: item.code, areaDesc: item.desc),
    );
  }

  // ---- GPS section ----

  void setCoordinate(LatLng? point) {
    if (state.isReadOnly) return;
    state = state.copyWith(
      gps: point == null
          ? const BillboardGps()
          : BillboardGps(latitude: point.latitude.toString(), longitude: point.longitude.toString()),
    );
  }

  // ---- Asset owner section ----

  void selectAssetOwner(GeneralModel item) {
    if (state.isReadOnly) return;
    state = state.copyWith(
      assetOwner: BillboardAssetOwner(code: item.code, desc: item.desc),
    );
  }

  // ---- Faces section ----

  void addFace(BillboardFace face) {
    if (state.isReadOnly) return;
    state = state.copyWith(faces: [...state.faces, face]);
  }

  void updateFaceAt(int index, BillboardFace face) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.faces.length) return;
    final next = [...state.faces];
    next[index] = face;
    state = state.copyWith(faces: next);
  }

  void removeFaceAt(int index) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.faces.length) return;
    final next = [...state.faces]..removeAt(index);
    state = state.copyWith(faces: next);
  }

  // ---- Photos section ----

  void addPhoto(BillboardPhoto photo) {
    if (state.isReadOnly) return;
    state = state.copyWith(photos: [...state.photos, photo]);
  }

  void removePhotoAt(int index) {
    if (state.isReadOnly) return;
    if (index < 0 || index >= state.photos.length) return;
    final next = [...state.photos]..removeAt(index);
    state = state.copyWith(photos: next);
  }

  // ---- Remarks section ----

  void toggleRemark(String code) {
    if (state.isReadOnly) return;
    final codes = [...state.remark.codes];
    if (codes.contains(code)) {
      codes.remove(code);
    } else {
      codes.add(code);
    }
    state = state.copyWith(remark: state.remark.copyWith(codes: codes));
  }

  /// Bulk-replaces the selected codes — used by the multi-pick sheet, which
  /// resolves its own diff internally rather than the caller replaying
  /// individual [toggleRemark] calls.
  void setRemarkCodes(List<String> codes) {
    if (state.isReadOnly) return;
    state = state.copyWith(remark: state.remark.copyWith(codes: codes));
  }

  void setOtherRemarkText(String value) {
    if (state.isReadOnly) return;
    state = state.copyWith(
      remark: state.remark.copyWith(otherText: value, clearOtherText: value.trim().isEmpty),
    );
  }

  // ---- Submit ----

  Future<bool> submit() async {
    if (state.isReadOnly || state.isSubmitting) return false;
    lastSubmitError = null;
    state = state.copyWith(isSubmitting: true);

    try {
      final form = BillboardForm(
        billboardNo: state.billboardNo,
        details: state.details.copyWith(description: fields.description.text),
        location: state.location.copyWith(
          mediaClientName: fields.mediaClientName.text,
          mediaClientTel: fields.mediaClientTel.text,
          unit: fields.unit.text,
          address: fields.address.text,
          postal: fields.postal.text,
          building: fields.building.text,
        ),
        gps: state.gps,
        mediaOwner: BillboardMediaOwner(name: fields.mediaOwnerName.text, tel: fields.mediaOwnerTel.text),
        assetOwner: state.assetOwner,
        license: BillboardLicense(fileNo: fields.licenseFileNo.text),
        remark: state.remark.copyWith(
          otherText: fields.otherRemarkText.text,
          clearOtherText: fields.otherRemarkText.text.trim().isEmpty,
        ),
        faces: state.faces,
        photos: state.photos,
      );

      final repository = ref.read(billboardRepositoryProvider);
      final result = form.isUpdate ? await repository.submitUpdate(form) : await repository.submitCreate(form);

      if (result.pendingImageUploads > 0) {
        await repository.uploadPendingPhotos(
          billboardNo: result.billboardNo,
          form: form,
          process: form.isUpdate ? 'update' : 'create',
        );
      }

      state = state.copyWith(isSubmitting: false, billboardNo: result.billboardNo);
      return true;
    } catch (e, st) {
      dev.log('submit() failed: $e', name: 'BillboardFormController', error: e, stackTrace: st);
      lastSubmitError = e is BillboardException ? e.message : 'Failed to submit billboard census.';
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

final billboardFormControllerProvider =
    NotifierProvider.family<BillboardFormController, BillboardFormState, BillboardFormSession>(
      BillboardFormController.new,
    );

final billboardFormFieldsProvider = Provider.family<BillboardFormFields, BillboardFormSession>((ref, session) {
  ref.watch(billboardFormControllerProvider(session));
  return ref.read(billboardFormControllerProvider(session).notifier).formFields;
});

class BillboardFormScope extends InheritedWidget {
  const BillboardFormScope({super.key, required this.session, required super.child});

  final BillboardFormSession session;

  static BillboardFormSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BillboardFormScope>();
    assert(scope != null, 'BillboardFormScope not found in widget tree.');
    return scope!.session;
  }

  @override
  bool updateShouldNotify(BillboardFormScope oldWidget) => session != oldWidget.session;
}
