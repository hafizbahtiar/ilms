import 'package:ilms/features/billboard/domain/entities/billboard_status_summary.dart';

abstract class BillboardStatusSummaryRepository {
  /// Defaults both bounds to today when omitted.
  Future<BillboardStatusSummary> getStatusSummary({DateTime? dateFrom, DateTime? dateTo});
}
