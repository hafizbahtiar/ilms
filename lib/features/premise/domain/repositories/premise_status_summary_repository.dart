import 'package:ilms/features/premise/domain/entities/premise_status_summary.dart';

abstract class PremiseStatusSummaryRepository {
  /// Defaults both bounds to today when omitted.
  Future<PremiseStatusSummary> getStatusSummary({DateTime? dateFrom, DateTime? dateTo});
}
