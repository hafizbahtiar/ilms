import 'package:ilms/features/premise/data/datasources/local/premise_draft_local_data_source.dart';
import 'package:ilms/features/premise/data/mappers/premise_draft_mapper.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_draft_summary.dart';
import 'package:ilms/features/premise/domain/repositories/premise_draft_repository.dart';

class PremiseDraftRepositoryImpl implements PremiseDraftRepository {
  PremiseDraftRepositoryImpl(this._local);

  final PremiseDraftLocalDataSource _local;

  @override
  Stream<List<PremiseDraftSummary>> watchDrafts() => _local.watchDrafts();

  @override
  Stream<int> watchDraftCount() => _local.watchDraftCount();

  @override
  Stream<PremiseDraftSummary?> watchLatestDraft() => _local.watchLatestDraft();

  @override
  Future<PremiseDraftSummary?> getLatestDraft() => _local.getLatestDraft();

  @override
  Future<PremiseDraftLoadResult?> loadDraft(int localDraftId) async {
    final row = await _local.getDraftRow(localDraftId);
    if (row == null || !row.isActive || row.isSynced) return null;

    return PremiseDraftLoadResult(
      localDraftId: row.id,
      payload: PremiseDraftMapper.decodePayload(row.formPayload),
      visitNo: row.visitNo,
      draftType: PremiseDraftTypeStorage.fromStorage(row.draftType),
    );
  }

  @override
  Future<PremiseDraftLoadResult?> loadEditSession(String visitNo) async {
    final row = await _local.getEditSessionByVisitNo(visitNo);
    if (row == null) return null;

    return PremiseDraftLoadResult(
      localDraftId: row.id,
      payload: PremiseDraftMapper.decodePayload(row.formPayload),
      visitNo: row.visitNo,
      draftType: PremiseDraftTypeStorage.fromStorage(row.draftType),
    );
  }

  @override
  Stream<Set<String>> watchEditSessionVisitNos() => _local.watchEditSessionVisitNos();

  @override
  Stream<List<PremiseDraftSummary>> watchEditSessions() => _local.watchEditSessions();

  @override
  Stream<List<PremiseDraftSummary>> watchDraftsAndEditSessions() => _local.watchDraftsAndEditSessions();

  @override
  Future<int> saveDraft({
    int? localDraftId,
    required PremiseDraftPayloadModel payload,
    required String companyName,
    required String traderName,
    String? visitNo,
    bool isEditSession = false,
    PremiseDraftType draftType = PremiseDraftType.newEntry,
  }) {
    return _local.upsertDraft(
      localDraftId: localDraftId,
      companyName: companyName,
      traderName: traderName,
      formPayload: PremiseDraftMapper.encodePayload(payload),
      visitNo: visitNo,
      isEditSession: isEditSession,
      draftType: draftType,
    );
  }

  @override
  Future<void> deleteDraft(int localDraftId) => _local.deleteDraft(localDraftId);

  @override
  Future<void> markDraftSynced(int localDraftId) => _local.markSynced(localDraftId);

  @override
  Future<int> duplicateDraft(int sourceLocalDraftId) async {
    final row = await _local.getDraftRow(sourceLocalDraftId);
    if (row == null || !row.isActive || row.isSynced) {
      throw StateError('Draft $sourceLocalDraftId is not available to duplicate.');
    }

    final payload = PremiseDraftMapper.decodePayload(row.formPayload);

    return saveDraft(
      payload: payload,
      companyName: row.companyName,
      traderName: row.traderName,
      draftType: PremiseDraftType.duplicate,
    );
  }
}
