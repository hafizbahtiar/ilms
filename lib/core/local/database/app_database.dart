import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/key_value_entries.dart';
import 'tables/premise_draft_entries.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [KeyValueEntries, PremiseDraftEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.executor);

  static AppDatabase? _instance;

  static AppDatabase get instance {
    final database = _instance;
    if (database == null) {
      throw StateError('AppDatabase.init() must be called before use.');
    }
    return database;
  }

  static Future<AppDatabase> init({AppDatabase? database}) async {
    return _instance = database ?? AppDatabase._(NativeDatabase(await _openDatabaseFile()));
  }

  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  static void reset() {
    _instance?.close();
    _instance = null;
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(premiseDraftEntries);
      }
    },
  );

  Future<void> upsertKeyValue({required String key, required String value}) {
    return into(keyValueEntries).insertOnConflictUpdate(
      KeyValueEntriesCompanion(key: Value(key), value: Value(value), updatedAt: Value(DateTime.now())),
    );
  }

  Future<String?> readKeyValue(String key) async {
    final row = await (select(keyValueEntries)..where((entry) => entry.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<int> deleteKeyValue(String key) {
    return (delete(keyValueEntries)..where((entry) => entry.key.equals(key))).go();
  }

  static Future<File> _openDatabaseFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'ilms_local.db'));
    return file;
  }
}
