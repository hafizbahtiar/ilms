import 'package:ilms/features/investigation/domain/entities/investigation_search_filter.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_search_result.dart';

/// Shared by both the search and history list pages — legacy has no
/// separate history endpoint.
abstract class InvestigationSearchRepository {
  Future<InvestigationSearchResult> search({required InvestigationSearchFilter filter, required int page});
}
