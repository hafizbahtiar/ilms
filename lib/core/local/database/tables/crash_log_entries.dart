import 'package:drift/drift.dart';

/// Offline queue for crash / error logs that failed to reach the backend.
class CrashLogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get payload => text()();

  TextColumn get status => text().withDefault(const Constant('pending'))();

  TextColumn get errorMessage => text().nullable()();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
