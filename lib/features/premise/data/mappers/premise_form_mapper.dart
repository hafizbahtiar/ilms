import 'package:flutter/material.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_company_contact.dart';
import 'package:ilms/features/premise/domain/entities/premise_details.dart';
import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';

class PremiseFormMapper {
  PremiseFormMapper._();

  static PremiseForm fromPresentation({
    required PremiseFormFields fields,
    required List<PremiseCensusImage> censusImages,
    List<PremiseRemark> remarks = const [],
    List<PremiseLicense> licenses = const [],
    List<PremiseBusinessActivity> businessActivities = const [],
    List<PremiseAddress> addresses = const [],
    String? visitNo,
    String? updatedAt,
    int? localDraftId,
    String? visitStatus,
    String? visitStatusDesc,
    String? areaCode,
    String? businessTypeCode,
    String? businessTypeDesc,
    String? premiseTypeCode,
    String? premiseTypeDesc,
  }) {
    return PremiseForm(
      visitNo: visitNo,
      updatedAt: updatedAt,
      localDraftId: localDraftId,
      visitStatus: visitStatus,
      visitStatusDesc: visitStatusDesc,
      companyContact: PremiseCompanyContact(
        companyName: _text(fields.companyName),
        registerNumber: _text(fields.registerNumber),
        companyTelNo: _text(fields.companyTelNo),
        companyFaxNo: _text(fields.companyFaxNo),
        stickerNo: _text(fields.stickerNo),
        censusDate: _text(fields.censusDate),
        unit: _text(fields.unit),
        building: _text(fields.building),
        street1: _text(fields.street1),
        street2: _text(fields.street2),
        stateCode: lookupCodeFromDisplay(_text(fields.state)),
        stateDescription: lookupDescFromDisplay(_text(fields.state)),
        postcode: lookupCodeFromDisplay(_text(fields.postcode)) ?? _text(fields.postcode),
        // [fields.area] always displays the area's full plain description
        // (e.g. `SEGAMBUT - DESA SERI HARTAMAS`), never a `code - desc` pair —
        // that's the value the backend's `area` field expects (it mirrors
        // `premise_addresses[*][area]`), so it's passed through as-is here.
        // Parsing it with lookupCodeFromDisplay/lookupDescFromDisplay would
        // wrongly split it into a fake code + truncated desc.
        //
        // The real area *code* (a distinct, short "parliament-like" value —
        // e.g. `SEGAMBUT` — used only for internal lookups such as street
        // matching) is captured at selection time and passed in via
        // [areaCode]; best-effort parse it from the text only when
        // unavailable, e.g. a draft resumed without re-selecting the area.
        areaCode: areaCode ?? lookupCodeFromDisplay(_text(fields.area)),
        areaDescription: _text(fields.area),
        contactPersonName: _text(fields.contactPersonName),
        contactPersonPhone: _text(fields.contactPersonPhone),
        contactPersonEmail: _text(fields.contactPersonEmail),
        contactPersonPosition: _text(fields.contactPersonPosition),
      ),
      details: PremiseDetails(
        traderName: _text(fields.traderName),
        businessTypeCode: businessTypeCode,
        businessTypeDescription: businessTypeDesc,
        premiseTypeCode: premiseTypeCode,
        premiseTypeDescription: premiseTypeDesc,
        width: _text(fields.width),
        length: _text(fields.length),
      ),
      censusImages: censusImages,
      remarks: remarks,
      licenses: licenses,
      businessActivities: businessActivities,
      addresses: addresses,
    );
  }

  static String? _text(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  static void applyLookupSelection({required TextEditingController controller, required GeneralModel item}) {
    applyGeneralLookupSelection(controller: controller, item: item);
  }
}
