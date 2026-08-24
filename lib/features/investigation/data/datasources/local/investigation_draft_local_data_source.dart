import 'package:drift/drift.dart';
import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_draft_summary.dart';

class InvestigationDraftLocalDataSource {
  InvestigationDraftLocalDataSource(this._db);

  final AppDatabase _db;

  Stream<List<InvestigationDraftSummary>> watchDrafts() {
    final query = _db.select(_db.investigationDraftEntries)..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map((rows) => rows.map(_toSummary).toList());
  }

  Stream<bool> watchHasDraft(String investigationNo) {
    final query = _db.select(_db.investigationDraftEntries)
      ..where((row) => row.investigationNo.equals(investigationNo));
    return query.watchSingleOrNull().map((row) => row != null);
  }

  Future<InvestigationDraftEntry?> getDraftRow(String investigationNo) {
    return (_db.select(
      _db.investigationDraftEntries,
    )..where((row) => row.investigationNo.equals(investigationNo))).getSingleOrNull();
  }

  Future<void> upsertDraft({
    required String investigationNo,
    required String applicantName,
    required String formPayload,
  }) async {
    final now = DateTime.now();
    await _db
        .into(_db.investigationDraftEntries)
        .insertOnConflictUpdate(
          InvestigationDraftEntriesCompanion.insert(
            investigationNo: investigationNo,
            applicantName: Value(applicantName),
            formPayload: formPayload,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> deleteDraft(String investigationNo) async {
    await (_db.delete(_db.investigationDraftEntries)..where((row) => row.investigationNo.equals(investigationNo))).go();
  }

  InvestigationDraftSummary _toSummary(InvestigationDraftEntry row) {
    return InvestigationDraftSummary(
      investigationNo: row.investigationNo,
      applicantName: row.applicantName,
      updatedAt: row.updatedAt,
    );
  }
}
