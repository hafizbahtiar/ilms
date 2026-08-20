import 'dart:convert';

import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:ilms/core/local/secure/secure_token_store.dart';
import 'package:ilms/features/auth/data/local/auth_session_resolver.dart';
import 'package:ilms/features/auth/data/local/auth_session_store.dart';
import 'package:ilms/features/auth/data/models/login_response_model.dart';

class SecureAuthSessionStore implements AuthSessionStore {
  SecureAuthSessionStore({this._secureTokenStore = const FlutterSecureTokenStore(), this._preferences});

  static const _accessTokenKey = 'access_token';
  static const _expiresAtKey = 'expires_at';
  static const _sessionKey = 'auth_session';

  final SecureTokenStore _secureTokenStore;
  final AppPreferences? _preferences;

  AppPreferences get _prefs {
    final preferences = _preferences;
    if (preferences != null) return preferences;
    return AppPreferences.instance;
  }

  @override
  Future<void> save(LoginDataModel data, {String? existingAccessToken}) async {
    final accessToken = data.accessToken ?? existingAccessToken;
    final expiresAt = data.expiresAt;

    if (accessToken != null && accessToken.isNotEmpty) {
      await _safeSecure(() => _secureTokenStore.write(_accessTokenKey, accessToken));
    }
    if (expiresAt != null) {
      await _safeSecure(() => _secureTokenStore.write(_expiresAtKey, expiresAt.toIso8601String()));
    }

    await _prefs.setString(_sessionKey, jsonEncode(data.toSessionJson()));
  }

  @override
  Future<LoginDataModel?> readSession() async {
    final raw = _prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;

    final sessionJson = jsonDecode(raw) as Map<String, dynamic>;
    final secureAccessToken = await _safeSecure(() => _secureTokenStore.read(_accessTokenKey));
    final secureExpiresAt = await _safeSecure(() => _secureTokenStore.read(_expiresAtKey));

    final resolved = AuthSessionResolver.resolve(
      sessionJson: sessionJson,
      secureAccessToken: secureAccessToken,
      secureExpiresAt: secureExpiresAt,
    );

    if (resolved.needsMigration) {
      if (resolved.migratedAccessToken != null) {
        await _safeSecure(() => _secureTokenStore.write(_accessTokenKey, resolved.migratedAccessToken!));
      }
      if (resolved.migratedExpiresAt != null) {
        await _safeSecure(() => _secureTokenStore.write(_expiresAtKey, resolved.migratedExpiresAt!));
      }
    }

    if (resolved.needsSessionStrip) {
      await _prefs.setString(_sessionKey, jsonEncode(resolved.strippedSessionJson));
    }

    return resolved.model;
  }

  @override
  Future<String?> restorableAccessToken() async {
    final session = await readSession();
    return AuthSessionResolver.sessionTokenToRestore(session, DateTime.now());
  }

  @override
  Future<void> clear() async {
    await _safeSecure(() => _secureTokenStore.delete(_accessTokenKey));
    await _safeSecure(() => _secureTokenStore.delete(_expiresAtKey));
    await _prefs.remove(_sessionKey);
  }

  Future<T?> _safeSecure<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }
}

class InMemoryAuthSessionStore implements AuthSessionStore {
  LoginDataModel? _session;

  @override
  Future<void> save(LoginDataModel data, {String? existingAccessToken}) async {
    _session = LoginDataModel(
      accessToken: data.accessToken ?? existingAccessToken,
      tokenType: data.tokenType,
      expiresAt: data.expiresAt,
      name: data.name,
      email: data.email,
      roles: data.roles,
      permissions: data.permissions,
    );
  }

  @override
  Future<LoginDataModel?> readSession() async => _session;

  @override
  Future<String?> restorableAccessToken() async {
    return AuthSessionResolver.sessionTokenToRestore(_session, DateTime.now());
  }

  @override
  Future<void> clear() async {
    _session = null;
  }
}
