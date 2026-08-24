import 'package:equatable/equatable.dart';

/// A historical, read-only minute record shown in the minutes history sheet.
class InvestigationMinute extends Equatable {
  const InvestigationMinute({this.minuteId, this.sequence, this.role, this.officer, this.date, this.minutes});

  final int? minuteId;
  final int? sequence;
  final String? role;
  final String? officer;
  final DateTime? date;
  final String? minutes;

  @override
  List<Object?> get props => [minuteId, sequence, role, officer, date, minutes];
}
