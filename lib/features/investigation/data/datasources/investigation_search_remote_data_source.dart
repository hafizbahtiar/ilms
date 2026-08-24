import 'package:ilms/features/investigation/data/models/investigation_search_models.dart';

abstract class InvestigationSearchRemoteDataSource {
  Future<InvestigationSearchResultDto> search({
    required InvestigationSearchFilterDto filter,
    required int page,
    int perPage = 15,
  });
}
