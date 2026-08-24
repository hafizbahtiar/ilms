import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/features/auth/data/datasources/auth_data_source.dart';
import 'package:ilms/features/auth/data/local/auth_session_store.dart';
import 'package:ilms/features/auth/data/models/login_response_model.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._sessionStore);

  final AuthDataSource _dataSource;
  final AuthSessionStore _sessionStore;

  @override
  Future<AuthUser> login({required String username, required String password}) async {
    final data = await _dataSource.login(username: username, password: password);
    await _sessionStore.save(data);
    return _mapToUser(data, fallbackId: username);
  }

  @override
  Future<AuthUser> autoLogin() async {
    final token = await _sessionStore.restorableAccessToken();
    if (token == null) {
      throw const AuthException('No valid session.');
    }

    DioClient.instance.setAccessToken(token);

    try {
      final data = await _dataSource.autoLogin();
      await _sessionStore.save(data, existingAccessToken: token);
      return _mapToUser(data, fallbackToken: token);
    } on AuthException {
      await clearSession();
      rethrow;
    }
  }

  @override
  Future<void> clearSession() async {
    DioClient.instance.clearAccessToken();
    await _sessionStore.clear();
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } finally {
      await clearSession();
    }
  }

  @override
  Future<String?> getForgotPasswordUrl() => _dataSource.getForgotPasswordUrl();

  AuthUser _mapToUser(LoginDataModel data, {String? fallbackId, String? fallbackToken}) {
    final accessToken = data.accessToken ?? fallbackToken;

    return AuthUser(
      id: accessToken ?? data.email ?? fallbackId ?? '',
      name: data.name ?? '',
      email: data.email ?? '',
      accessToken: accessToken,
      tokenType: data.tokenType,
      expiresAt: data.expiresAt,
      roles: data.roles,
      permissions: data.permissions,
    );
  }
}
