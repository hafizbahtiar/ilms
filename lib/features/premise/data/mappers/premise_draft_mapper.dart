import 'dart:convert';

import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';

class PremiseDraftMapper {
  PremiseDraftMapper._();

  static final _fieldKeys = <String, String Function(PremiseFormFields)>{
    'companyName': (f) => f.companyName.text,
    'registerNumber': (f) => f.registerNumber.text,
    'companyTelNo': (f) => f.companyTelNo.text,
    'companyFaxNo': (f) => f.companyFaxNo.text,
    'stickerNo': (f) => f.stickerNo.text,
    'censusDate': (f) => f.censusDate.text,
    'unit': (f) => f.unit.text,
    'building': (f) => f.building.text,
    'street1': (f) => f.street1.text,
    'street2': (f) => f.street2.text,
    'state': (f) => f.state.text,
    'postcode': (f) => f.postcode.text,
    'area': (f) => f.area.text,
    'contactPersonName': (f) => f.contactPersonName.text,
    'contactPersonPhone': (f) => f.contactPersonPhone.text,
    'contactPersonEmail': (f) => f.contactPersonEmail.text,
    'contactPersonPosition': (f) => f.contactPersonPosition.text,
    'traderName': (f) => f.traderName.text,
    'businessType': (f) => f.businessType.text,
    'premiseType': (f) => f.premiseType.text,
    'width': (f) => f.width.text,
    'length': (f) => f.length.text,
  };

  static final _fieldSetters = <String, void Function(PremiseFormFields, String)>{
    'companyName': (f, v) => f.companyName.text = v,
    'registerNumber': (f, v) => f.registerNumber.text = v,
    'companyTelNo': (f, v) => f.companyTelNo.text = v,
    'companyFaxNo': (f, v) => f.companyFaxNo.text = v,
    'stickerNo': (f, v) => f.stickerNo.text = v,
    'censusDate': (f, v) => f.censusDate.text = v,
    'unit': (f, v) => f.unit.text = v,
    'building': (f, v) => f.building.text = v,
    'street1': (f, v) => f.street1.text = v,
    'street2': (f, v) => f.street2.text = v,
    'state': (f, v) => f.state.text = v,
    'postcode': (f, v) => f.postcode.text = v,
    'area': (f, v) => f.area.text = v,
    'contactPersonName': (f, v) => f.contactPersonName.text = v,
    'contactPersonPhone': (f, v) => f.contactPersonPhone.text = v,
    'contactPersonEmail': (f, v) => f.contactPersonEmail.text = v,
    'contactPersonPosition': (f, v) => f.contactPersonPosition.text = v,
    'traderName': (f, v) => f.traderName.text = v,
    'businessType': (f, v) => f.businessType.text = v,
    'premiseType': (f, v) => f.premiseType.text = v,
    'width': (f, v) => f.width.text = v,
    'length': (f, v) => f.length.text = v,
  };

  static PremiseDraftPayloadModel toPayload({required PremiseFormFields fields, required PremiseFormState state}) {
    final map = <String, String>{};
    for (final entry in _fieldKeys.entries) {
      map[entry.key] = entry.value(fields);
    }

    return PremiseDraftPayloadModel(
      companyStateCode: state.companyStateCode,
      companyPostcode: state.companyPostcode,
      businessTypeCode: state.businessTypeCode,
      businessTypeDesc: state.businessTypeDesc,
      premiseTypeCode: state.premiseTypeCode,
      premiseTypeDesc: state.premiseTypeDesc,
      fields: map,
      censusImages: state.censusImages,
      remarks: state.remarks,
      licenses: state.licenses,
      businessActivities: state.businessActivities,
      addresses: state.addresses,
    );
  }

  /// A "duplicate" draft (legacy `duplicateFromSearch`) starts from another
  /// premise's full detail so its fields carry over, but every server `id`
  /// in it (remarks, business activities, licenses, license activities)
  /// still points at the SOURCE premise's rows. Since [toJson] on the
  /// request models sends `id` whenever it's non-null regardless of
  /// create/update, submitting a duplicated draft unmodified would UPDATE
  /// the source premise's rows instead of inserting new ones for this
  /// record (see legacy's `duplicateLicenseInfoForPremise` /
  /// `duplicateBusinessActivitiesForPremise` / `duplicateRemarksForPremise`,
  /// which guard against exactly this). This strips every server `id` (and
  /// local bookkeeping ids that pointed at the source's local rows) so a
  /// duplicated draft always inserts fresh rows.
  static PremiseDraftPayloadModel stripServerIdsForDuplicate(PremiseDraftPayloadModel payload) {
    return PremiseDraftPayloadModel(
      companyStateCode: payload.companyStateCode,
      companyPostcode: payload.companyPostcode,
      businessTypeCode: payload.businessTypeCode,
      businessTypeDesc: payload.businessTypeDesc,
      premiseTypeCode: payload.premiseTypeCode,
      premiseTypeDesc: payload.premiseTypeDesc,
      fields: payload.fields,
      censusImages: payload.censusImages,
      remarks: payload.remarks.map(_stripRemarkId).toList(),
      licenses: payload.licenses.map(_stripLicenseId).toList(),
      businessActivities: payload.businessActivities.map(_stripBusinessActivityId).toList(),
      addresses: payload.addresses,
    );
  }

  static PremiseRemark _stripRemarkId(PremiseRemark remark) => PremiseRemark(
    code: remark.code,
    remark: remark.remark,
    remarkType: remark.remarkType,
    remarkDesc: remark.remarkDesc,
    description: remark.description,
    createdAt: remark.createdAt,
  );

  static PremiseBusinessActivity _stripBusinessActivityId(PremiseBusinessActivity activity) => PremiseBusinessActivity(
    businessType: activity.businessType,
    businessTypeDesc: activity.businessTypeDesc,
    status: activity.status,
    statusDesc: activity.statusDesc,
    description: activity.description,
  );

  static PremiseLicense _stripLicenseId(PremiseLicense license) => PremiseLicense(
    licenseNo: license.licenseNo,
    licenseFileNo: license.licenseFileNo,
    validFrom: license.validFrom,
    validTo: license.validTo,
    status: license.status,
    statusDesc: license.statusDesc,
    businessActivities: license.businessActivities.map(_stripLicenseActivityId).toList(),
  );

  static PremiseLicenseActivity _stripLicenseActivityId(PremiseLicenseActivity activity) => PremiseLicenseActivity(
    businessType: activity.businessType,
    businessTypeDesc: activity.businessTypeDesc,
    status: activity.status,
    statusDesc: activity.statusDesc,
    description: activity.description,
    amount: activity.amount,
  );

  static String encodePayload(PremiseDraftPayloadModel payload) => jsonEncode(payload.toJson());

  static PremiseDraftPayloadModel decodePayload(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid draft payload');
    }
    return PremiseDraftPayloadModel.fromJson(decoded);
  }

  static void applyPayload({
    required PremiseFormFields fields,
    required PremiseDraftPayloadModel payload,
    required void Function(PremiseFormState state) updateState,
    required PremiseFormState currentState,
  }) {
    for (final entry in payload.fields.entries) {
      _fieldSetters[entry.key]?.call(fields, entry.value);
    }

    updateState(
      currentState.copyWith(
        censusImages: payload.censusImages,
        companyStateCode: payload.companyStateCode,
        companyPostcode: payload.companyPostcode,
        businessTypeCode: payload.businessTypeCode,
        businessTypeDesc: payload.businessTypeDesc,
        premiseTypeCode: payload.premiseTypeCode,
        premiseTypeDesc: payload.premiseTypeDesc,
        remarks: payload.remarks,
        licenses: payload.licenses,
        businessActivities: payload.businessActivities,
        addresses: payload.addresses,
      ),
    );
  }

  static String displayCompanyName(PremiseFormFields fields) => fields.companyName.text.trim();

  static String displayTraderName(PremiseFormFields fields) => fields.traderName.text.trim();

  static String displayCompanyNameFromPayload(PremiseDraftPayloadModel payload) =>
      payload.fields['companyName']?.trim() ?? '';

  static String displayTraderNameFromPayload(PremiseDraftPayloadModel payload) =>
      payload.fields['traderName']?.trim() ?? '';

  static PremiseDraftPayloadModel emptyPayload() => const PremiseDraftPayloadModel();

  static bool isEmptyPayload(PremiseDraftPayloadModel payload) {
    final hasText = payload.fields.values.any((value) => value.trim().isNotEmpty);
    return !hasText &&
        payload.censusImages.isEmpty &&
        payload.remarks.isEmpty &&
        payload.licenses.isEmpty &&
        payload.businessActivities.isEmpty &&
        payload.addresses.isEmpty &&
        payload.companyStateCode == null &&
        payload.companyPostcode == null &&
        payload.businessTypeCode == null &&
        payload.businessTypeDesc == null &&
        payload.premiseTypeCode == null &&
        payload.premiseTypeDesc == null;
  }

  static bool payloadsEqual(PremiseDraftPayloadModel a, PremiseDraftPayloadModel b) {
    return encodePayload(a) == encodePayload(b);
  }
}
