import 'package:ilms/features/premise/domain/entities/premise_duplicate_filter.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_result.dart';

/// Duplicate-from-previous-phase operations (`searchPrevPhase`, check, detail → draft).
abstract class PremiseDuplicateRepository {
  Future<PremiseDuplicateResult> searchPreviousPhase({
    required PremiseDuplicateFilter filter,
    required int page,
    int perPage = 15,
  });

  /// Validates eligibility, loads server detail, and saves a local draft row.
  Future<int> createDraftFromRecord(String visitNo);
}
