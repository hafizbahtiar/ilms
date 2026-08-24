import 'package:ilms/features/billboard/domain/entities/billboard_status_summary.dart';

/// Low-level status-summary API access. Maps 1:1 to the network endpoint —
/// not used by UI directly.
abstract class BillboardStatusSummaryRemoteDataSource {
  Future<BillboardStatusSummary> getStatusSummary({required String dateFrom, required String dateTo});
}
