import 'package:equatable/equatable.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_advertisement.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_applicant_info.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_business_activity.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_location.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minute.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minutes_entry.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_photo.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_pollution_disturbance.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_premise_details.dart';

/// Aggregate root for the investigation view/edit form. There is no
/// "create" case — every investigation already exists on the server, so
/// [investigationNo] is always present (unlike premise/billboard's form
/// aggregate, which is nullable for a new entry).
class InvestigationDetails extends Equatable {
  const InvestigationDetails({
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
  final InvestigationApplicantInfo applicant;
  final InvestigationLocation location;
  final InvestigationPremiseDetails premiseDetails;
  final InvestigationBusinessActivity businessActivity;
  final InvestigationPollutionDisturbance pollutionDisturbance;
  final InvestigationAdvertisement advertisement;
  final List<InvestigationPhoto> photos;
  final List<InvestigationMinute> minutes;
  final InvestigationMinutesEntry minutesEntry;

  InvestigationDetails copyWith({
    int? investigationId,
    String? investigationStatus,
    InvestigationApplicantInfo? applicant,
    InvestigationLocation? location,
    InvestigationPremiseDetails? premiseDetails,
    InvestigationBusinessActivity? businessActivity,
    InvestigationPollutionDisturbance? pollutionDisturbance,
    InvestigationAdvertisement? advertisement,
    List<InvestigationPhoto>? photos,
    List<InvestigationMinute>? minutes,
    InvestigationMinutesEntry? minutesEntry,
  }) {
    return InvestigationDetails(
      investigationNo: investigationNo,
      investigationId: investigationId ?? this.investigationId,
      investigationStatus: investigationStatus ?? this.investigationStatus,
      applicant: applicant ?? this.applicant,
      location: location ?? this.location,
      premiseDetails: premiseDetails ?? this.premiseDetails,
      businessActivity: businessActivity ?? this.businessActivity,
      pollutionDisturbance: pollutionDisturbance ?? this.pollutionDisturbance,
      advertisement: advertisement ?? this.advertisement,
      photos: photos ?? this.photos,
      minutes: minutes ?? this.minutes,
      minutesEntry: minutesEntry ?? this.minutesEntry,
    );
  }

  @override
  List<Object?> get props => [
    investigationNo,
    investigationId,
    investigationStatus,
    applicant,
    location,
    premiseDetails,
    businessActivity,
    pollutionDisturbance,
    advertisement,
    photos,
    minutes,
    minutesEntry,
  ];
}
