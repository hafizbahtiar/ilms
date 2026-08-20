import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/shared/lookups/data/datasources/mock_general_lookup_data_source.dart';
import 'package:ilms/shared/lookups/data/general_lookup_cache_keys.dart';
import 'package:ilms/shared/lookups/data/repositories/general_lookup_repository_impl.dart';
import 'package:ilms/shared/models/general_model.dart';

void main() {
  group('GeneralLookupRepositoryImpl cache', () {
    late AppDatabase database;
    late GeneralLookupRepositoryImpl repository;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      await AppDatabase.init(database: database);
      repository = GeneralLookupRepositoryImpl(const MockGeneralLookupDataSource(), database);
    });

    tearDown(() {
      AppDatabase.reset();
    });

    test('getStates reads from cache after first fetch', () async {
      final first = await repository.getStates();
      expect(first, isNotEmpty);

      final cachedRaw = await database.readKeyValue(GeneralLookupCacheKeys.states());
      expect(cachedRaw, isNotNull);

      final second = await repository.getStates();
      expect(second, first);
    });

    test('refreshStates replaces cached values', () async {
      await repository.getStates();
      final refreshed = await repository.refreshStates();
      expect(refreshed, isNotEmpty);

      final cached = await database.readKeyValue(GeneralLookupCacheKeys.states());
      expect(cached, isNotNull);
      expect(cached!.contains('"code"'), isTrue);
    });

    test('clearAllCaches removes lookup keys only', () async {
      await repository.getStates();
      await database.upsertKeyValue(key: 'other:key', value: 'keep');

      await repository.clearAllCaches();

      expect(await database.readKeyValue(GeneralLookupCacheKeys.states()), isNull);
      expect(await database.readKeyValue('other:key'), 'keep');
    });
  });

  group('GeneralLookupCacheCodec', () {
    test('roundtrips general models', () {
      const items = [GeneralModel(code: 'WP', desc: 'Kuala Lumpur')];
      final encoded = GeneralLookupCacheCodec.encode(items);
      final decoded = GeneralLookupCacheCodec.decode(encoded);
      expect(decoded.first.code, 'WP');
      expect(decoded.first.desc, 'Kuala Lumpur');
    });
  });
}
