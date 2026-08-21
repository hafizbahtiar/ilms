import 'package:ilms/features/premise/domain/entities/premise_status_summary.dart';

/// Low-level status-summary API access. Maps 1:1 to the network endpoint —
/// not used by UI directly.
abstract class PremiseStatusSummaryRemoteDataSource {
  Future<PremiseStatusSummary> getStatusSummary({required String dateFrom, required String dateTo});
}
