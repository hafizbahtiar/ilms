import 'package:drift/drift.dart';
import 'package:ilms/core/local/database/app_database.dart';

class CrashLogLocalStore {
  CrashLogLocalStore(this._database);

  final AppDatabase _database;

  Future<int> insert({required String payload}) {
    return _database.into(_database.crashLogEntries).insert(CrashLogEntriesCompanion.insert(payload: payload));
  }

  Future<List<CrashLogEntry>> getPending() {
    return (_database.select(_database.crashLogEntries)
          ..where((tbl) => tbl.status.equals('pending'))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt)]))
        .get();
  }

  Future<int> delete(int id) {
    return (_database.delete(_database.crashLogEntries)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> incrementRetry(int id, {String? errorMessage}) async {
    final row = await (_database.select(_database.crashLogEntries)..where((tbl) => tbl.id.equals(id))).getSingle();
    await (_database.update(_database.crashLogEntries)..where((tbl) => tbl.id.equals(id))).write(
      CrashLogEntriesCompanion(
        retryCount: Value(row.retryCount + 1),
        errorMessage: errorMessage != null ? Value(errorMessage) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
