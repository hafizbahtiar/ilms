import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_form.dart';
import 'package:ilms/features/premise/domain/entities/premise_gps.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';
import 'package:ilms/features/premise/presentation/utils/premise_license_file_no.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';

/// Request model for `/api/premiseCensus/create|update`, mirroring legacy
/// `PremiseInputModel` (one class per sub-object, same field placement).
///
/// Images are intentionally excluded — they upload via `/create-photo` after submit.
class PremiseSubmitPayloadModel {
  const PremiseSubmitPayloadModel({
    this.visitNo,
    this.updatedAt,
    required this.companyDetails,
    required this.contactPerson,
    required this.premiseDetails,
    this.gps = const PremiseGpsRequest(),
    this.premiseAddresses = const [],
    this.businessActivities = const [],
    this.remarks = const [],
    this.licenseInformation = const [],
  });

  final String? visitNo;
  final String? updatedAt;
  final CompanyDetailsRequest companyDetails;
  final ContactPersonRequest contactPerson;
  final PremiseDetailsRequest premiseDetails;
  final PremiseGpsRequest gps;
  final List<PremiseAddressRequest> premiseAddresses;
  final List<PremiseBusinessActivityRequest> businessActivities;
  final List<PremiseRemarkRequest> remarks;
  final List<PremiseLicenseRequest> licenseInformation;

  factory PremiseSubmitPayloadModel.fromDomain(PremiseForm form) {
    final company = form.companyContact;
    final details = form.details;

    return PremiseSubmitPayloadModel(
      visitNo: form.visitNo,
      updatedAt: form.updatedAt,
      companyDetails: CompanyDetailsRequest(
        companyName: company.companyName,
        registerNo: company.registerNumber,
        telNo: company.companyTelNo,
        faxNo: company.companyFaxNo,
        stickerNo: company.stickerNo,
        // Legacy places visit status inside company_details, NOT as a
        // top-level field — the server rejects it as "required" otherwise.
        visitStatus: form.visitStatus,
        censusDate: company.censusDate,
        state: company.stateCode,
        unit: company.unit,
        building: company.building,
        street1: company.street1,
        street2: company.street2,
        postcode: company.postcode,
        // The backend's `area` here is the full descriptive value (matches
        // `premise_addresses[*][area]`, e.g. "SEGAMBUT - DESA SRI HARTAMAS"),
        // NOT the short area/parliament code ("SEGAMBUT") — that code is a
        // separate concept the premise-address payload sends as `parliament`.
        area: company.areaDescription,
      ),
      contactPerson: ContactPersonRequest(
        name: company.contactPersonName,
        phone: company.contactPersonPhone,
        email: company.contactPersonEmail,
        position: company.contactPersonPosition,
      ),
      premiseDetails: PremiseDetailsRequest(
        traderName: details.traderName,
        businessType: details.businessTypeCode,
        businessTypeDesc: details.businessTypeDescription,
        premiseType: details.premiseTypeCode,
        premiseTypeDesc: details.premiseTypeDescription,
        width: details.width,
        length: details.length,
      ),
      gps: PremiseGpsRequest.fromDomain(form.gps),
      premiseAddresses: form.addresses.map(PremiseAddressRequest.fromDomain).toList(),
      businessActivities: form.businessActivities.map(PremiseBusinessActivityRequest.fromDomain).toList(),
      remarks: form.remarks.map(PremiseRemarkRequest.fromDomain).toList(),
      licenseInformation: form.licenses.map(PremiseLicenseRequest.fromDomain).toList(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      // Real submit-time clock — stamped here rather than at fromDomain()
      // construction so it reflects the moment the create request actually
      // fires, not when the payload snapshot was built.
      'time_created': formatYyyyMmDdHhMmSs(DateTime.now()),
      'company_details': companyDetails.toJson(),
      'contact_person': contactPerson.toJson(),
      'premise_details': premiseDetails.toJson(),
      // This used to travel per-address as `premise_addresses[*].latitude/
      // longitude` instead — now one `{latitude, longitude}` object for the
      // whole premise.
      'gps_details': gps.toJson(),
      if (premiseAddresses.isNotEmpty) 'premise_addresses': premiseAddresses.map((e) => e.toCreateJson()).toList(),
      if (businessActivities.isNotEmpty)
        'business_activities': businessActivities.map((e) => e.toCreateJson()).toList(),
      if (remarks.isNotEmpty) 'remarks': remarks.map((e) => e.toCreateJson()).toList(),
      if (licenseInformation.isNotEmpty)
        'license_information': licenseInformation.map((e) => e.toCreateJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'visit_no': visitNo,
      'updated_at': updatedAt,
      'company_details': companyDetails.toJson(),
      'contact_person': contactPerson.toJson(),
      'premise_details': premiseDetails.toJson(),
      'gps_details': gps.toJson(),
      'premise_addresses': premiseAddresses.map((e) => e.toUpdateJson()).toList(),
      'business_activities': businessActivities.map((e) => e.toUpdateJson()).toList(),
      'remarks': remarks.map((e) => e.toUpdateJson()).toList(),
      'license_information': licenseInformation.map((e) => e.toUpdateJson()).toList(),
    };
  }
}

/// `company_details` — carries [visitStatus] too (legacy `CompanyDetails`).
class CompanyDetailsRequest {
  const CompanyDetailsRequest({
    this.companyName,
    this.registerNo,
    this.telNo,
    this.faxNo,
    this.stickerNo,
    this.visitStatus,
    this.censusDate,
    this.state,
    this.unit,
    this.building,
    this.street1,
    this.street2,
    this.postcode,
    this.area,
  });

  final String? companyName;
  final String? registerNo;
  final String? telNo;
  final String? faxNo;
  final String? stickerNo;
  final String? visitStatus;
  final String? censusDate;
  final String? state;
  final String? unit;
  final String? building;
  final String? street1;
  final String? street2;
  final String? postcode;
  final String? area;

  Map<String, dynamic> toJson() => {
    'company_name': companyName,
    'register_no': registerNo,
    'tel_no': telNo,
    'fax_no': faxNo,
    'sticker_no': stickerNo,
    'visit_status': visitStatus,
    'census_date': censusDate,
    'state': state,
    'unit': unit,
    'building': building,
    'street1': street1,
    'street2': street2,
    'postcode': postcode,
    'area': area,
  };
}

/// `contact_person` (legacy `ContactPerson`).
class ContactPersonRequest {
  const ContactPersonRequest({this.name, this.phone, this.email, this.position});

  final String? name;
  final String? phone;
  final String? email;
  final String? position;

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'email': email, 'position': position};
}

/// `premise_details` (legacy `PremiseDetails`).
class PremiseDetailsRequest {
  const PremiseDetailsRequest({
    this.traderName,
    this.businessType,
    this.businessTypeDesc,
    this.premiseType,
    this.premiseTypeDesc,
    this.width,
    this.length,
  });

  final String? traderName;
  final String? businessType;
  final String? businessTypeDesc;
  final String? premiseType;
  final String? premiseTypeDesc;
  final String? width;
  final String? length;

  Map<String, dynamic> toJson() => {
    'trader_name': traderName,
    'business_type': businessType,
    'business_type_desc': businessTypeDesc,
    'premise_type': premiseType,
    'premise_type_desc': premiseTypeDesc,
    'width': width,
    'length': length,
  };
}

/// `gps_details` — one coordinate for the whole premise record: a
/// `{latitude, longitude}` object, confirmed against the backend contract.
class PremiseGpsRequest {
  const PremiseGpsRequest({this.latitude, this.longitude});

  final String? latitude;
  final String? longitude;

  factory PremiseGpsRequest.fromDomain(PremiseGps gps) =>
      PremiseGpsRequest(latitude: gps.latitude, longitude: gps.longitude);

  Map<String, dynamic> toJson() => {'latitude': latitude, 'longitude': longitude};
}

/// One entry in `premise_addresses` (legacy `PremiseAddress`).
class PremiseAddressRequest {
  const PremiseAddressRequest({
    this.premiseAddressId,
    this.visitPremiseAddressId,
    this.unitNo,
    this.floor,
    this.blockNo,
    this.building,
    this.streetName,
    this.area,
    this.parliament,
    this.postcode,
    this.state,
  });

  final int? premiseAddressId;
  final int? visitPremiseAddressId;
  final String? unitNo;
  final String? floor;
  final String? blockNo;
  final String? building;
  final String? streetName;
  final String? area;
  final String? parliament;
  final String? postcode;
  final String? state;

  factory PremiseAddressRequest.fromDomain(PremiseAddress address) => PremiseAddressRequest(
    premiseAddressId: address.premiseAddressId,
    visitPremiseAddressId: address.visitPremiseAddressId,
    unitNo: address.unitNo,
    floor: address.floor,
    blockNo: address.blockNo,
    building: address.building,
    streetName: address.streetName,
    area: address.area,
    parliament: address.parliament,
    postcode: address.postcode,
    state: address.state,
  );

  Map<String, dynamic> toCreateJson() => {
    if (premiseAddressId != null) 'paid': premiseAddressId,
    'unit_no': unitNo,
    'floor': floor,
    'block_no': blockNo,
    'building': building,
    'street_name': streetName,
    'area': area,
    'parliament': parliament,
    'postcode': postcode,
    'state': state,
  };

  /// Update parity with legacy `PremiseAddress.toJsonUpdate()`.
  Map<String, dynamic> toUpdateJson() => {
    if (premiseAddressId != null) 'paid': premiseAddressId,
    if (visitPremiseAddressId != null) 'vpa_id': visitPremiseAddressId,
    'unit_no': unitNo,
    'floor': floor,
    'block_no': blockNo,
    'building': building,
    'street_name': streetName,
    'area': area,
    'parliament': parliament,
    'postcode': postcode,
    'state': state,
  };
}

/// One entry in `business_activities` (legacy `BusinessActivity`).
class PremiseBusinessActivityRequest {
  const PremiseBusinessActivityRequest({
    this.id,
    this.businessType,
    this.businessTypeDesc,
    this.status,
    this.statusDesc,
    this.description,
  });

  final int? id;
  final String? businessType;
  final String? businessTypeDesc;
  final String? status;
  final String? statusDesc;
  final String? description;

  factory PremiseBusinessActivityRequest.fromDomain(PremiseBusinessActivity activity) => PremiseBusinessActivityRequest(
    id: activity.id,
    businessType: activity.businessType,
    businessTypeDesc: activity.businessTypeDesc,
    status: activity.status,
    statusDesc: activity.statusDesc,
    description: activity.description,
  );

  /// Create parity with legacy `BusinessActivity.toJson()` — the `*_desc`
  /// fields are display-only lookups that `/create` has no column for.
  Map<String, dynamic> toCreateJson() => {'business_type': businessType, 'status': status, 'description': description};

  /// Update parity with legacy `BusinessActivity.toJsonUpdate()`.
  Map<String, dynamic> toUpdateJson() => {
    if (id != null) 'id': id,
    'business_type': businessType,
    'business_type_desc': businessTypeDesc,
    'status': status,
    'status_desc': statusDesc,
    'description': description,
  };
}

/// One entry in `remarks` (legacy `Remark`).
class PremiseRemarkRequest {
  const PremiseRemarkRequest({this.id, this.code, this.remark, this.remarkType, this.description});

  final int? id;
  final String? code;
  final String? remark;
  final String? remarkType;
  final String? description;

  factory PremiseRemarkRequest.fromDomain(PremiseRemark remark) => PremiseRemarkRequest(
    id: remark.id,
    code: remark.code,
    remark: remark.remark,
    remarkType: remark.remarkType,
    description: remark.description,
  );

  Map<String, dynamic> toCreateJson() => {
    'code': code,
    'remark': remark,
    'remark_type': remarkType,
    'description': description,
  };

  /// Update parity with legacy `Remark.toJsonUpdate()`.
  Map<String, dynamic> toUpdateJson() => {
    if (id != null) 'id': id,
    'code': code,
    'remark': remark,
    'remark_type': remarkType,
    'description': description,
  };
}

/// One entry in a license's `additional_license_info` (legacy `AdditionalLicenseInfo`).
class PremiseLicenseActivityRequest {
  const PremiseLicenseActivityRequest({
    this.id,
    this.businessType,
    this.businessTypeDesc,
    this.status,
    this.statusDesc,
    this.description,
    this.amount,
  });

  /// Server row id — resubmitted so the backend updates this row instead of
  /// inserting a duplicate.
  final int? id;
  final String? businessType;
  final String? businessTypeDesc;
  final String? status;
  final String? statusDesc;
  final String? description;
  final String? amount;

  factory PremiseLicenseActivityRequest.fromDomain(PremiseLicenseActivity activity) => PremiseLicenseActivityRequest(
    id: activity.id,
    businessType: activity.businessType,
    businessTypeDesc: activity.businessTypeDesc,
    status: activity.status,
    statusDesc: activity.statusDesc,
    description: activity.description,
    amount: activity.amount,
  );

  /// Create parity with legacy `AdditionalLicenseInfo.toJson()`: only the four
  /// columns `/api/premiseCensus/create` accepts. The `*_desc` fields are
  /// display-only lookups with no column behind them, and `id` is deliberately
  /// omitted so a duplicated premise can't overwrite the source premise's row.
  Map<String, dynamic> toCreateJson() => {
    'business_type': businessType,
    'status': status,
    'description': description,
    'amount': amount,
  };

  /// Update parity with legacy `AdditionalLicenseInfo.toJsonUpdate()`.
  Map<String, dynamic> toUpdateJson() => {
    if (id != null) 'id': id,
    'business_type': businessType,
    'business_type_desc': businessTypeDesc,
    'status': status,
    'status_desc': statusDesc,
    'description': description,
    'amount': amount,
  };
}

/// One entry in `license_information` (legacy `LicenseInformation`).
class PremiseLicenseRequest {
  const PremiseLicenseRequest({
    this.id,
    this.licenseNo,
    this.fileNo,
    this.licenseFrom,
    this.licenseTo,
    this.status,
    this.statusDesc,
    this.additionalLicenseInfo = const [],
  });

  final int? id;
  final String? licenseNo;
  final String? fileNo;
  final String? licenseFrom;
  final String? licenseTo;
  final String? status;
  final String? statusDesc;
  final List<PremiseLicenseActivityRequest> additionalLicenseInfo;

  factory PremiseLicenseRequest.fromDomain(PremiseLicense license) => PremiseLicenseRequest(
    id: license.id,
    licenseNo: license.licenseNo,
    fileNo: PremiseLicenseFileNo.formatForSubmit(license.licenseFileNo),
    licenseFrom: license.validFrom,
    licenseTo: license.validTo,
    status: license.status,
    statusDesc: license.statusDesc,
    additionalLicenseInfo: license.businessActivities.map(PremiseLicenseActivityRequest.fromDomain).toList(),
  );

  /// Create parity with legacy `LicenseInformation.toJson()`. `/create` has no
  /// `file_no` or `status_desc` column on the license row — sending them made
  /// the whole submit fail whenever the form carried any license at all.
  Map<String, dynamic> toCreateJson() => {
    if (id != null) 'id': id,
    'license_no': licenseNo ?? '',
    'license_file_no': fileNo,
    'license_from': _isoDate(licenseFrom),
    'license_to': _isoDate(licenseTo),
    'status': status,
    'additional_license_info': additionalLicenseInfo.map((e) => e.toCreateJson()).toList(),
  };

  /// Update parity with legacy `LicenseInformation.toJsonUpdate()` — `/update`
  /// does carry the `*_desc` display columns.
  Map<String, dynamic> toUpdateJson() => {
    if (id != null) 'id': id,
    'license_no': licenseNo ?? '',
    'license_file_no': fileNo,
    'license_from': _isoDate(licenseFrom),
    'license_to': _isoDate(licenseTo),
    'status': status,
    'status_desc': statusDesc,
    'additional_license_info': additionalLicenseInfo.map((e) => e.toUpdateJson()).toList(),
  };

  /// The form holds dates as `dd/MM/yyyy`; both endpoints expect a plain
  /// `yyyy-MM-dd` (legacy `LicenseInformation._dateOnly` sent the date half of
  /// a `DateTime.toString()`). Unparseable/empty values pass through untouched
  /// rather than becoming a bogus date.
  static String? _isoDate(String? value) {
    if (value == null || value.isEmpty) return value;
    final parsed = parseDdMmYyyy(value);
    return parsed == null ? value : formatIsoDate(parsed);
  }
}
