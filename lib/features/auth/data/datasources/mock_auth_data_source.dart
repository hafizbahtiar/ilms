import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';

import 'auth_data_source.dart';

class MockAuthDataSource implements AuthDataSource {
  @override
  Future<Map<String, String>> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (email == 'demo@ilms.com' && password == 'password123') {
      return {'id': '1', 'name': 'Demo User', 'email': 'demo@ilms.com'};
    }

    throw const AuthException('Invalid email or password.');
  }
}
