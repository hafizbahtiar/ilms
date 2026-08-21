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

  /// The active, unsynced edit-session row for [visitNo] — the local
  /// unsaved edit of an existing premise record, if one is pending.
  Future<PremiseDraftEntry?> getEditSessionByVisitNo(String visitNo) {
    return (_db.select(_db.premiseDraftEntries)..where(
          (row) =>
              row.visitNo.equals(visitNo) &
              row.isActive.equals(true) &
              row.isSynced.equals(false) &
              row.isEditSession.equals(true),
        ))
        .getSingleOrNull();
  }

  /// visitNo of every premise record with a pending local unsaved edit —
  /// used to show an "Unsaved" tag on list tiles.
  Stream<Set<String>> watchEditSessionVisitNos() {
    final query = _db.select(_db.premiseDraftEntries)
      ..where((row) => row.isActive.equals(true) & row.isSynced.equals(false) & row.isEditSession.equals(true));

    return query.watch().map((rows) => rows.map((row) => row.visitNo).whereType<String>().toSet());
  }

  /// Every pending local unsaved edit (edit-session rows only).
  Stream<List<PremiseDraftSummary>> watchEditSessions() {
    final query = _db.select(_db.premiseDraftEntries)
      ..where((row) => row.isActive.equals(true) & row.isSynced.equals(false) & row.isEditSession.equals(true))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map((rows) => rows.map(_toSummary).toList());
  }

  /// New-entry drafts AND pending local unsaved edits together, newest
  /// first — [PremiseDraftSummary.isEditSession] distinguishes the two.
  Stream<List<PremiseDraftSummary>> watchDraftsAndEditSessions() {
    final query = _db.select(_db.premiseDraftEntries)
      ..where((row) => row.isActive.equals(true) & row.isSynced.equals(false))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);

    return query.watch().map((rows) => rows.map(_toSummary).toList());
  }

  Future<int> upsertDraft({
    int? localDraftId,
    required String companyName,
    required String traderName,
    required String formPayload,
    String? visitNo,
    bool isEditSession = false,
    PremiseDraftType draftType = PremiseDraftType.newEntry,
  }) async {
    final now = DateTime.now();

    if (localDraftId != null) {
      await (_db.update(_db.premiseDraftEntries)..where((row) => row.id.equals(localDraftId))).write(
        PremiseDraftEntriesCompanion(
          companyName: Value(companyName),
          traderName: Value(traderName),
          formPayload: Value(formPayload),
          visitNo: Value(visitNo),
          draftType: Value(draftType.name),
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
            draftType: Value(draftType.name),
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
      visitNo: row.visitNo,
      draftType: PremiseDraftTypeStorage.fromStorage(row.draftType),
    );
  }
}
