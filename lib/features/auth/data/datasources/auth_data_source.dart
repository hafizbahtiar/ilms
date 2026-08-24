import 'package:ilms/features/auth/data/models/login_response_model.dart';

abstract class AuthDataSource {
  Future<LoginDataModel> login({required String username, required String password});

  Future<LoginDataModel> autoLogin();

  Future<void> logout();

  /// The hosted forgot-password page URL, or `null` if the backend didn't
  /// provide one.
  Future<String?> getForgotPasswordUrl();
}
