import 'package:ilms/features/auth/domain/entities/auth_user.dart';

class AuthState {
  const AuthState({this.isLoading = false, this.errorMessage, this.user});

  final bool isLoading;
  final String? errorMessage;
  final AuthUser? user;

  AuthState copyWith({bool? isLoading, String? errorMessage, AuthUser? user, bool clearError = false}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}
