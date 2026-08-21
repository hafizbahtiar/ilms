import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_company_contact.dart';
import 'package:ilms/features/premise/domain/entities/premise_details.dart';
import 'package:ilms/features/premise/domain/entities/premise_detail_record.dart';
import 'package:ilms/features/premise/domain/entities/premise_image_upload_status.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';

/// Maps `/api/premiseCensus/detail` payload into a local draft snapshot.
class PremiseDetailMapper {
  PremiseDetailMapper._();

  /// Full detail mapping — for view/edit flows.
  static PremiseDraftPayloadModel fromApiDetail(Map<String, dynamic> data) {
    return _fromApiDetail(data, includeImages: true, includeVisitFindings: true);
  }

  /// Duplicate flow — carry structural premise data only; omit census
  /// photos and this visit's findings (remarks, licenses, business
  /// activities) — the surveyor re-collects those for the new visit.
  static PremiseDraftPayloadModel fromApiDetailForDuplicate(Map<String, dynamic> data) {
    return _fromApiDetail(data, includeImages: false, includeVisitFindings: false);
  }

  static PremiseDraftPayloadModel _fromApiDetail(
    Map<String, dynamic> data, {
    required bool includeImages,
    bool includeVisitFindings = true,
  }) {
    final company = _asMap(data['company_details']);
    final contact = _asMap(data['contact_person']);
    final details = _asMap(data['premise_details']);
    final rawImages = data['images'];
    final rawRemarks = data['remarks'];
    final rawLicenses = data['license_information'];
    final rawBusinessActivities = data['business_activities'];

    final fields = <String, String>{
      'companyName': _string(company['company_name']),
      'registerNumber': _string(company['register_no']),
      'companyTelNo': _string(company['tel_no']),
      'companyFaxNo': _string(company['fax_no']),
      'stickerNo': _string(company['sticker_no']),
      'censusDate': _formatDate(company['census_date']),
      'unit': _string(company['unit']),
      'building': _string(company['building']),
      'street1': _string(company['street1']),
      'street2': _string(company['street2']),
      'state': _lookupDisplay(_string(company['state']), null),
      'postcode': _postcodeDisplay(_string(company['postcode']), null),
      'area': _string(company['area']),
      'contactPersonName': _string(contact['name']),
      'contactPersonPhone': _string(contact['phone']),
      'contactPersonEmail': _string(contact['email']),
      'contactPersonPosition': _string(contact['position']),
      'traderName': _string(details['trader_name']),
      'businessType': _lookupDisplay(_string(details['business_type']), _string(details['business_type_desc'])),
      'premiseType': _lookupDisplay(_string(details['premise_type']), _string(details['premise_type_desc'])),
      'width': _string(details['width']),
      'length': _string(details['length']),
    };

    return PremiseDraftPayloadModel(
      companyStateCode: _nullableString(company['state']),
      companyPostcode: _nullableString(company['postcode']),
      fields: fields,
      censusImages: includeImages ? _mapImages(rawImages) : const [],
      remarks: includeVisitFindings ? _mapRemarks(rawRemarks) : const [],
      licenses: includeVisitFindings ? _mapLicenses(rawLicenses) : const [],
      businessActivities: includeVisitFindings ? _mapBusinessActivities(rawBusinessActivities) : const [],
    );
  }

  /// Read-only aggregate for the History document detail page — unlike
  /// [fromApiDetail], this keeps codes/descriptions separate (no merged
  /// display-label strings) and also carries visit status + audit metadata,
  /// which the form has no use for.
  static PremiseDetailRecord toDetailRecord(Map<String, dynamic> data, {required String visitNo}) {
    final company = _asMap(data['company_details']);
    final contact = _asMap(data['contact_person']);
    final details = _asMap(data['premise_details']);

    return PremiseDetailRecord(
      visitNo: visitNo,
      companyContact: PremiseCompanyContact(
        companyName: _nullableString(company['company_name']),
        registerNumber: _nullableString(company['register_no']),
        companyTelNo: _nullableString(company['tel_no']),
        companyFaxNo: _nullableString(company['fax_no']),
        stickerNo: _nullableString(company['sticker_no']),
        censusDate: _nullableFormattedDate(company['census_date']),
        unit: _nullableString(company['unit']),
        building: _nullableString(company['building']),
        street1: _nullableString(company['street1']),
        street2: _nullableString(company['street2']),
        stateDescription: _nullableString(company['state']),
        postcode: _nullableString(company['postcode']),
        areaDescription: _nullableString(company['area']),
        contactPersonName: _nullableString(contact['name']),
        contactPersonPhone: _nullableString(contact['phone']),
        contactPersonEmail: _nullableString(contact['email']),
        contactPersonPosition: _nullableString(contact['position']),
      ),
      details: PremiseDetails(
        traderName: _nullableString(details['trader_name']),
        businessTypeCode: _nullableString(details['business_type']),
        businessTypeDescription: _nullableString(details['business_type_desc']),
        premiseTypeCode: _nullableString(details['premise_type']),
        premiseTypeDescription: _nullableString(details['premise_type_desc']),
        width: _nullableString(details['width']),
        length: _nullableString(details['length']),
      ),
      addresses: _mapAddresses(data['premise_addresses']),
      licenses: _mapLicenses(data['license_information']),
      businessActivities: _mapBusinessActivities(data['business_activities']),
      remarks: _mapRemarks(data['remarks']),
      censusImages: _mapImages(data['images']),
      visitStatus: _nullableString(company['visit_status']),
      createdBy: _nullableString(data['created_by']),
      createdAt: _nullableString(data['created_at']),
      updatedBy: _nullableString(data['updated_by']),
      updatedAt: _nullableString(data['updated_at']),
    );
  }

  static List<PremiseAddress> _mapAddresses(dynamic rawAddresses) {
    if (rawAddresses is! List) return const [];

    return rawAddresses.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return PremiseAddress(
        premiseAddressId: map['paid'] is int ? map['paid'] as int : int.tryParse('${map['paid']}'),
        visitPremiseAddressId: map['vpa_id'] is int ? map['vpa_id'] as int : int.tryParse('${map['vpa_id']}'),
        unitNo: map['unit_no']?.toString(),
        floor: map['floor']?.toString(),
        blockNo: map['block_no']?.toString(),
        building: map['building']?.toString(),
        streetName: map['street_name']?.toString(),
        area: map['area']?.toString(),
        parliament: map['parliament']?.toString(),
        postcode: map['postcode']?.toString(),
        state: map['state']?.toString(),
        latitude: map['latitude']?.toString(),
        longitude: map['longitude']?.toString(),
      );
    }).toList();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  /// Server sends dates either as a bare `yyyy-MM-dd` or a full UTC
  /// timestamp (e.g. `census_date: "2025-01-21T16:00:00.000000Z"`) —
  /// reformat to the app's `dd/MM/yyyy` display convention. `.toLocal()`
  /// matters for the timestamp case: `16:00:00Z` is already the next day in
  /// Malaysia time, so formatting the UTC value directly would show the
  /// wrong calendar date. Falls back to the raw value if it doesn't parse,
  /// so nothing silently disappears.
  static String _formatDate(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return '';
    final parsed = DateTime.tryParse(text);
    return parsed == null ? text : formatDdMmYyyy(parsed.toLocal());
  }

  static String? _nullableFormattedDate(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    final parsed = DateTime.tryParse(text);
    return parsed == null ? text : formatDdMmYyyy(parsed.toLocal());
  }

  static String _lookupDisplay(String code, String? desc) {
    if (code.isEmpty && (desc == null || desc.isEmpty)) return '';
    return generalLookupLabel(GeneralModel(code: code.isEmpty ? null : code, desc: desc));
  }

  static String _postcodeDisplay(String code, String? desc) {
    if (code.isEmpty && (desc == null || desc.isEmpty)) return '';
    return generalPostcodeLabel(GeneralModel(code: code.isEmpty ? null : code, desc: desc));
  }

  static List<PremiseCensusImage> _mapImages(dynamic rawImages) {
    if (rawImages is! List) return const [];

    return rawImages.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      final url = map['image_url']?.toString();
      return PremiseCensusImage(
        id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
        typeCode: map['type']?.toString(),
        typeDescription: map['type_desc']?.toString(),
        networkUrl: url,
        uploadStatus: PremiseImageUploadStatus.uploaded,
      );
    }).toList();
  }

  static List<PremiseRemark> _mapRemarks(dynamic rawRemarks) {
    if (rawRemarks is! List) return const [];

    return rawRemarks.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return PremiseRemark(
        id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
        code: map['code']?.toString(),
        remark: map['remark']?.toString(),
        remarkType: map['remark_type']?.toString(),
        remarkDesc: map['remark_desc']?.toString(),
        description: map['description']?.toString(),
        createdAt: map['created_at']?.toString(),
      );
    }).toList();
  }

  static List<PremiseLicense> _mapLicenses(dynamic rawLicenses) {
    if (rawLicenses is! List) return const [];

    return rawLicenses.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return PremiseLicense(
        id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
        licenseNo: map['license_no']?.toString(),
        licenseFileNo: map['file_no']?.toString(),
        validFrom: _nullableFormattedDate(map['license_from']),
        validTo: _nullableFormattedDate(map['license_to']),
        status: map['status']?.toString(),
        statusDesc: map['status_desc']?.toString(),
        businessActivities: _mapLicenseActivities(map['additional_license_info']),
      );
    }).toList();
  }

  static List<PremiseLicenseActivity> _mapLicenseActivities(dynamic rawActivities) {
    if (rawActivities is! List) return const [];

    return rawActivities.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return PremiseLicenseActivity(
        businessType: map['business_type']?.toString(),
        businessTypeDesc: map['business_type_desc']?.toString(),
        status: map['status']?.toString(),
        statusDesc: map['status_desc']?.toString(),
        description: map['description']?.toString(),
        amount: map['amount']?.toString(),
      );
    }).toList();
  }

  static List<PremiseBusinessActivity> _mapBusinessActivities(dynamic rawActivities) {
    if (rawActivities is! List) return const [];

    return rawActivities.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return PremiseBusinessActivity(
        id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
        businessType: map['business_type']?.toString(),
        businessTypeDesc: map['business_type_desc']?.toString(),
        status: map['status']?.toString(),
        statusDesc: map['status_desc']?.toString(),
        description: map['description']?.toString(),
      );
    }).toList();
  }
}
