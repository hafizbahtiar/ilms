import 'package:drift/drift.dart';

/// Local investigation edit-session drafts — "Save & Exit" while editing an
/// existing investigation. Unlike premise, there is no new-entry draft type
/// (every investigation already exists on the server), so one row per
/// investigation_no is enough.
class InvestigationDraftEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get investigationNo => text().unique()();

  TextColumn get applicantName => text().withDefault(const Constant(''))();

  /// JSON payload — full form fields incl. pending photo bytes.
  TextColumn get formPayload => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
