import 'package:ilms/features/billboard/data/datasources/billboard_status_summary_remote_data_source.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_status_summary.dart';
import 'package:ilms/features/billboard/domain/repositories/billboard_status_summary_repository.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';

class BillboardStatusSummaryRepositoryImpl implements BillboardStatusSummaryRepository {
  BillboardStatusSummaryRepositoryImpl(this._remote);

  final BillboardStatusSummaryRemoteDataSource _remote;

  @override
  Future<BillboardStatusSummary> getStatusSummary({DateTime? dateFrom, DateTime? dateTo}) {
    final today = DateTime.now();
    return _remote.getStatusSummary(dateFrom: formatIsoDate(dateFrom ?? today), dateTo: formatIsoDate(dateTo ?? today));
  }
}
