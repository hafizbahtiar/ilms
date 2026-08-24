import 'package:ilms/features/billboard/data/datasources/local/billboard_draft_local_data_source.dart';
import 'package:ilms/features/billboard/data/mappers/billboard_draft_mapper.dart';
import 'package:ilms/features/billboard/data/models/billboard_draft_payload_model.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_draft_summary.dart';
import 'package:ilms/features/billboard/domain/repositories/billboard_draft_repository.dart';

class BillboardDraftRepositoryImpl implements BillboardDraftRepository {
  BillboardDraftRepositoryImpl(this._local);

  final BillboardDraftLocalDataSource _local;

  @override
  Stream<List<BillboardDraftSummary>> watchDrafts() => _local.watchDrafts();

  @override
  Stream<int> watchDraftCount() => _local.watchDraftCount();

  @override
  Stream<BillboardDraftSummary?> watchLatestDraft() => _local.watchLatestDraft();

  @override
  Future<BillboardDraftLoadResult?> loadDraft(int localDraftId) async {
    final row = await _local.getDraftRow(localDraftId);
    if (row == null || !row.isActive || row.isSynced) return null;

    return BillboardDraftLoadResult(
      localDraftId: row.id,
      payload: BillboardDraftMapper.decodePayload(row.formPayload),
      billboardNo: row.billboardNo,
    );
  }

  @override
  Future<BillboardDraftLoadResult?> loadEditSession(String billboardNo) async {
    final row = await _local.getEditSessionByBillboardNo(billboardNo);
    if (row == null) return null;

    return BillboardDraftLoadResult(
      localDraftId: row.id,
      payload: BillboardDraftMapper.decodePayload(row.formPayload),
      billboardNo: row.billboardNo,
    );
  }

  @override
  Stream<Set<String>> watchEditSessionBillboardNos() => _local.watchEditSessionBillboardNos();

  @override
  Stream<List<BillboardDraftSummary>> watchEditSessions() => _local.watchEditSessions();

  @override
  Stream<List<BillboardDraftSummary>> watchDraftsAndEditSessions() => _local.watchDraftsAndEditSessions();

  @override
  Future<int> saveDraft({
    int? localDraftId,
    required BillboardDraftPayloadModel payload,
    required String mediaClientName,
    required String description,
    String? billboardNo,
    bool isEditSession = false,
  }) {
    return _local.upsertDraft(
      localDraftId: localDraftId,
      mediaClientName: mediaClientName,
      description: description,
      formPayload: BillboardDraftMapper.encodePayload(payload),
      billboardNo: billboardNo,
      isEditSession: isEditSession,
    );
  }

  @override
  Future<void> deleteDraft(int localDraftId) => _local.deleteDraft(localDraftId);
}
