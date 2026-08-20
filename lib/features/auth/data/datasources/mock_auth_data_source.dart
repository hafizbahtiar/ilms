import 'package:ilms/features/auth/data/models/login_response_model.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';

import 'auth_data_source.dart';

class MockAuthDataSource implements AuthDataSource {
  @override
  Future<LoginDataModel> login({required String username, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (username == 'admin' && password == 'admin123456') {
      return LoginDataModel(
        accessToken: 'mock-access-token',
        tokenType: 'Bearer',
        expiresAt: DateTime.now().add(const Duration(hours: 12)),
        name: 'Admin User',
        email: 'admin@ilms.com',
        roles: const ['admin'],
        permissions: const ['view-mobile-premise', 'view-mobile-billboard', 'view-mobile-investigation'],
      );
    }

    throw const AuthException('Invalid username or password.');
  }

  @override
  Future<LoginDataModel> autoLogin() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return LoginDataModel(
      tokenType: 'Bearer',
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
      name: 'Admin User',
      email: 'admin@ilms.com',
      roles: const ['admin'],
      permissions: const ['view-mobile-premise', 'view-mobile-billboard', 'view-mobile-investigation'],
    );
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
