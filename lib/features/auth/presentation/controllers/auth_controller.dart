import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> login({required String username, required String password}) async {
    state = const AuthState(isLoading: true);

    try {
      final user = await _repository.login(username: username, password: password);
      state = AuthState(user: user);
    } on AuthException catch (error) {
      state = AuthState(errorMessage: error.message);
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final user = await _repository.autoLogin();
      state = AuthState(user: user);
      return true;
    } catch (_) {
      try {
        await _repository.clearSession();
      } catch (_) {
        // Never crash startup when secure storage is unavailable.
      }
      state = const AuthState();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}
