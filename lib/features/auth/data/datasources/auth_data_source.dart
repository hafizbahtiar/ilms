import 'package:ilms/features/auth/data/models/login_response_model.dart';

abstract class AuthDataSource {
  Future<LoginDataModel> login({required String username, required String password});

  Future<LoginDataModel> autoLogin();

  Future<void> logout();
}
