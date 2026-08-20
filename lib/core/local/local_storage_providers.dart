import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/core/local/files/internal_storage_manager.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:ilms/core/local/secure/secure_token_store.dart';
import 'package:ilms/features/auth/data/local/auth_session_store.dart';
import 'package:ilms/features/auth/data/local/secure_auth_session_store.dart';

final secureTokenStoreProvider = Provider<SecureTokenStore>((ref) {
  return const FlutterSecureTokenStore();
});

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return AppPreferences.instance;
});

final authSessionStoreProvider = Provider<AuthSessionStore>((ref) {
  return SecureAuthSessionStore(
    secureTokenStore: ref.watch(secureTokenStoreProvider),
    preferences: ref.watch(appPreferencesProvider),
  );
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final internalStorageManagerProvider = Provider<InternalStorageManager>((ref) {
  return InternalStorageManager.instance;
});
