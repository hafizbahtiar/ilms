import 'dart:convert';
import 'dart:typed_data';

/// Local edit-session draft blob — one JSON object per `(ownerUserId,
/// investigationNo)`, mirroring legacy `SiasatanEditSessions`' single-blob
/// shape. Unlike the API's Y/N string encoding, booleans are stored as JSON
/// booleans since this format never leaves the device.
class InvestigationDraftPayloadModel {
  const InvestigationDraftPayloadModel({
    required this.investigationNo,
    this.investigationId,
    this.investigationStatus,
    required this.applicant,
    required this.location,
    required this.premiseDetails,
    required this.businessActivity,
    required this.pollutionDisturbance,
    required this.advertisement,
    this.photos = const [],
    this.minutes = const [],
    required this.minutesEntry,
  });

  final String investigationNo;
  final int? investigationId;
  final String? investigationStatus;
  final Map<String, dynamic> applicant;
  final Map<String, dynamic> location;
  final Map<String, dynamic> premiseDetails;
  final Map<String, dynamic> businessActivity;
  final Map<String, dynamic> pollutionDisturbance;
  final Map<String, dynamic> advertisement;
  final List<Map<String, dynamic>> photos;
  final List<Map<String, dynamic>> minutes;
  final Map<String, dynamic> minutesEntry;

  Map<String, dynamic> toJson() => {
    'investigation_no': investigationNo,
    'investigation_id': investigationId,
    'investigation_status': investigationStatus,
    'applicant': applicant,
    'location': location,
    'premise_details': premiseDetails,
    'business_activity': businessActivity,
    'pollution_disturbance': pollutionDisturbance,
    'advertisement': advertisement,
    'photos': photos,
    'minutes': minutes,
    'minutes_entry': minutesEntry,
  };

  factory InvestigationDraftPayloadModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> asMapList(dynamic value) {
      if (value is! List) return const [];
      return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }

    Map<String, dynamic> asMap(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : const {};

    return InvestigationDraftPayloadModel(
      investigationNo: json['investigation_no']?.toString() ?? '',
      investigationId: json['investigation_id'] as int?,
      investigationStatus: json['investigation_status'] as String?,
      applicant: asMap(json['applicant']),
      location: asMap(json['location']),
      premiseDetails: asMap(json['premise_details']),
      businessActivity: asMap(json['business_activity']),
      pollutionDisturbance: asMap(json['pollution_disturbance']),
      advertisement: asMap(json['advertisement']),
      photos: asMapList(json['photos']),
      minutes: asMapList(json['minutes']),
      minutesEntry: asMap(json['minutes_entry']),
    );
  }

  String encode() => jsonEncode(toJson());

  static InvestigationDraftPayloadModel decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid investigation draft payload');
    }
    return InvestigationDraftPayloadModel.fromJson(decoded);
  }
}

/// base64 helpers for persisting newly-picked, not-yet-uploaded photo bytes
/// inside a photo entry's `file` key (Option B — survives Save & Exit).
Uint8List? decodeDraftPhotoBytes(dynamic raw) {
  final text = raw?.toString().trim();
  if (text == null || text.isEmpty) return null;
  try {
    return base64Decode(text);
  } catch (_) {
    return null;
  }
}

String encodeDraftPhotoBytes(Uint8List bytes) => base64Encode(bytes);
