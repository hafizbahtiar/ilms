import 'package:ilms/features/investigation/data/datasources/local/investigation_draft_local_data_source.dart';
import 'package:ilms/features/investigation/data/mappers/investigation_draft_mapper.dart';
import 'package:ilms/features/investigation/data/models/investigation_draft_payload_model.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_draft_summary.dart';
import 'package:ilms/features/investigation/domain/repositories/investigation_draft_repository.dart';

class InvestigationDraftRepositoryImpl implements InvestigationDraftRepository {
  InvestigationDraftRepositoryImpl(this._local);

  final InvestigationDraftLocalDataSource _local;

  @override
  Stream<List<InvestigationDraftSummary>> watchDrafts() => _local.watchDrafts();

  @override
  Stream<bool> watchHasDraft(String investigationNo) => _local.watchHasDraft(investigationNo);

  @override
  Future<InvestigationDetails?> getDraft(String investigationNo) async {
    final row = await _local.getDraftRow(investigationNo);
    if (row == null) return null;
    final payload = InvestigationDraftPayloadModel.decode(row.formPayload);
    return InvestigationDraftMapper.toDomain(payload);
  }

  @override
  Future<void> saveDraft(InvestigationDetails details) {
    final payload = InvestigationDraftMapper.toPayload(details);
    return _local.upsertDraft(
      investigationNo: details.investigationNo,
      applicantName: details.applicant.applicantName ?? '',
      formPayload: payload.encode(),
    );
  }

  @override
  Future<void> discardDraft(String investigationNo) => _local.deleteDraft(investigationNo);
}
