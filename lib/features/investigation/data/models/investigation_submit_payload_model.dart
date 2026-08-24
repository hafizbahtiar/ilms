import 'package:ilms/features/investigation/domain/entities/investigation_advertisement.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_business_activity.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_location.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minutes_entry.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_pollution_disturbance.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_premise_details.dart';

/// Request body for `/api/investigation/update`, mirroring legacy
/// `DetailsSiasatanData.toJsonUpdate()` — applicant info and location are
/// read-only and NOT sent; images are also omitted (uploaded separately via
/// `/create-photo`).
class InvestigationSubmitPayloadModel {
  const InvestigationSubmitPayloadModel({
    required this.investigationNo,
    required this.location,
    required this.premiseDetails,
    required this.businessActivity,
    required this.pollutionDisturbance,
    required this.advertisement,
    required this.minutesEntry,
  });

  final String investigationNo;
  final InvestigationLocation location;
  final InvestigationPremiseDetails premiseDetails;
  final InvestigationBusinessActivity businessActivity;
  final InvestigationPollutionDisturbance pollutionDisturbance;
  final InvestigationAdvertisement advertisement;
  final InvestigationMinutesEntry minutesEntry;

  factory InvestigationSubmitPayloadModel.fromDomain(InvestigationDetails details) {
    return InvestigationSubmitPayloadModel(
      investigationNo: details.investigationNo,
      location: details.location,
      premiseDetails: details.premiseDetails,
      businessActivity: details.businessActivity,
      pollutionDisturbance: details.pollutionDisturbance,
      advertisement: details.advertisement,
      minutesEntry: details.minutesEntry,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'investigation_no': investigationNo,
      'location': {'parliament': location.parliamentCode, 'area': location.areaCode},
      'investigation_details': {
        'premise_position': premiseDetails.premisePosition,
        'premise_left': premiseDetails.premiseLeft,
        'premise_right': premiseDetails.premiseRight,
        'premise_above': premiseDetails.premiseAbove,
        'premise_below': premiseDetails.premiseBelow,
        'building_type': premiseDetails.buildingType,
        'level': premiseDetails.level,
        'building_status': premiseDetails.buildingStatus,
        'premise_modification': _yesNo(premiseDetails.premiseModification),
        'premise_length': _numericOrZero(premiseDetails.premiseLength),
        'premise_width': _numericOrZero(premiseDetails.premiseWidth),
        'similar_premises_count': _numericOrZero(premiseDetails.similarPremisesCount),
      },
      'business_activities': {
        'floor_length': _numericOrZero(businessActivity.floorLength),
        'floor_width': _numericOrZero(businessActivity.floorWidth),
        'opening_time': businessActivity.openingTime,
        'closing_time': businessActivity.closingTime,
      },
      // S-M8: `chair_count`/`table_count`/`stall_count` belong to the
      // `placingFurniture` toggle and clear when it's off. The remaining
      // counters are independent and always sent as-is.
      'pollution_disturbance': {
        'placing_furniture': _yesNo(pollutionDisturbance.placingFurniture),
        'chair_count': _numericOrZero(pollutionDisturbance.placingFurniture ? pollutionDisturbance.chairCount : null),
        'table_count': _numericOrZero(pollutionDisturbance.placingFurniture ? pollutionDisturbance.tableCount : null),
        'stall_count': _numericOrZero(pollutionDisturbance.placingFurniture ? pollutionDisturbance.stallCount : null),
        'machine_count': _numericOrZero(pollutionDisturbance.machineCount),
        'hair_salon_chair_count': _numericOrZero(pollutionDisturbance.hairSalonChairCount),
        'room_count': _numericOrZero(pollutionDisturbance.roomCount),
        'student_count': _numericOrZero(pollutionDisturbance.studentCount),
        'petrol_liters': _numericOrZero(pollutionDisturbance.petrolLiters),
        'diesel_liters': _numericOrZero(pollutionDisturbance.dieselLiters),
        'gas_liters': _numericOrZero(pollutionDisturbance.gasLiters),
        'other_activities': pollutionDisturbance.otherActivities,
      },
      'advertisement': {
        'advertisement_displayed': _yesNo(advertisement.displayed),
        'advertisement_location': advertisement.displayed ? advertisement.location : '',
        'advertisement_compliant': _yesNo(advertisement.compliant),
        'advertisement_non_compliant_reason': advertisement.compliant ? '' : advertisement.nonCompliantReason,
        'malay_language': _yesNo(advertisement.malayLanguage),
        'advertisement_size': _yesNo(advertisement.sizeCompliant),
        'advertisement_spelling': _yesNo(advertisement.spellingCompliant),
      },
      'investigation_minutes': {
        'investigation_date': _formatDate(minutesEntry.investigationDate),
        'investigation_time': minutesEntry.investigationTime,
        'prepared_by': minutesEntry.preparedBy,
        'minutes': minutesEntry.minutes,
      },
    };
  }

  static String _yesNo(bool value) => value ? 'Y' : 'N';

  /// Backend decimal columns reject `"-"`/`""` — emit `"0"` for any value
  /// that is not a parseable number.
  static String _numericOrZero(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == '-') return '0';
    return double.tryParse(trimmed) != null ? trimmed : '0';
  }

  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
