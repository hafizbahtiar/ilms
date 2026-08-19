import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_controller.dart';

class FakeSuccessRepository implements AuthRepository {
  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    return const AuthUser(id: '1', name: 'Demo User', email: 'demo@ilms.com');
  }
}

class FakeFailureRepository implements AuthRepository {
  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    throw const AuthException('Invalid email or password.');
  }
}

void main() {
  test('login moves state to success when credentials are valid', () async {
    final controller = AuthController(FakeSuccessRepository());

    await controller.login(email: 'demo@ilms.com', password: 'password123');

    expect(controller.state.user?.email, 'demo@ilms.com');
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, isNull);
  });

  test('login moves state to error when credentials are invalid', () async {
    final controller = AuthController(FakeFailureRepository());

    await controller.login(email: 'wrong@ilms.com', password: 'wrong-password');

    expect(controller.state.user, isNull);
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, 'Invalid email or password.');
  });
}
