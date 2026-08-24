import 'package:ilms/features/billboard/data/datasources/billboard_search_remote_data_source.dart';
import 'package:ilms/features/billboard/data/models/billboard_search_models.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_search_filter.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_search_result.dart';
import 'package:ilms/features/billboard/domain/repositories/billboard_search_repository.dart';

class BillboardSearchRepositoryImpl implements BillboardSearchRepository {
  BillboardSearchRepositoryImpl(this._remote);

  final BillboardSearchRemoteDataSource _remote;

  @override
  Future<BillboardSearchResult> search({
    required BillboardSearchFilter filter,
    required int page,
    int perPage = 15,
  }) async {
    final result = await _remote.search(
      filter: BillboardSearchFilterDto.fromDomain(filter),
      page: page,
      perPage: perPage,
    );
    return result.toDomain();
  }
}
