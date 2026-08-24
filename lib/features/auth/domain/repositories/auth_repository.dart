import 'package:ilms/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> login({required String username, required String password});

  Future<AuthUser> autoLogin();

  Future<void> clearSession();

  Future<void> logout();

  Future<String?> getForgotPasswordUrl();
}
