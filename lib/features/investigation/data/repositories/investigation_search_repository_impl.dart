import 'package:ilms/features/investigation/data/datasources/investigation_search_remote_data_source.dart';
import 'package:ilms/features/investigation/data/models/investigation_search_models.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_search_filter.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_search_result.dart';
import 'package:ilms/features/investigation/domain/repositories/investigation_search_repository.dart';

class InvestigationSearchRepositoryImpl implements InvestigationSearchRepository {
  InvestigationSearchRepositoryImpl(this._remote);

  final InvestigationSearchRemoteDataSource _remote;

  @override
  Future<InvestigationSearchResult> search({required InvestigationSearchFilter filter, required int page}) async {
    final result = await _remote.search(filter: InvestigationSearchFilterDto.fromDomain(filter), page: page);
    return result.toDomain();
  }
}
