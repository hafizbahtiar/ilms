import 'package:equatable/equatable.dart';

/// Maklumat Premis — fully editable, no mandatory fields.
class InvestigationPremiseDetails extends Equatable {
  const InvestigationPremiseDetails({
    this.premisePosition,
    this.premiseLeft,
    this.premiseRight,
    this.premiseAbove,
    this.premiseBelow,
    this.buildingType,
    this.level,
    this.buildingStatus,
    this.premiseModification = false,
    this.premiseLength,
    this.premiseWidth,
    this.similarPremisesCount,
  });

  final String? premisePosition;
  final String? premiseLeft;
  final String? premiseRight;
  final String? premiseAbove;
  final String? premiseBelow;
  final String? buildingType;
  final String? level;
  final String? buildingStatus;
  final bool premiseModification;
  final String? premiseLength;
  final String? premiseWidth;
  final String? similarPremisesCount;

  InvestigationPremiseDetails copyWith({
    String? premisePosition,
    String? premiseLeft,
    String? premiseRight,
    String? premiseAbove,
    String? premiseBelow,
    String? buildingType,
    String? level,
    String? buildingStatus,
    bool? premiseModification,
    String? premiseLength,
    String? premiseWidth,
    String? similarPremisesCount,
  }) {
    return InvestigationPremiseDetails(
      premisePosition: premisePosition ?? this.premisePosition,
      premiseLeft: premiseLeft ?? this.premiseLeft,
      premiseRight: premiseRight ?? this.premiseRight,
      premiseAbove: premiseAbove ?? this.premiseAbove,
      premiseBelow: premiseBelow ?? this.premiseBelow,
      buildingType: buildingType ?? this.buildingType,
      level: level ?? this.level,
      buildingStatus: buildingStatus ?? this.buildingStatus,
      premiseModification: premiseModification ?? this.premiseModification,
      premiseLength: premiseLength ?? this.premiseLength,
      premiseWidth: premiseWidth ?? this.premiseWidth,
      similarPremisesCount: similarPremisesCount ?? this.similarPremisesCount,
    );
  }

  @override
  List<Object?> get props => [
    premisePosition,
    premiseLeft,
    premiseRight,
    premiseAbove,
    premiseBelow,
    buildingType,
    level,
    buildingStatus,
    premiseModification,
    premiseLength,
    premiseWidth,
    similarPremisesCount,
  ];
}
