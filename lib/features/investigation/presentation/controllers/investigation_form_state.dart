import 'package:flutter/material.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_advertisement.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_applicant_info.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_business_activity.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_location.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minute.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minutes_entry.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_photo.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_pollution_disturbance.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_premise_details.dart';

/// No `create`/`duplicate` — every investigation already exists on the
/// server; the app only views or edits.
enum InvestigationFormMode { view, edit }

extension InvestigationFormModeX on InvestigationFormMode {
  bool get isReadOnly => this == InvestigationFormMode.view;

  static InvestigationFormMode fromQuery(String? value) {
    return switch (value) {
      'edit' => InvestigationFormMode.edit,
      _ => InvestigationFormMode.view,
    };
  }
}

@immutable
class InvestigationFormSession {
  const InvestigationFormSession({required this.mode, this.instanceKey, required this.investigationNo});

  final InvestigationFormMode mode;
  final String? instanceKey;
  final String investigationNo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestigationFormSession &&
          other.mode == mode &&
          other.instanceKey == instanceKey &&
          other.investigationNo == investigationNo;

  @override
  int get hashCode => Object.hash(mode, instanceKey, investigationNo);
}

class InvestigationFormState {
  const InvestigationFormState({
    required this.mode,
    this.activeSectionIndex = 0,
    this.isSubmitting = false,
    this.isLoading = true,
    this.isResumedFromDraft = false,
    this.applicant = const InvestigationApplicantInfo(),
    this.location = const InvestigationLocation(),
    this.premiseDetails = const InvestigationPremiseDetails(),
    this.businessActivity = const InvestigationBusinessActivity(),
    this.pollutionDisturbance = const InvestigationPollutionDisturbance(),
    this.advertisement = const InvestigationAdvertisement(),
    this.photos = const [],
    this.minutes = const [],
    this.minutesEntry = const InvestigationMinutesEntry(),
  });

  final InvestigationFormMode mode;
  final int activeSectionIndex;
  final bool isSubmitting;

  /// True while loading the record (and any pending draft) from storage.
  final bool isLoading;

  /// True when the loaded state came from a local edit-session draft rather
  /// than the server record as-is.
  final bool isResumedFromDraft;

  final InvestigationApplicantInfo applicant;
  final InvestigationLocation location;
  final InvestigationPremiseDetails premiseDetails;
  final InvestigationBusinessActivity businessActivity;
  final InvestigationPollutionDisturbance pollutionDisturbance;
  final InvestigationAdvertisement advertisement;
  final List<InvestigationPhoto> photos;
  final List<InvestigationMinute> minutes;
  final InvestigationMinutesEntry minutesEntry;

  bool get isReadOnly => mode.isReadOnly;

  InvestigationFormState copyWith({
    InvestigationFormMode? mode,
    int? activeSectionIndex,
    bool? isSubmitting,
    bool? isLoading,
    bool? isResumedFromDraft,
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
    return InvestigationFormState(
      mode: mode ?? this.mode,
      activeSectionIndex: activeSectionIndex ?? this.activeSectionIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
      isResumedFromDraft: isResumedFromDraft ?? this.isResumedFromDraft,
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
}

/// Text controllers for every editable text/number field across the
/// Maklumat Premis and Minit sections (applicant info & location are
/// read-only display, so they need no controllers).
class InvestigationFormFields {
  InvestigationFormFields() {
    premisePosition = TextEditingController();
    premiseLeft = TextEditingController();
    premiseRight = TextEditingController();
    premiseAbove = TextEditingController();
    premiseBelow = TextEditingController();
    buildingType = TextEditingController();
    level = TextEditingController();
    buildingStatus = TextEditingController();
    premiseLength = TextEditingController();
    premiseWidth = TextEditingController();
    similarPremisesCount = TextEditingController();

    floorLength = TextEditingController();
    floorWidth = TextEditingController();
    openingTime = TextEditingController();
    closingTime = TextEditingController();

    chairCount = TextEditingController();
    tableCount = TextEditingController();
    stallCount = TextEditingController();
    machineCount = TextEditingController();
    hairSalonChairCount = TextEditingController();
    roomCount = TextEditingController();
    studentCount = TextEditingController();
    petrolLiters = TextEditingController();
    dieselLiters = TextEditingController();
    gasLiters = TextEditingController();
    otherActivities = TextEditingController();

    advertisementLocation = TextEditingController();
    advertisementNonCompliantReason = TextEditingController();

    minutesDate = TextEditingController();
    minutesTime = TextEditingController();
    minutesPreparedBy = TextEditingController();
    minutesText = TextEditingController();
  }

  late final TextEditingController premisePosition;
  late final TextEditingController premiseLeft;
  late final TextEditingController premiseRight;
  late final TextEditingController premiseAbove;
  late final TextEditingController premiseBelow;
  late final TextEditingController buildingType;
  late final TextEditingController level;
  late final TextEditingController buildingStatus;
  late final TextEditingController premiseLength;
  late final TextEditingController premiseWidth;
  late final TextEditingController similarPremisesCount;

  late final TextEditingController floorLength;
  late final TextEditingController floorWidth;
  late final TextEditingController openingTime;
  late final TextEditingController closingTime;

  late final TextEditingController chairCount;
  late final TextEditingController tableCount;
  late final TextEditingController stallCount;
  late final TextEditingController machineCount;
  late final TextEditingController hairSalonChairCount;
  late final TextEditingController roomCount;
  late final TextEditingController studentCount;
  late final TextEditingController petrolLiters;
  late final TextEditingController dieselLiters;
  late final TextEditingController gasLiters;
  late final TextEditingController otherActivities;

  late final TextEditingController advertisementLocation;
  late final TextEditingController advertisementNonCompliantReason;

  late final TextEditingController minutesDate;
  late final TextEditingController minutesTime;
  late final TextEditingController minutesPreparedBy;
  late final TextEditingController minutesText;

  void dispose() {
    for (final controller in [
      premisePosition,
      premiseLeft,
      premiseRight,
      premiseAbove,
      premiseBelow,
      buildingType,
      level,
      buildingStatus,
      premiseLength,
      premiseWidth,
      similarPremisesCount,
      floorLength,
      floorWidth,
      openingTime,
      closingTime,
      chairCount,
      tableCount,
      stallCount,
      machineCount,
      hairSalonChairCount,
      roomCount,
      studentCount,
      petrolLiters,
      dieselLiters,
      gasLiters,
      otherActivities,
      advertisementLocation,
      advertisementNonCompliantReason,
      minutesDate,
      minutesTime,
      minutesPreparedBy,
      minutesText,
    ]) {
      controller.dispose();
    }
  }
}
