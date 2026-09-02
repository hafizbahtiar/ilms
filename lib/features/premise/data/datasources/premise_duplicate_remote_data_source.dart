import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/data/models/premise_duplicate_models.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_check.dart';

/// Low-level duplicate API access. Maps 1:1 to network endpoints — not used by UI directly.
abstract class PremiseDuplicateRemoteDataSource {
  void cancelSearch();

  Future<PremiseDuplicateResultDto> searchPreviousPhase({
    required PremiseDuplicateFilterDto filter,
    required int page,
    int perPage = 15,
  });

  Future<PremiseDuplicateCheck> checkCanDuplicate(String visitNo);

  Future<PremiseDraftPayloadModel> loadDetail(String visitNo);
}
