import 'package:ilms/features/premise/data/models/premise_search_models.dart';

abstract class PremiseSearchRemoteDataSource {
  Future<PremiseSearchResultDto> search({
    required PremiseSearchFilterDto filter,
    required String dateFrom,
    required String dateTo,
    required int page,
    int perPage = 15,
  });
}
