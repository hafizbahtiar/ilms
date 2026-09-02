import 'dart:convert';

import 'package:ilms/features/billboard/data/models/billboard_draft_payload_model.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_face.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_photo.dart';
import 'package:ilms/features/billboard/presentation/controllers/billboard_form_state.dart';
import 'package:ilms/features/premise/domain/entities/premise_image_upload_status.dart';

class BillboardDraftMapper {
  BillboardDraftMapper._();

  static final _fieldKeys = <String, String Function(BillboardFormFields)>{
    'phase': (f) => f.phase.text,
    'description': (f) => f.description.text,
    'billboardType': (f) => f.billboardType.text,
    'hoardingStartDate': (f) => f.hoardingStartDate.text,
    'hoardingCompleteDate': (f) => f.hoardingCompleteDate.text,
    'mediaClientName': (f) => f.mediaClientName.text,
    'mediaClientTel': (f) => f.mediaClientTel.text,
    'unit': (f) => f.unit.text,
    'address': (f) => f.address.text,
    'postal': (f) => f.postal.text,
    'building': (f) => f.building.text,
    'parliament': (f) => f.parliament.text,
    'area': (f) => f.area.text,
    'mediaOwnerName': (f) => f.mediaOwnerName.text,
    'mediaOwnerTel': (f) => f.mediaOwnerTel.text,
    'assetOwner': (f) => f.assetOwner.text,
    'licenseFileNo': (f) => f.licenseFileNo.text,
    'otherRemarkText': (f) => f.otherRemarkText.text,
  };

  static final _fieldSetters = <String, void Function(BillboardFormFields, String)>{
    'phase': (f, v) => f.phase.text = v,
    'description': (f, v) => f.description.text = v,
    'billboardType': (f, v) => f.billboardType.text = v,
    'hoardingStartDate': (f, v) => f.hoardingStartDate.text = v,
    'hoardingCompleteDate': (f, v) => f.hoardingCompleteDate.text = v,
    // Older drafts stored the misspelled key.
    'hordingStartDate': (f, v) => f.hoardingStartDate.text = v,
    'hordingCompleteDate': (f, v) => f.hoardingCompleteDate.text = v,
    'mediaClientName': (f, v) => f.mediaClientName.text = v,
    'mediaClientTel': (f, v) => f.mediaClientTel.text = v,
    'unit': (f, v) => f.unit.text = v,
    'address': (f, v) => f.address.text = v,
    'postal': (f, v) => f.postal.text = v,
    'building': (f, v) => f.building.text = v,
    'parliament': (f, v) => f.parliament.text = v,
    'area': (f, v) => f.area.text = v,
    'mediaOwnerName': (f, v) => f.mediaOwnerName.text = v,
    'mediaOwnerTel': (f, v) => f.mediaOwnerTel.text = v,
    'assetOwner': (f, v) => f.assetOwner.text = v,
    'licenseFileNo': (f, v) => f.licenseFileNo.text = v,
    'otherRemarkText': (f, v) => f.otherRemarkText.text = v,
  };

  static BillboardDraftPayloadModel toPayload({
    required BillboardFormFields fields,
    required BillboardFormState state,
  }) {
    final map = <String, String>{};
    for (final entry in _fieldKeys.entries) {
      map[entry.key] = entry.value(fields);
    }

    return BillboardDraftPayloadModel(
      fields: map,
      isLedBoard: state.details.isLedBoard,
      isLight: state.details.isLight,
      isPotential: state.details.isPotential,
      parliamentCode: state.location.parliamentCode,
      areaCode: state.location.areaCode,
      assetOwnerCode: state.assetOwner.code,
      latitude: state.gps.latitude,
      longitude: state.gps.longitude,
      remarkCodes: state.remark.codes,
      faces: state.faces
          .map(
            (f) => BillboardDraftFace(id: f.id, localId: f.localId, width: f.width, height: f.height, count: f.count),
          )
          .toList(),
      photos: state.photos
          .map(
            (p) => BillboardDraftPhoto(
              id: p.id,
              localId: p.localId,
              localPath: p.localPath,
              networkUrl: p.networkUrl,
              uploadStatus: p.uploadStatus.name,
            ),
          )
          .toList(),
    );
  }

  static String encodePayload(BillboardDraftPayloadModel payload) => jsonEncode(payload.toJson());

  static BillboardDraftPayloadModel decodePayload(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid billboard draft payload');
    }
    return BillboardDraftPayloadModel.fromJson(decoded);
  }

  static void applyPayload({
    required BillboardFormFields fields,
    required BillboardDraftPayloadModel payload,
    required void Function(BillboardFormState state) updateState,
    required BillboardFormState currentState,
  }) {
    for (final entry in payload.fields.entries) {
      _fieldSetters[entry.key]?.call(fields, entry.value);
    }

    updateState(
      currentState.copyWith(
        details: currentState.details.copyWith(
          isLedBoard: payload.isLedBoard,
          isLight: payload.isLight,
          isPotential: payload.isPotential,
        ),
        location: currentState.location.copyWith(parliamentCode: payload.parliamentCode, areaCode: payload.areaCode),
        gps: currentState.gps.copyWith(latitude: payload.latitude, longitude: payload.longitude),
        assetOwner: currentState.assetOwner.copyWith(code: payload.assetOwnerCode),
        remark: currentState.remark.copyWith(codes: payload.remarkCodes),
        faces: payload.faces
            .map((f) => BillboardFace(id: f.id, localId: f.localId, width: f.width, height: f.height, count: f.count))
            .toList(),
        photos: payload.photos
            .map(
              (p) => BillboardPhoto(
                id: p.id,
                localId: p.localId,
                localPath: p.localPath,
                networkUrl: p.networkUrl,
                uploadStatus: _uploadStatusFromStorage(p.uploadStatus),
              ),
            )
            .toList(),
      ),
    );
  }

  static PremiseImageUploadStatus _uploadStatusFromStorage(String value) {
    return PremiseImageUploadStatus.values.firstWhere(
      (item) => item.name == value,
      orElse: () => PremiseImageUploadStatus.local,
    );
  }

  static String displayMediaClientName(BillboardFormFields fields) => fields.mediaClientName.text.trim();

  static String displayDescription(BillboardFormFields fields) => fields.description.text.trim();

  static BillboardDraftPayloadModel emptyPayload() => const BillboardDraftPayloadModel();

  static bool isEmptyPayload(BillboardDraftPayloadModel payload) {
    final hasText = payload.fields.values.any((value) => value.trim().isNotEmpty);
    return !hasText &&
        !payload.isLedBoard &&
        !payload.isLight &&
        !payload.isPotential &&
        payload.remarkCodes.isEmpty &&
        payload.faces.isEmpty &&
        payload.photos.isEmpty &&
        payload.parliamentCode == null &&
        payload.areaCode == null &&
        payload.assetOwnerCode == null &&
        payload.latitude == null &&
        payload.longitude == null;
  }

  static bool payloadsEqual(BillboardDraftPayloadModel a, BillboardDraftPayloadModel b) {
    return encodePayload(a) == encodePayload(b);
  }
}
