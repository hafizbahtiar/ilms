import 'package:ilms/features/premise/data/models/premise_status_summary_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_status_summary.dart';

/// Maps `/api/premiseCensus/statusSummary` payload into a domain entity.
class PremiseStatusSummaryMapper {
  PremiseStatusSummaryMapper._();

  static PremiseStatusSummary fromModel(PremiseStatusSummaryModel model) {
    return PremiseStatusSummary(
      dateFrom: model.dateFrom,
      dateTo: model.dateTo,
      total: model.total,
      visitStatus: model.visitStatus
          .map((item) => PremiseVisitStatusCount(status: item.status, value: item.value))
          .toList(),
    );
  }
}
