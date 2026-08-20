import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/core/local/files/internal_storage_manager.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:ilms/core/local/secure/secure_token_store.dart';
import 'package:ilms/features/auth/data/local/secure_auth_session_store.dart';
import 'package:ilms/features/auth/data/models/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureAuthSessionStore', () {
    late InMemorySecureTokenStore secureTokenStore;
    late AppPreferences preferences;
    late SecureAuthSessionStore sessionStore;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      AppPreferences.reset();
      secureTokenStore = InMemorySecureTokenStore();
      preferences = await AppPreferences.init();
      sessionStore = SecureAuthSessionStore(secureTokenStore: secureTokenStore, preferences: preferences);
    });

    tearDown(() {
      AppPreferences.reset();
    });

    test('save and readSession restore full auth session', () async {
      final data = LoginDataModel(
        accessToken: 'token-123',
        tokenType: 'Bearer',
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        name: 'Admin User',
        email: 'admin@ilms.com',
        roles: const ['admin'],
        permissions: const ['view-mobile-premise'],
      );

      await sessionStore.save(data);
      final restored = await sessionStore.readSession();

      expect(restored?.accessToken, 'token-123');
      expect(restored?.name, 'Admin User');
      expect(restored?.roles, ['admin']);
      expect(restored?.permissions, ['view-mobile-premise']);
    });

    test('restorableAccessToken returns null after clear', () async {
      await sessionStore.save(
        LoginDataModel(accessToken: 'token-123', expiresAt: DateTime.now().add(const Duration(hours: 2))),
      );

      await sessionStore.clear();

      expect(await sessionStore.restorableAccessToken(), isNull);
      expect(await sessionStore.readSession(), isNull);
    });
  });

  group('AppDatabase', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      await AppDatabase.init(database: database);
    });

    tearDown(() {
      AppDatabase.reset();
    });

    test('upsert and read key value entries', () async {
      await database.upsertKeyValue(key: 'feature_flag', value: 'enabled');
      expect(await database.readKeyValue('feature_flag'), 'enabled');
    });
  });

  group('InternalStorageManager', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ilms_storage_test');
      InternalStorageManager.setTestRoot(tempDir);
    });

    tearDown(() async {
      InternalStorageManager.resetTestRoot();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('saveFile and getFile round trip text content', () async {
      final manager = InternalStorageManager.instance;

      final saved = await manager.saveFile(fileData: 'hello', fileName: 'note.txt', subFolder: 'logs');
      final loaded = await manager.getFile('note.txt', subFolder: 'logs');

      expect(saved, isNotNull);
      expect(loaded, isNotNull);
      expect(await loaded!.readAsString(), 'hello');
      await manager.deleteFolder('logs');
    });
  });
}
