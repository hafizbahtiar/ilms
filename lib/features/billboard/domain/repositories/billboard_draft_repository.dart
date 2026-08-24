import 'package:ilms/features/billboard/data/models/billboard_draft_payload_model.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_draft_summary.dart';

class BillboardDraftLoadResult {
  const BillboardDraftLoadResult({required this.localDraftId, required this.payload, this.billboardNo});

  final int localDraftId;
  final BillboardDraftPayloadModel payload;
  final String? billboardNo;
}

/// Local billboard drafts — new-entry (Save & Exit while creating) and
/// edit-session (Save & Exit while editing an existing record), mirroring
/// premise's draft repository shape.
abstract class BillboardDraftRepository {
  Stream<List<BillboardDraftSummary>> watchDrafts();

  Stream<int> watchDraftCount();

  Stream<BillboardDraftSummary?> watchLatestDraft();

  Future<BillboardDraftLoadResult?> loadDraft(int localDraftId);

  Future<BillboardDraftLoadResult?> loadEditSession(String billboardNo);

  /// billboardNo of every billboard record with a pending local unsaved edit
  /// — used to show an "Unsaved" tag on list tiles.
  Stream<Set<String>> watchEditSessionBillboardNos();

  Stream<List<BillboardDraftSummary>> watchEditSessions();

  Stream<List<BillboardDraftSummary>> watchDraftsAndEditSessions();

  Future<int> saveDraft({
    int? localDraftId,
    required BillboardDraftPayloadModel payload,
    required String mediaClientName,
    required String description,
    String? billboardNo,
    bool isEditSession = false,
  });

  Future<void> deleteDraft(int localDraftId);
}
