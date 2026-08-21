import 'package:equatable/equatable.dart';

/// Single status bucket within a [PremiseStatusSummary] — e.g. `LEGAL: 12`.
class PremiseVisitStatusCount extends Equatable {
  const PremiseVisitStatusCount({required this.status, required this.value});

  final String status;
  final int value;

  @override
  List<Object?> get props => [status, value];
}

/// Aggregate visit-status counts for a date range — backs the homepage
/// status summary donut chart.
class PremiseStatusSummary extends Equatable {
  const PremiseStatusSummary({
    required this.dateFrom,
    required this.dateTo,
    required this.total,
    this.visitStatus = const [],
  });

  final String dateFrom;
  final String dateTo;
  final int total;
  final List<PremiseVisitStatusCount> visitStatus;

  @override
  List<Object?> get props => [dateFrom, dateTo, total, visitStatus];
}
