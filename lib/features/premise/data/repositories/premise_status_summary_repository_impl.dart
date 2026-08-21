import 'package:ilms/features/premise/data/datasources/premise_status_summary_remote_data_source.dart';
import 'package:ilms/features/premise/domain/entities/premise_status_summary.dart';
import 'package:ilms/features/premise/domain/repositories/premise_status_summary_repository.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';

class PremiseStatusSummaryRepositoryImpl implements PremiseStatusSummaryRepository {
  PremiseStatusSummaryRepositoryImpl(this._remote);

  final PremiseStatusSummaryRemoteDataSource _remote;

  @override
  Future<PremiseStatusSummary> getStatusSummary({DateTime? dateFrom, DateTime? dateTo}) {
    final today = DateTime.now();
    return _remote.getStatusSummary(
      dateFrom: formatIsoDate(dateFrom ?? today),
      dateTo: formatIsoDate(dateTo ?? today),
    );
  }
}
