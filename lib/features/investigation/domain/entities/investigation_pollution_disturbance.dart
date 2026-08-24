import 'package:equatable/equatable.dart';

/// Pollution/Disturbance block inside Maklumat Premis.
///
/// [placingFurniture] ("Obstruction of Public Areas") gates
/// [chairCount]/[tableCount]/[stallCount] only — the remaining counters are
/// independent and always visible (mirrors legacy S-M8: they must never be
/// wiped when the toggle is off).
class InvestigationPollutionDisturbance extends Equatable {
  const InvestigationPollutionDisturbance({
    this.placingFurniture = false,
    this.chairCount,
    this.tableCount,
    this.stallCount,
    this.machineCount,
    this.hairSalonChairCount,
    this.roomCount,
    this.studentCount,
    this.petrolLiters,
    this.dieselLiters,
    this.gasLiters,
    this.otherActivities,
  });

  final bool placingFurniture;
  final String? chairCount;
  final String? tableCount;
  final String? stallCount;
  final String? machineCount;
  final String? hairSalonChairCount;
  final String? roomCount;
  final String? studentCount;
  final String? petrolLiters;
  final String? dieselLiters;
  final String? gasLiters;
  final String? otherActivities;

  InvestigationPollutionDisturbance copyWith({
    bool? placingFurniture,
    String? chairCount,
    String? tableCount,
    String? stallCount,
    String? machineCount,
    String? hairSalonChairCount,
    String? roomCount,
    String? studentCount,
    String? petrolLiters,
    String? dieselLiters,
    String? gasLiters,
    String? otherActivities,
  }) {
    return InvestigationPollutionDisturbance(
      placingFurniture: placingFurniture ?? this.placingFurniture,
      chairCount: chairCount ?? this.chairCount,
      tableCount: tableCount ?? this.tableCount,
      stallCount: stallCount ?? this.stallCount,
      machineCount: machineCount ?? this.machineCount,
      hairSalonChairCount: hairSalonChairCount ?? this.hairSalonChairCount,
      roomCount: roomCount ?? this.roomCount,
      studentCount: studentCount ?? this.studentCount,
      petrolLiters: petrolLiters ?? this.petrolLiters,
      dieselLiters: dieselLiters ?? this.dieselLiters,
      gasLiters: gasLiters ?? this.gasLiters,
      otherActivities: otherActivities ?? this.otherActivities,
    );
  }

  @override
  List<Object?> get props => [
    placingFurniture,
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
  ];
}
