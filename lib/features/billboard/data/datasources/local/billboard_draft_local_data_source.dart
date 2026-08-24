import 'package:drift/drift.dart';
import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_draft_summary.dart';

class BillboardDraftLocalDataSource {
  BillboardDraftLocalDataSource(this._db);

  final AppDatabase _db;

  Stream<List<BillboardDraftSummary>> watchDrafts() {
    final query = _db.select(_db.billboardDraftEntries)
      ..where((row) => row.isActive.equals(true) & row.isSynced.equals(false) & row.isEditSession.equals(false))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map((rows) => rows.map(_toSummary).toList());
  }

  Stream<int> watchDraftCount() => watchDrafts().map((items) => items.length);

  Stream<BillboardDraftSummary?> watchLatestDraft() {
    return watchDrafts().map((items) => items.isEmpty ? null : items.first);
  }

  Future<BillboardDraftEntry?> getDraftRow(int id) {
    return (_db.select(_db.billboardDraftEntries)..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<BillboardDraftEntry?> getEditSessionByBillboardNo(String billboardNo) {
    return (_db.select(_db.billboardDraftEntries)..where(
          (row) =>
              row.billboardNo.equals(billboardNo) &
              row.isActive.equals(true) &
              row.isSynced.equals(false) &
              row.isEditSession.equals(true),
        ))
        .getSingleOrNull();
  }

  Stream<Set<String>> watchEditSessionBillboardNos() {
    final query = _db.select(_db.billboardDraftEntries)
      ..where((row) => row.isActive.equals(true) & row.isSynced.equals(false) & row.isEditSession.equals(true));

    return query.watch().map((rows) => rows.map((row) => row.billboardNo).whereType<String>().toSet());
  }

  Stream<List<BillboardDraftSummary>> watchEditSessions() {
    final query = _db.select(_db.billboardDraftEntries)
      ..where((row) => row.isActive.equals(true) & row.isSynced.equals(false) & row.isEditSession.equals(true))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map((rows) => rows.map(_toSummary).toList());
  }

  Stream<List<BillboardDraftSummary>> watchDraftsAndEditSessions() {
    final query = _db.select(_db.billboardDraftEntries)
      ..where((row) => row.isActive.equals(true) & row.isSynced.equals(false))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map((rows) => rows.map(_toSummary).toList());
  }

  Future<int> upsertDraft({
    int? localDraftId,
    required String mediaClientName,
    required String description,
    required String formPayload,
    String? billboardNo,
    bool isEditSession = false,
  }) async {
    final now = DateTime.now();

    if (localDraftId != null) {
      await (_db.update(_db.billboardDraftEntries)..where((row) => row.id.equals(localDraftId))).write(
        BillboardDraftEntriesCompanion(
          mediaClientName: Value(mediaClientName),
          description: Value(description),
          formPayload: Value(formPayload),
          billboardNo: Value(billboardNo),
          updatedAt: Value(now),
        ),
      );
      return localDraftId;
    }

    return _db
        .into(_db.billboardDraftEntries)
        .insert(
          BillboardDraftEntriesCompanion.insert(
            mediaClientName: Value(mediaClientName),
            description: Value(description),
            formPayload: formPayload,
            billboardNo: Value(billboardNo),
            isEditSession: Value(isEditSession),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> deleteDraft(int localDraftId) async {
    await (_db.delete(_db.billboardDraftEntries)..where((row) => row.id.equals(localDraftId))).go();
  }

  BillboardDraftSummary _toSummary(BillboardDraftEntry row) {
    return BillboardDraftSummary(
      id: row.id,
      mediaClientName: row.mediaClientName,
      description: row.description,
      updatedAt: row.updatedAt,
      isEditSession: row.isEditSession,
      billboardNo: row.billboardNo,
    );
  }
}
