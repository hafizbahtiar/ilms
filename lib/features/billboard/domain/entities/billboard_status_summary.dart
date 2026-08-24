import 'package:equatable/equatable.dart';

/// Single billboard-type bucket within a [BillboardStatusSummary].
class BillboardTypeCount extends Equatable {
  const BillboardTypeCount({required this.type, required this.value});

  final String type;
  final int value;

  @override
  List<Object?> get props => [type, value];
}

/// Aggregate billboard-type counts for a date range — backs the list/home
/// activity summary widget.
class BillboardStatusSummary extends Equatable {
  const BillboardStatusSummary({
    required this.dateFrom,
    required this.dateTo,
    required this.total,
    this.types = const [],
  });

  final String dateFrom;
  final String dateTo;
  final int total;
  final List<BillboardTypeCount> types;

  @override
  List<Object?> get props => [dateFrom, dateTo, total, types];
}
