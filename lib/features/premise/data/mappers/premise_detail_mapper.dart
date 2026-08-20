import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';
import 'package:ilms/features/premise/domain/entities/premise_image_upload_status.dart';
import 'package:ilms/shared/lookups/lookup_labels.dart';
import 'package:ilms/shared/models/general_model.dart';

/// Maps `/api/premiseCensus/detail` payload into a local draft snapshot.
class PremiseDetailMapper {
  PremiseDetailMapper._();

  /// Full detail mapping — for view/edit flows.
  static PremiseDraftPayloadModel fromApiDetail(Map<String, dynamic> data) {
    return _fromApiDetail(data, includeImages: true);
  }

  /// Duplicate flow — carry premise data only; omit census photos and remarks.
  static PremiseDraftPayloadModel fromApiDetailForDuplicate(Map<String, dynamic> data) {
    return _fromApiDetail(data, includeImages: false);
  }

  static PremiseDraftPayloadModel _fromApiDetail(
    Map<String, dynamic> data, {
    required bool includeImages,
  }) {
    final company = _asMap(data['company_details']);
    final contact = _asMap(data['contact_person']);
    final details = _asMap(data['premise_details']);
    final rawImages = data['images'];
    // Remarks are intentionally ignored — duplicate starts with a clean remarks tab.

    final fields = <String, String>{
      'companyName': _string(company['company_name']),
      'registerNumber': _string(company['register_no']),
      'companyTelNo': _string(company['tel_no']),
      'companyFaxNo': _string(company['fax_no']),
      'stickerNo': _string(company['sticker_no']),
      'censusDate': _string(company['census_date']),
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
      'businessType': _lookupDisplay(
        _string(details['business_type']),
        _string(details['business_type_desc']),
      ),
      'premiseType': _lookupDisplay(
        _string(details['premise_type']),
        _string(details['premise_type_desc']),
      ),
      'width': _string(details['width']),
      'length': _string(details['length']),
    };

    return PremiseDraftPayloadModel(
      companyStateCode: _nullableString(company['state']),
      companyPostcode: _nullableString(company['postcode']),
      fields: fields,
      censusImages: includeImages ? _mapImages(rawImages) : const [],
    );
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
}
