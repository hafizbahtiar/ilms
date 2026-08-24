import 'package:ilms/features/billboard/data/models/billboard_status_summary_model.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_status_summary.dart';

/// Maps `/api/billboardCensus/typeSummary` payload into a domain entity.
class BillboardStatusSummaryMapper {
  BillboardStatusSummaryMapper._();

  static BillboardStatusSummary fromModel(BillboardStatusSummaryModel model) {
    return BillboardStatusSummary(
      dateFrom: model.dateFrom,
      dateTo: model.dateTo,
      total: model.total,
      types: model.types.map((item) => BillboardTypeCount(type: item.type, value: item.value)).toList(),
    );
  }
}
