import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/data/datasources/mock_auth_data_source.dart';
import 'package:ilms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';

void main() {
  test('login returns AuthUser for valid demo credentials', () async {
    final repository = AuthRepositoryImpl(MockAuthDataSource());

    final user = await repository.login(
      email: 'demo@ilms.com',
      password: 'password123',
    );

    expect(user.email, 'demo@ilms.com');
    expect(user.name, isNotEmpty);
  });

  test('login throws AuthException for invalid credentials', () async {
    final repository = AuthRepositoryImpl(MockAuthDataSource());

    expect(
      () =>
          repository.login(email: 'wrong@ilms.com', password: 'wrong-password'),
      throwsA(isA<AuthException>()),
    );
  });
}
