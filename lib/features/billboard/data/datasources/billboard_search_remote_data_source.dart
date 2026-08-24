import 'package:ilms/features/billboard/data/models/billboard_search_models.dart';

abstract class BillboardSearchRemoteDataSource {
  Future<BillboardSearchResultDto> search({
    required BillboardSearchFilterDto filter,
    required int page,
    int perPage = 15,
  });
}
