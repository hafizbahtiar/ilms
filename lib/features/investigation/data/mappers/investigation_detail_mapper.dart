import 'package:ilms/features/investigation/domain/entities/investigation_advertisement.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_applicant_info.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_business_activity.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_code_description.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_location.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minute.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minutes_entry.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_photo.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_pollution_disturbance.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_premise_details.dart';

/// Maps `/api/investigation/detail` payload into [InvestigationDetails].
/// Mirrors legacy `DetailsSiasatanData.fromJson`.
class InvestigationDetailMapper {
  InvestigationDetailMapper._();

  static InvestigationDetails fromApiDetail(Map<String, dynamic> data) {
    final applicant = _asMap(data['applicant_information']);
    final location = _asMap(data['location']);
    final premiseDetails = _asMap(data['investigation_details']);
    final businessActivity = _asMap(data['business_activities']);
    final pollutionDisturbance = _asMap(data['pollution_disturbance']);
    final advertisement = _asMap(data['advertisement']);
    final minutesEntry = _asMap(data['investigation_minutes']);

    return InvestigationDetails(
      investigationNo: _string(data['investigation_no']) ?? '',
      investigationId: _int(data['investigation_id']),
      investigationStatus: _string(data['investigation_status']),
      applicant: InvestigationApplicantInfo(
        licenseFileNo: _string(applicant['license_file_no']),
        applicantName: _string(applicant['applicant_name']),
        identificationNo: _string(applicant['identification_no']),
        companyName: _string(applicant['company_name']),
        registrationNo: _string(applicant['registration_no']),
        businessTypes: _mapCodeDescriptions(applicant['business_types']),
        advertisementTypes: _mapCodeDescriptions(applicant['advertisement_types']),
      ),
      location: InvestigationLocation(
        parliamentCode: _string(location['parliament']),
        areaCode: _string(location['area']),
      ),
      premiseDetails: InvestigationPremiseDetails(
        premisePosition: _string(premiseDetails['premise_position']),
        premiseLeft: _string(premiseDetails['premise_left']),
        premiseRight: _string(premiseDetails['premise_right']),
        premiseAbove: _string(premiseDetails['premise_above']),
        premiseBelow: _string(premiseDetails['premise_below']),
        buildingType: _string(premiseDetails['building_type']),
        level: _string(premiseDetails['level']),
        buildingStatus: _string(premiseDetails['building_status']),
        premiseModification: _isYes(premiseDetails['premise_modification']),
        premiseLength: _string(premiseDetails['premise_length']),
        premiseWidth: _string(premiseDetails['premise_width']),
        similarPremisesCount: _string(premiseDetails['similar_premises_count']) ?? '0',
      ),
      businessActivity: InvestigationBusinessActivity(
        floorLength: _string(businessActivity['floor_length']),
        floorWidth: _string(businessActivity['floor_width']),
        openingTime: _string(businessActivity['opening_time']),
        closingTime: _string(businessActivity['closing_time']),
      ),
      pollutionDisturbance: InvestigationPollutionDisturbance(
        placingFurniture: _isYes(pollutionDisturbance['placing_furniture']),
        chairCount: _string(pollutionDisturbance['chair_count']) ?? '0',
        tableCount: _string(pollutionDisturbance['table_count']) ?? '0',
        stallCount: _string(pollutionDisturbance['stall_count']) ?? '0',
        machineCount: _string(pollutionDisturbance['machine_count']) ?? '0',
        hairSalonChairCount: _string(pollutionDisturbance['hair_salon_chair_count']) ?? '0',
        roomCount: _string(pollutionDisturbance['room_count']) ?? '0',
        studentCount: _string(pollutionDisturbance['student_count']) ?? '0',
        petrolLiters: _string(pollutionDisturbance['petrol_liters']) ?? '0',
        dieselLiters: _string(pollutionDisturbance['diesel_liters']) ?? '0',
        gasLiters: _string(pollutionDisturbance['gas_liters']) ?? '0',
        otherActivities: _string(pollutionDisturbance['other_activities']),
      ),
      advertisement: InvestigationAdvertisement(
        displayed: _isYes(advertisement['advertisement_displayed']),
        location: _string(advertisement['advertisement_location']),
        compliant: _isYes(advertisement['advertisement_compliant']),
        nonCompliantReason: _string(advertisement['advertisement_non_compliant_reason']),
        malayLanguage: _isYes(advertisement['malay_language']),
        sizeCompliant: _isYes(advertisement['advertisement_size']),
        spellingCompliant: _isYes(advertisement['advertisement_spelling']),
      ),
      photos: _mapPhotos(data['images']),
      minutes: _mapMinutes(data['minutes']),
      minutesEntry: InvestigationMinutesEntry(
        investigationDate: _tryParseDate(minutesEntry['investigation_date']),
        investigationTime: _string(minutesEntry['investigation_time']),
        preparedBy: _string(minutesEntry['prepared_by']),
        minutes: _string(minutesEntry['minutes']),
      ),
    );
  }

  static List<InvestigationCodeDescription> _mapCodeDescriptions(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return InvestigationCodeDescription(code: _string(map['code']), description: _string(map['description']));
    }).toList();
  }

  static List<InvestigationPhoto> _mapPhotos(dynamic rawImages) {
    if (rawImages is! List) return const [];
    return rawImages.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return InvestigationPhoto(
        imageId: _int(map['image_id'] ?? map['id']),
        sequence: _int(map['sequence'] ?? map['seq']),
        uploadedBy: _string(map['uploaded_by']),
        uploadedAt: _tryParseDate(map['uploaded_at']),
        url: _string(map['url'] ?? map['image_url'] ?? map['thumbnail_url']),
      );
    }).toList();
  }

  static List<InvestigationMinute> _mapMinutes(dynamic rawMinutes) {
    if (rawMinutes is! List) return const [];
    return rawMinutes.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return InvestigationMinute(
        minuteId: _int(map['minute_id']),
        sequence: _int(map['sequence']),
        role: _string(map['role']),
        officer: _string(map['officer']),
        date: _tryParseDate(map['date']),
        minutes: _string(map['minutes']),
      );
    }).toList();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static String? _string(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static int? _int(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value');
  }

  static bool _isYes(dynamic value) => value?.toString().toUpperCase() == 'Y';

  /// The backend sends `""` (not `null`) for unset date fields;
  /// `DateTime.parse("")` throws — parse defensively so one bad date does not
  /// blank the whole form.
  static DateTime? _tryParseDate(dynamic raw) {
    final text = raw?.toString().trim();
    if (text == null || text.isEmpty) return null;
    try {
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }
}
