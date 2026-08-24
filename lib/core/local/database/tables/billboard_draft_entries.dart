import 'package:drift/drift.dart';

/// Local billboard drafts — unsynced new entries and pending local unsaved
/// edits, mirroring `premise_draft_entries.dart`'s shape.
class BillboardDraftEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get mediaClientName => text().withDefault(const Constant(''))();

  TextColumn get description => text().withDefault(const Constant(''))();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  BoolColumn get isEditSession => boolean().withDefault(const Constant(false))();

  TextColumn get billboardNo => text().nullable()();

  /// JSON payload — form fields + toggles + gps + remark codes + faces + photos.
  TextColumn get formPayload => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
