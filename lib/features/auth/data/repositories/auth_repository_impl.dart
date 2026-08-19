import 'package:ilms/features/auth/data/datasources/auth_data_source.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Future<AuthUser> login({required String email, required String password}) async {
    final rawUser = await _dataSource.login(email: email, password: password);

    return AuthUser(id: rawUser['id'] ?? '', name: rawUser['name'] ?? '', email: rawUser['email'] ?? '');
  }
}
