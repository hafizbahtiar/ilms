import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/data/local/auth_session_resolver.dart';
import 'package:ilms/features/auth/data/models/login_response_model.dart';

void main() {
  group('AuthSessionResolver.sessionTokenToRestore', () {
    test('returns null when there is no stored session', () {
      expect(AuthSessionResolver.sessionTokenToRestore(null, DateTime.now()), isNull);
    });

    test('returns null when the stored token has already expired', () {
      final data = LoginDataModel(
        accessToken: 'expired-token',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      expect(AuthSessionResolver.sessionTokenToRestore(data, DateTime.now()), isNull);
    });

    test('returns the access token when the stored session is still valid', () {
      final data = LoginDataModel(
        accessToken: 'still-valid-token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(AuthSessionResolver.sessionTokenToRestore(data, DateTime.now()), 'still-valid-token');
    });
  });

  group('AuthSessionResolver.resolve', () {
    test('uses the secure-storage token when there is no legacy token in the session record', () {
      final resolved = AuthSessionResolver.resolve(
        sessionJson: {'name': 'Ali', 'roles': [], 'permissions': []},
        secureAccessToken: 'secure-token',
        secureExpiresAt: '2026-08-01T00:00:00.000Z',
      );

      expect(resolved.model.accessToken, 'secure-token');
      expect(resolved.model.name, 'Ali');
      expect(resolved.needsMigration, isFalse);
    });

    test('migrates a legacy token embedded in the session record when secure storage is empty', () {
      final resolved = AuthSessionResolver.resolve(
        sessionJson: {
          'name': 'Ali',
          'roles': [],
          'permissions': [],
          'access_token': 'legacy-token',
          'expires_at': '2026-08-01T00:00:00.000Z',
        },
        secureAccessToken: null,
        secureExpiresAt: null,
      );

      expect(resolved.model.accessToken, 'legacy-token');
      expect(resolved.needsMigration, isTrue);
      expect(resolved.strippedSessionJson.containsKey('access_token'), isFalse);
    });

    test('strips the session record when secure storage already has the token', () {
      final resolved = AuthSessionResolver.resolve(
        sessionJson: {
          'name': 'Ali',
          'roles': [],
          'permissions': [],
          'access_token': 'legacy-token',
          'expires_at': '2026-08-01T00:00:00.000Z',
        },
        secureAccessToken: 'legacy-token',
        secureExpiresAt: '2026-08-01T00:00:00.000Z',
      );

      expect(resolved.needsMigration, isFalse);
      expect(resolved.needsSessionStrip, isTrue);
      expect(resolved.strippedSessionJson.containsKey('access_token'), isFalse);
    });
  });
}
