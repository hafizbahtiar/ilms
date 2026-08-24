import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/core/services/crash_log/crash_log_local_store.dart';
import 'package:ilms/core/services/crash_log/crash_log_repository.dart';
import 'package:ilms/core/services/crash_log/crash_log_service.dart';
import 'package:ilms/core/services/crash_log/mobile_error_log.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FakeSuccessRepository implements AuthRepository {
  @override
  Future<AuthUser> login({required String username, required String password}) async {
    return const AuthUser(id: '1', name: 'Admin User', email: 'admin@ilms.com');
  }

  @override
  Future<AuthUser> autoLogin() async {
    return const AuthUser(id: '1', name: 'Admin User', email: 'admin@ilms.com');
  }

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<String?> getForgotPasswordUrl() async => null;
}

class FakeFailureRepository implements AuthRepository {
  @override
  Future<AuthUser> login({required String username, required String password}) async {
    throw const AuthException('Invalid username or password.');
  }

  @override
  Future<AuthUser> autoLogin() async {
    throw const AuthException('No valid session.');
  }

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<String?> getForgotPasswordUrl() async => null;
}

class FakeNetworkFailureRepository implements AuthRepository {
  @override
  Future<AuthUser> login({required String username, required String password}) async {
    throw const AuthException('Unable to reach the server. Please check your connection and try again.');
  }

  @override
  Future<AuthUser> autoLogin() async {
    throw const AuthException('No valid session.');
  }

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<String?> getForgotPasswordUrl() async => null;
}

class SpyCrashLogService extends CrashLogService {
  SpyCrashLogService({required CrashLogLocalStore localStore})
    : super(
        repository: _NoopCrashLogRepository(),
        localStore: localStore,
        packageInfo: PackageInfo(
          appName: 'ILMS',
          packageName: 'com.example.ilms',
          version: '1.0.1',
          buildNumber: '1',
        ),
      );

  Object? lastError;
  String? lastModule;
  String? lastPage;
  String? lastType;
  Map<String, dynamic>? lastContext;

  @override
  Future<void> reportError({
    required String module,
    String? page,
    required String type,
    required Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    lastError = error;
    lastModule = module;
    lastPage = page;
    lastType = type;
    lastContext = context;
  }
}

class _NoopCrashLogRepository extends CrashLogRepository {
  @override
  Future<void> send(MobileErrorLog log) async {}
}

void main() {
  AppDatabase? spyDatabase;

  SpyCrashLogService createSpy() {
    spyDatabase ??= AppDatabase.forTesting(NativeDatabase.memory());
    return SpyCrashLogService(localStore: CrashLogLocalStore(spyDatabase!));
  }

  tearDown(() {
    spyDatabase?.close();
    spyDatabase = null;
  });
  test('login moves state to success when credentials are valid', () async {
    final controller = AuthController(FakeSuccessRepository());

    await controller.login(username: 'admin', password: 'admin123456');

    expect(controller.state.user?.email, 'admin@ilms.com');
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, isNull);
  });

  test('login moves state to error when credentials are invalid', () async {
    final controller = AuthController(FakeFailureRepository());

    await controller.login(username: 'wrong-user', password: 'wrong-password');

    expect(controller.state.user, isNull);
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, 'Invalid username or password.');
  });

  test('login reports credential failures as business errors', () async {
    final crashLogService = createSpy();
    final controller = AuthController(FakeFailureRepository(), crashLogService: crashLogService);

    await controller.login(username: 'wrong-user', password: 'wrong-password');

    expect(crashLogService.lastModule, 'auth');
    expect(crashLogService.lastPage, '/login');
    expect(crashLogService.lastType, 'business');
    expect(crashLogService.lastContext?['username'], 'wrong-user');
    expect(crashLogService.lastError, isA<AuthException>());
  });

  test('login reports connectivity failures as network errors', () async {
    final crashLogService = createSpy();
    final controller = AuthController(FakeNetworkFailureRepository(), crashLogService: crashLogService);

    await controller.login(username: 'admin', password: 'admin123456');

    expect(crashLogService.lastType, 'network');
    expect(crashLogService.lastModule, 'auth');
  });

  test('tryAutoLogin moves state to success when session is valid', () async {
    final controller = AuthController(FakeSuccessRepository());

    final success = await controller.tryAutoLogin();

    expect(success, isTrue);
    expect(controller.state.user?.email, 'admin@ilms.com');
  });

  test('tryAutoLogin clears state when session is invalid', () async {
    final controller = AuthController(FakeFailureRepository());

    final success = await controller.tryAutoLogin();

    expect(success, isFalse);
    expect(controller.state.user, isNull);
  });
}
