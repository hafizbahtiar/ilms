import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';

/// JSON payload aligned with legacy `/api/premiseCensus/create|update`.
///
/// Images are intentionally excluded — they upload via `/create-photo` after submit.
class PremiseSubmitPayloadModel {
  PremiseSubmitPayloadModel({
    this.visitNo,
    this.updatedAt,
    required this.companyDetails,
    required this.contactPerson,
    required this.premiseDetails,
    this.premiseAddresses = const [],
    this.businessActivities = const [],
    this.remarks = const [],
    this.licenseInformation = const [],
  });

  final String? visitNo;
  final String? updatedAt;
  final Map<String, dynamic> companyDetails;
  final Map<String, dynamic> contactPerson;
  final Map<String, dynamic> premiseDetails;
  final List<Map<String, dynamic>> premiseAddresses;
  final List<Map<String, dynamic>> businessActivities;
  final List<Map<String, dynamic>> remarks;
  final List<Map<String, dynamic>> licenseInformation;

  factory PremiseSubmitPayloadModel.fromDomain(PremiseForm form) {
    final company = form.companyContact;
    final details = form.details;

    return PremiseSubmitPayloadModel(
      visitNo: form.visitNo,
      updatedAt: form.updatedAt,
      companyDetails: {
        'company_name': company.companyName,
        'register_no': company.registerNumber,
        'tel_no': company.companyTelNo,
        'fax_no': company.companyFaxNo,
        'sticker_no': company.stickerNo,
        'census_date': company.censusDate,
        'state': company.stateCode,
        'unit': company.unit,
        'building': company.building,
        'street1': company.street1,
        'street2': company.street2,
        'postcode': company.postcode,
        'area': company.areaCode,
      },
      contactPerson: {
        'name': company.contactPersonName,
        'phone': company.contactPersonPhone,
        'email': company.contactPersonEmail,
        'position': company.contactPersonPosition,
      },
      premiseDetails: {
        'trader_name': details.traderName,
        'business_type': details.businessTypeCode,
        'business_type_desc': details.businessTypeDescription,
        'premise_type': details.premiseTypeCode,
        'premise_type_desc': details.premiseTypeDescription,
        'width': details.width,
        'length': details.length,
      },
      premiseAddresses: form.addresses.map(_addressToJson).toList(),
      businessActivities: form.businessActivities.map(_businessToJson).toList(),
      remarks: form.remarks.map(_remarkToJson).toList(),
      licenseInformation: form.licenses.map(_licenseToJson).toList(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'company_details': companyDetails,
      'contact_person': contactPerson,
      'premise_details': premiseDetails,
      if (premiseAddresses.isNotEmpty) 'premise_addresses': premiseAddresses,
      if (businessActivities.isNotEmpty) 'business_activities': businessActivities,
      if (remarks.isNotEmpty) 'remarks': remarks,
      if (licenseInformation.isNotEmpty) 'license_information': licenseInformation,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'visit_no': visitNo,
      'updated_at': updatedAt,
      'company_details': companyDetails,
      'contact_person': contactPerson,
      'premise_details': premiseDetails,
      'premise_addresses': premiseAddresses,
      'business_activities': businessActivities,
      'remarks': remarks,
      'license_information': licenseInformation,
    };
  }

  static Map<String, dynamic> _addressToJson(PremiseAddress address) {
    return {
      if (address.premiseAddressId != null) 'paid': address.premiseAddressId,
      if (address.visitPremiseAddressId != null) 'vpa_id': address.visitPremiseAddressId,
      'unit_no': address.unitNo,
      'floor': address.floor,
      'block_no': address.blockNo,
      'building': address.building,
      'street_name': address.streetName,
      'area': address.area,
      'parliament': address.parliament,
      'postcode': address.postcode,
      'state': address.state,
      'latitude': address.latitude,
      'longitude': address.longitude,
    };
  }

  static Map<String, dynamic> _businessToJson(PremiseBusinessActivity activity) {
    return {
      if (activity.id != null) 'id': activity.id,
      'activity_code': activity.activityCode,
      'activity_desc': activity.activityDescription,
      'remarks': activity.remarks,
    };
  }

  static Map<String, dynamic> _remarkToJson(PremiseRemark remark) {
    return {
      if (remark.id != null) 'id': remark.id,
      'remark': remark.remark,
      if (remark.createdAt != null) 'created_at': remark.createdAt,
    };
  }

  static Map<String, dynamic> _licenseToJson(PremiseLicense license) {
    return {
      if (license.id != null) 'id': license.id,
      'license_no': license.licenseNo,
      'file_no': license.licenseFileNo,
      'license_from': license.validFrom,
      'license_to': license.validTo,
      'status': license.status,
    };
  }
}
