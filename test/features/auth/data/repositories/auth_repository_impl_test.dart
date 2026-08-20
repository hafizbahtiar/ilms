import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/auth/data/datasources/mock_auth_data_source.dart';
import 'package:ilms/features/auth/data/local/secure_auth_session_store.dart';
import 'package:ilms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';

void main() {
  setUp(() async {
    await AppConfig.init(
      flavor: AppFlavor.dev,
      loader: (_) async => {'APP_ENV': 'dev', 'BASE_URL': 'http://localhost'},
    );
    DioClient.create(AppConfig.instance);
  });

  tearDown(() {
    DioClient.reset();
    AppConfig.reset();
  });

  test('login returns AuthUser for valid demo credentials', () async {
    final repository = AuthRepositoryImpl(MockAuthDataSource(), InMemoryAuthSessionStore());

    final user = await repository.login(username: 'admin', password: 'admin123456');

    expect(user.email, 'admin@ilms.com');
    expect(user.name, isNotEmpty);
  });

  test('login throws AuthException for invalid credentials', () async {
    final repository = AuthRepositoryImpl(MockAuthDataSource(), InMemoryAuthSessionStore());

    expect(() => repository.login(username: 'wrong-user', password: 'wrong-password'), throwsA(isA<AuthException>()));
  });

  test('autoLogin returns user when session token exists', () async {
    final sessionStore = InMemoryAuthSessionStore();
    final repository = AuthRepositoryImpl(MockAuthDataSource(), sessionStore);

    await repository.login(username: 'admin', password: 'admin123456');
    final user = await repository.autoLogin();

    expect(user.email, 'admin@ilms.com');
    expect(user.accessToken, isNotEmpty);
    expect(user.roles, ['admin']);
    expect(user.permissions, contains('view-mobile-premise'));
  });

  test('stored session can be read before autoLogin refresh', () async {
    final sessionStore = InMemoryAuthSessionStore();
    final repository = AuthRepositoryImpl(MockAuthDataSource(), sessionStore);

    await repository.login(username: 'admin', password: 'admin123456');
    final stored = await sessionStore.readSession();

    expect(stored?.email, 'admin@ilms.com');
    expect(stored?.roles, ['admin']);
  });

  test('autoLogin throws when no stored session', () async {
    final repository = AuthRepositoryImpl(MockAuthDataSource(), InMemoryAuthSessionStore());

    expect(repository.autoLogin, throwsA(isA<AuthException>()));
  });

  test('logout clears the stored session', () async {
    final sessionStore = InMemoryAuthSessionStore();
    final repository = AuthRepositoryImpl(MockAuthDataSource(), sessionStore);

    await repository.login(username: 'admin', password: 'admin123456');
    expect(await sessionStore.restorableAccessToken(), isNotNull);

    await repository.logout();
    expect(await sessionStore.restorableAccessToken(), isNull);
  });
}
