import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_draft_summary.dart';

/// Local edit-session drafts — Save & Exit while editing an investigation.
/// One row per `(ownerUserId, investigationNo)`.
abstract class InvestigationDraftRepository {
  Stream<List<InvestigationDraftSummary>> watchDrafts();

  Stream<bool> watchHasDraft(String investigationNo);

  Future<InvestigationDetails?> getDraft(String investigationNo);

  Future<void> saveDraft(InvestigationDetails details);

  Future<void> discardDraft(String investigationNo);
}
