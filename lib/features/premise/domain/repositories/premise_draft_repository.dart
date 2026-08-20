import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_draft_summary.dart';

class PremiseDraftLoadResult {
  const PremiseDraftLoadResult({
    required this.localDraftId,
    required this.payload,
    this.visitNo,
  });

  final int localDraftId;
  final PremiseDraftPayloadModel payload;
  final String? visitNo;
}

abstract class PremiseDraftRepository {
  Stream<List<PremiseDraftSummary>> watchDrafts();

  Stream<int> watchDraftCount();

  Stream<PremiseDraftSummary?> watchLatestDraft();

  Future<PremiseDraftSummary?> getLatestDraft();

  Future<PremiseDraftLoadResult?> loadDraft(int localDraftId);

  Future<int> saveDraft({
    int? localDraftId,
    required PremiseDraftPayloadModel payload,
    required String companyName,
    required String traderName,
    String? visitNo,
  });

  Future<void> deleteDraft(int localDraftId);

  Future<void> markDraftSynced(int localDraftId);

  /// Copies an existing draft into a new unsynced draft row.
  Future<int> duplicateDraft(int sourceLocalDraftId);
}
