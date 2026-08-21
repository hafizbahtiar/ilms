import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_draft_summary.dart';

class PremiseDraftLoadResult {
  const PremiseDraftLoadResult({
    required this.localDraftId,
    required this.payload,
    this.visitNo,
    this.draftType = PremiseDraftType.newEntry,
  });

  final int localDraftId;
  final PremiseDraftPayloadModel payload;
  final String? visitNo;
  final PremiseDraftType draftType;
}

abstract class PremiseDraftRepository {
  Stream<List<PremiseDraftSummary>> watchDrafts();

  Stream<int> watchDraftCount();

  Stream<PremiseDraftSummary?> watchLatestDraft();

  Future<PremiseDraftSummary?> getLatestDraft();

  Future<PremiseDraftLoadResult?> loadDraft(int localDraftId);

  /// The pending local unsaved edit for [visitNo], if one exists — lets a
  /// resumed session restore locally-saved changes instead of silently
  /// re-fetching a fresh (and stale) copy from the server.
  Future<PremiseDraftLoadResult?> loadEditSession(String visitNo);

  /// visitNo of every premise record with a pending local unsaved edit.
  Stream<Set<String>> watchEditSessionVisitNos();

  /// Every pending local unsaved edit (edit-session rows only).
  Stream<List<PremiseDraftSummary>> watchEditSessions();

  /// New-entry drafts AND pending local unsaved edits together —
  /// [PremiseDraftSummary.isEditSession] distinguishes the two.
  Stream<List<PremiseDraftSummary>> watchDraftsAndEditSessions();

  /// [isEditSession] marks this as local edits to an existing, already
  /// synced premise record (opened via view → Edit) rather than an
  /// unfinished new entry — kept out of the Drafts list (see
  /// [watchDrafts]), which lists only resumable new-entry drafts.
  Future<int> saveDraft({
    int? localDraftId,
    required PremiseDraftPayloadModel payload,
    required String companyName,
    required String traderName,
    String? visitNo,
    bool isEditSession = false,
    PremiseDraftType draftType = PremiseDraftType.newEntry,
  });

  Future<void> deleteDraft(int localDraftId);

  Future<void> markDraftSynced(int localDraftId);

  /// Copies an existing draft into a new unsynced draft row.
  Future<int> duplicateDraft(int sourceLocalDraftId);
}
