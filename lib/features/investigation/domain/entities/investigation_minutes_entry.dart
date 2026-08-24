import 'package:equatable/equatable.dart';

/// The one editable minutes entry per submit — the only section with real
/// validation (all three fields mandatory).
class InvestigationMinutesEntry extends Equatable {
  const InvestigationMinutesEntry({this.investigationDate, this.investigationTime, this.preparedBy, this.minutes});

  final DateTime? investigationDate;
  final String? investigationTime;
  final String? preparedBy;
  final String? minutes;

  bool get isValid =>
      investigationDate != null &&
      (investigationTime?.trim().isNotEmpty ?? false) &&
      (minutes?.trim().isNotEmpty ?? false);

  InvestigationMinutesEntry copyWith({
    DateTime? investigationDate,
    String? investigationTime,
    String? preparedBy,
    String? minutes,
  }) {
    return InvestigationMinutesEntry(
      investigationDate: investigationDate ?? this.investigationDate,
      investigationTime: investigationTime ?? this.investigationTime,
      preparedBy: preparedBy ?? this.preparedBy,
      minutes: minutes ?? this.minutes,
    );
  }

  @override
  List<Object?> get props => [investigationDate, investigationTime, preparedBy, minutes];
}
