import 'package:ilms/features/investigation/data/models/investigation_draft_payload_model.dart';
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

/// Converts [InvestigationDetails] to/from the local draft blob.
class InvestigationDraftMapper {
  InvestigationDraftMapper._();

  static InvestigationDraftPayloadModel toPayload(InvestigationDetails details) {
    return InvestigationDraftPayloadModel(
      investigationNo: details.investigationNo,
      investigationId: details.investigationId,
      investigationStatus: details.investigationStatus,
      applicant: {
        'license_file_no': details.applicant.licenseFileNo,
        'applicant_name': details.applicant.applicantName,
        'identification_no': details.applicant.identificationNo,
        'company_name': details.applicant.companyName,
        'registration_no': details.applicant.registrationNo,
        'business_types': details.applicant.businessTypes
            .map((e) => {'code': e.code, 'description': e.description})
            .toList(),
        'advertisement_types': details.applicant.advertisementTypes
            .map((e) => {'code': e.code, 'description': e.description})
            .toList(),
      },
      location: {
        'parliament_code': details.location.parliamentCode,
        'parliament_desc': details.location.parliamentDesc,
        'area_code': details.location.areaCode,
        'area_desc': details.location.areaDesc,
      },
      premiseDetails: {
        'premise_position': details.premiseDetails.premisePosition,
        'premise_left': details.premiseDetails.premiseLeft,
        'premise_right': details.premiseDetails.premiseRight,
        'premise_above': details.premiseDetails.premiseAbove,
        'premise_below': details.premiseDetails.premiseBelow,
        'building_type': details.premiseDetails.buildingType,
        'level': details.premiseDetails.level,
        'building_status': details.premiseDetails.buildingStatus,
        'premise_modification': details.premiseDetails.premiseModification,
        'premise_length': details.premiseDetails.premiseLength,
        'premise_width': details.premiseDetails.premiseWidth,
        'similar_premises_count': details.premiseDetails.similarPremisesCount,
      },
      businessActivity: {
        'floor_length': details.businessActivity.floorLength,
        'floor_width': details.businessActivity.floorWidth,
        'opening_time': details.businessActivity.openingTime,
        'closing_time': details.businessActivity.closingTime,
      },
      pollutionDisturbance: {
        'placing_furniture': details.pollutionDisturbance.placingFurniture,
        'chair_count': details.pollutionDisturbance.chairCount,
        'table_count': details.pollutionDisturbance.tableCount,
        'stall_count': details.pollutionDisturbance.stallCount,
        'machine_count': details.pollutionDisturbance.machineCount,
        'hair_salon_chair_count': details.pollutionDisturbance.hairSalonChairCount,
        'room_count': details.pollutionDisturbance.roomCount,
        'student_count': details.pollutionDisturbance.studentCount,
        'petrol_liters': details.pollutionDisturbance.petrolLiters,
        'diesel_liters': details.pollutionDisturbance.dieselLiters,
        'gas_liters': details.pollutionDisturbance.gasLiters,
        'other_activities': details.pollutionDisturbance.otherActivities,
      },
      advertisement: {
        'displayed': details.advertisement.displayed,
        'location': details.advertisement.location,
        'compliant': details.advertisement.compliant,
        'non_compliant_reason': details.advertisement.nonCompliantReason,
        'malay_language': details.advertisement.malayLanguage,
        'size_compliant': details.advertisement.sizeCompliant,
        'spelling_compliant': details.advertisement.spellingCompliant,
      },
      photos: details.photos
          .map(
            (photo) => {
              'image_id': photo.imageId,
              'sequence': photo.sequence,
              'uploaded_by': photo.uploadedBy,
              'uploaded_at': photo.uploadedAt?.toIso8601String(),
              'url': photo.url,
              if (photo.bytes != null) 'file': encodeDraftPhotoBytes(photo.bytes!),
            },
          )
          .toList(),
      minutes: details.minutes
          .map(
            (minute) => {
              'minute_id': minute.minuteId,
              'sequence': minute.sequence,
              'role': minute.role,
              'officer': minute.officer,
              'date': minute.date?.toIso8601String(),
              'minutes': minute.minutes,
            },
          )
          .toList(),
      minutesEntry: {
        'investigation_date': details.minutesEntry.investigationDate?.toIso8601String(),
        'investigation_time': details.minutesEntry.investigationTime,
        'prepared_by': details.minutesEntry.preparedBy,
        'minutes': details.minutesEntry.minutes,
      },
    );
  }

  static InvestigationDetails toDomain(InvestigationDraftPayloadModel payload) {
    return InvestigationDetails(
      investigationNo: payload.investigationNo,
      investigationId: payload.investigationId,
      investigationStatus: payload.investigationStatus,
      applicant: InvestigationApplicantInfo(
        licenseFileNo: payload.applicant['license_file_no'] as String?,
        applicantName: payload.applicant['applicant_name'] as String?,
        identificationNo: payload.applicant['identification_no'] as String?,
        companyName: payload.applicant['company_name'] as String?,
        registrationNo: payload.applicant['registration_no'] as String?,
        businessTypes: _codeDescriptions(payload.applicant['business_types']),
        advertisementTypes: _codeDescriptions(payload.applicant['advertisement_types']),
      ),
      location: InvestigationLocation(
        parliamentCode: payload.location['parliament_code'] as String?,
        parliamentDesc: payload.location['parliament_desc'] as String?,
        areaCode: payload.location['area_code'] as String?,
        areaDesc: payload.location['area_desc'] as String?,
      ),
      premiseDetails: InvestigationPremiseDetails(
        premisePosition: payload.premiseDetails['premise_position'] as String?,
        premiseLeft: payload.premiseDetails['premise_left'] as String?,
        premiseRight: payload.premiseDetails['premise_right'] as String?,
        premiseAbove: payload.premiseDetails['premise_above'] as String?,
        premiseBelow: payload.premiseDetails['premise_below'] as String?,
        buildingType: payload.premiseDetails['building_type'] as String?,
        level: payload.premiseDetails['level'] as String?,
        buildingStatus: payload.premiseDetails['building_status'] as String?,
        premiseModification: payload.premiseDetails['premise_modification'] as bool? ?? false,
        premiseLength: payload.premiseDetails['premise_length'] as String?,
        premiseWidth: payload.premiseDetails['premise_width'] as String?,
        similarPremisesCount: payload.premiseDetails['similar_premises_count'] as String?,
      ),
      businessActivity: InvestigationBusinessActivity(
        floorLength: payload.businessActivity['floor_length'] as String?,
        floorWidth: payload.businessActivity['floor_width'] as String?,
        openingTime: payload.businessActivity['opening_time'] as String?,
        closingTime: payload.businessActivity['closing_time'] as String?,
      ),
      pollutionDisturbance: InvestigationPollutionDisturbance(
        placingFurniture: payload.pollutionDisturbance['placing_furniture'] as bool? ?? false,
        chairCount: payload.pollutionDisturbance['chair_count'] as String?,
        tableCount: payload.pollutionDisturbance['table_count'] as String?,
        stallCount: payload.pollutionDisturbance['stall_count'] as String?,
        machineCount: payload.pollutionDisturbance['machine_count'] as String?,
        hairSalonChairCount: payload.pollutionDisturbance['hair_salon_chair_count'] as String?,
        roomCount: payload.pollutionDisturbance['room_count'] as String?,
        studentCount: payload.pollutionDisturbance['student_count'] as String?,
        petrolLiters: payload.pollutionDisturbance['petrol_liters'] as String?,
        dieselLiters: payload.pollutionDisturbance['diesel_liters'] as String?,
        gasLiters: payload.pollutionDisturbance['gas_liters'] as String?,
        otherActivities: payload.pollutionDisturbance['other_activities'] as String?,
      ),
      advertisement: InvestigationAdvertisement(
        displayed: payload.advertisement['displayed'] as bool? ?? false,
        location: payload.advertisement['location'] as String?,
        compliant: payload.advertisement['compliant'] as bool? ?? false,
        nonCompliantReason: payload.advertisement['non_compliant_reason'] as String?,
        malayLanguage: payload.advertisement['malay_language'] as bool? ?? false,
        sizeCompliant: payload.advertisement['size_compliant'] as bool? ?? false,
        spellingCompliant: payload.advertisement['spelling_compliant'] as bool? ?? false,
      ),
      photos: payload.photos
          .map(
            (photo) => InvestigationPhoto(
              imageId: photo['image_id'] as int?,
              sequence: photo['sequence'] as int?,
              uploadedBy: photo['uploaded_by'] as String?,
              uploadedAt: _tryParseDate(photo['uploaded_at']),
              url: photo['url'] as String?,
              bytes: decodeDraftPhotoBytes(photo['file']),
            ),
          )
          .toList(),
      minutes: payload.minutes
          .map(
            (minute) => InvestigationMinute(
              minuteId: minute['minute_id'] as int?,
              sequence: minute['sequence'] as int?,
              role: minute['role'] as String?,
              officer: minute['officer'] as String?,
              date: _tryParseDate(minute['date']),
              minutes: minute['minutes'] as String?,
            ),
          )
          .toList(),
      minutesEntry: InvestigationMinutesEntry(
        investigationDate: _tryParseDate(payload.minutesEntry['investigation_date']),
        investigationTime: payload.minutesEntry['investigation_time'] as String?,
        preparedBy: payload.minutesEntry['prepared_by'] as String?,
        minutes: payload.minutesEntry['minutes'] as String?,
      ),
    );
  }

  static List<InvestigationCodeDescription> _codeDescriptions(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      return InvestigationCodeDescription(code: map['code'] as String?, description: map['description'] as String?);
    }).toList();
  }

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
