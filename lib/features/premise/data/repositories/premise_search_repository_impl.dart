import 'package:ilms/features/premise/data/datasources/premise_search_remote_data_source.dart';
import 'package:ilms/features/premise/data/models/premise_search_models.dart';
import 'package:ilms/features/premise/domain/entities/premise_search_filter.dart';
import 'package:ilms/features/premise/domain/entities/premise_search_result.dart';
import 'package:ilms/features/premise/domain/repositories/premise_search_repository.dart';

class PremiseSearchRepositoryImpl implements PremiseSearchRepository {
  PremiseSearchRepositoryImpl(this._remote);

  final PremiseSearchRemoteDataSource _remote;

  @override
  Future<PremiseSearchResult> search({
    required PremiseSearchFilter filter,
    required String dateFrom,
    required String dateTo,
    required int page,
    int perPage = 15,
  }) async {
    final result = await _remote.search(
      filter: PremiseSearchFilterDto.fromDomain(filter),
      dateFrom: dateFrom,
      dateTo: dateTo,
      page: page,
      perPage: perPage,
    );
    return result.toDomain();
  }
}
