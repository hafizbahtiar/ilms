import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_controller.dart';

class FakeSuccessRepository implements AuthRepository {
  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
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
}

class FakeFailureRepository implements AuthRepository {
  @override
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
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
}

void main() {
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
