import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/local_storage_providers.dart';
import 'package:ilms/features/auth/data/datasources/api_auth_data_source.dart';
import 'package:ilms/features/auth/data/datasources/auth_data_source.dart';
import 'package:ilms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_state.dart';

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return ApiAuthDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authDataSourceProvider), ref.read(authSessionStoreProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});
