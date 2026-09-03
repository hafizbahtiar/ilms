import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/core/services/crash_log/crash_log_service.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, {this._crashLogService}) : super(const AuthState());

  final AuthRepository _repository;
  final CrashLogService? _crashLogService;

  Future<void> login({required String username, required String password}) async {
    state = const AuthState(isLoading: true);

    try {
      final user = await _repository.login(username: username, password: password);
      state = AuthState(user: user);
    } on AuthException catch (error) {
      state = AuthState(errorMessage: error.message);
      _reportLoginFailure(error, username: username);
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

  void _reportLoginFailure(AuthException error, {required String username}) {
    final service = _crashLogService;
    if (service == null) return;

    unawaited(
      service.reportError(
        module: 'auth',
        page: AppRoutes.login,
        type: _loginErrorType(error.message),
        error: error,
        context: {'username': username},
      ),
    );
  }

  String _loginErrorType(String message) {
    const networkHints = ['Unable to reach the server', 'Unable to connect to the server', 'Server error'];

    if (networkHints.any(message.contains)) {
      return 'network';
    }

    return 'business';
  }
}
