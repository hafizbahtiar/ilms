import 'package:ilms/features/auth/data/models/login_response_model.dart';

abstract class AuthSessionStore {
  Future<void> save(LoginDataModel data, {String? existingAccessToken});

  Future<LoginDataModel?> readSession();

  Future<String?> restorableAccessToken();

  Future<void> clear();
}
