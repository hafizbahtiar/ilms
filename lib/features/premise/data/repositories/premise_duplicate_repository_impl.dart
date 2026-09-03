import 'package:ilms/features/premise/data/datasources/premise_duplicate_remote_data_source.dart';
import 'package:ilms/features/premise/data/mappers/premise_draft_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_duplicate_models.dart';
import 'package:ilms/features/premise/domain/entities/premise_draft_summary.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_filter.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_result.dart';
import 'package:ilms/features/premise/domain/repositories/premise_draft_repository.dart';
import 'package:ilms/features/premise/domain/repositories/premise_duplicate_repository.dart';

class PremiseDuplicateRepositoryImpl implements PremiseDuplicateRepository {
  PremiseDuplicateRepositoryImpl(this._remote, this._draftRepository);

  final PremiseDuplicateRemoteDataSource _remote;
  final PremiseDraftRepository _draftRepository;

  @override
  void cancelSearch() => _remote.cancelSearch();

  @override
  Future<int> createDraftFromRecord(String visitNo) async {
    final check = await _remote.checkCanDuplicate(visitNo);
    if (!check.canDuplicate) {
      throw Exception(check.message ?? 'Premise status: Already Processed.');
    }

    final payload = await _remote.loadDetail(visitNo);
    return _draftRepository.saveDraft(
      // Strip the source premise's server ids — this draft becomes a NEW
      // premise record, not an edit of the one it was duplicated from.
      payload: PremiseDraftMapper.stripServerIdsForDuplicate(payload),
      companyName: PremiseDraftMapper.displayCompanyNameFromPayload(payload),
      traderName: PremiseDraftMapper.displayTraderNameFromPayload(payload),
      draftType: PremiseDraftType.duplicate,
    );
  }

  @override
  Future<PremiseDuplicateResult> searchPreviousPhase({
    required PremiseDuplicateFilter filter,
    required int page,
    int perPage = 15,
  }) async {
    final dto = await _remote.searchPreviousPhase(
      filter: PremiseDuplicateFilterDto.fromDomain(filter),
      page: page,
      perPage: perPage,
    );

    return PremiseDuplicateResult(
      items: [for (final item in dto.items) item.toDomain()],
      nextPage: dto.nextPage,
      hasNextPage: dto.hasNextPage,
    );
  }
}
