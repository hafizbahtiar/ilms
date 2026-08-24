import 'package:ilms/features/billboard/domain/entities/billboard_search_filter.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_search_result.dart';

abstract class BillboardSearchRepository {
  Future<BillboardSearchResult> search({required BillboardSearchFilter filter, required int page, int perPage = 15});
}
