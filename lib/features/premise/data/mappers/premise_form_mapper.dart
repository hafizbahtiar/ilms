import 'package:flutter/material.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_company_contact.dart';
import 'package:ilms/features/premise/domain/entities/premise_details.dart';
import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';

class PremiseFormMapper {
  PremiseFormMapper._();

  static PremiseForm fromPresentation({
    required PremiseFormFields fields,
    required List<PremiseCensusImage> censusImages,
    String? visitNo,
    String? updatedAt,
    int? localDraftId,
  }) {
    return PremiseForm(
      visitNo: visitNo,
      updatedAt: updatedAt,
      localDraftId: localDraftId,
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
        areaCode: lookupCodeFromDisplay(_text(fields.area)),
        areaDescription: lookupDescFromDisplay(_text(fields.area)),
        contactPersonName: _text(fields.contactPersonName),
        contactPersonPhone: _text(fields.contactPersonPhone),
        contactPersonEmail: _text(fields.contactPersonEmail),
        contactPersonPosition: _text(fields.contactPersonPosition),
      ),
      details: PremiseDetails(
        traderName: _text(fields.traderName),
        businessTypeCode: lookupCodeFromDisplay(_text(fields.businessType)),
        businessTypeDescription: lookupDescFromDisplay(_text(fields.businessType)),
        premiseTypeCode: lookupCodeFromDisplay(_text(fields.premiseType)),
        premiseTypeDescription: lookupDescFromDisplay(_text(fields.premiseType)),
        width: _text(fields.width),
        length: _text(fields.length),
      ),
      censusImages: censusImages,
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
