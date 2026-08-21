import 'package:drift/drift.dart';

/// Local premise census drafts (unsynced new entries — excludes edit sessions for now).
class PremiseDraftEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get companyName => text().withDefault(const Constant(''))();

  TextColumn get traderName => text().withDefault(const Constant(''))();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  BoolColumn get isEditSession => boolean().withDefault(const Constant(false))();

  TextColumn get visitNo => text().nullable()();

  /// [PremiseDraftType] name — how this draft came to be (new entry, vacant,
  /// or a duplicate of an existing record/draft).
  TextColumn get draftType => text().withDefault(const Constant('newEntry'))();

  /// JSON payload — form fields + census images metadata.
  TextColumn get formPayload => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
