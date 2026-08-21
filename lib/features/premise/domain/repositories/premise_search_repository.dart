import 'package:ilms/features/premise/domain/entities/premise_search_filter.dart';
import 'package:ilms/features/premise/domain/entities/premise_search_result.dart';

abstract class PremiseSearchRepository {
  Future<PremiseSearchResult> search({
    required PremiseSearchFilter filter,
    required String dateFrom,
    required String dateTo,
    required int page,
    int perPage = 15,
  });
}
