import 'package:drift/drift.dart';
import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/features/premise/domain/entities/premise_draft_summary.dart';

class PremiseDraftLocalDataSource {
  PremiseDraftLocalDataSource(this._db);

  final AppDatabase _db;

  Stream<List<PremiseDraftSummary>> watchDrafts() {
    final query = _db.select(_db.premiseDraftEntries)
      ..where((row) => row.isActive.equals(true) & row.isSynced.equals(false) & row.isEditSession.equals(false))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map((rows) => rows.map(_toSummary).toList());
  }

  Stream<int> watchDraftCount() => watchDrafts().map((items) => items.length);

  Stream<PremiseDraftSummary?> watchLatestDraft() {
    return watchDrafts().map((items) => items.isEmpty ? null : items.first);
  }

  Future<PremiseDraftSummary?> getLatestDraft() async {
    final rows =
        await (_db.select(_db.premiseDraftEntries)
              ..where((row) => row.isActive.equals(true) & row.isSynced.equals(false) & row.isEditSession.equals(false))
              ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])
              ..limit(1))
            .get();
    if (rows.isEmpty) return null;
    return _toSummary(rows.first);
  }

  Future<PremiseDraftEntry?> getDraftRow(int id) {
    return (_db.select(_db.premiseDraftEntries)..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<int> upsertDraft({
    int? localDraftId,
    required String companyName,
    required String traderName,
    required String formPayload,
    String? visitNo,
    bool isEditSession = false,
  }) async {
    final now = DateTime.now();

    if (localDraftId != null) {
      await (_db.update(_db.premiseDraftEntries)..where((row) => row.id.equals(localDraftId))).write(
        PremiseDraftEntriesCompanion(
          companyName: Value(companyName),
          traderName: Value(traderName),
          formPayload: Value(formPayload),
          visitNo: Value(visitNo),
          updatedAt: Value(now),
        ),
      );
      return localDraftId;
    }

    return _db
        .into(_db.premiseDraftEntries)
        .insert(
          PremiseDraftEntriesCompanion.insert(
            companyName: Value(companyName),
            traderName: Value(traderName),
            formPayload: formPayload,
            visitNo: Value(visitNo),
            isEditSession: Value(isEditSession),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> deleteDraft(int localDraftId) async {
    await (_db.delete(_db.premiseDraftEntries)..where((row) => row.id.equals(localDraftId))).go();
  }

  Future<void> markSynced(int localDraftId) async {
    await (_db.update(_db.premiseDraftEntries)..where((row) => row.id.equals(localDraftId))).write(
      PremiseDraftEntriesCompanion(isSynced: const Value(true), updatedAt: Value(DateTime.now())),
    );
  }

  PremiseDraftSummary _toSummary(PremiseDraftEntry row) {
    return PremiseDraftSummary(
      id: row.id,
      companyName: row.companyName,
      traderName: row.traderName,
      updatedAt: row.updatedAt,
      isEditSession: row.isEditSession,
    );
  }
}
