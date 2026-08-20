import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/change_password/data/datasources/change_password_data_source.dart';
import 'package:ilms/features/change_password/data/datasources/mock_change_password_data_source.dart';
import 'package:ilms/features/change_password/data/repositories/change_password_repository_impl.dart';
import 'package:ilms/features/change_password/domain/repositories/change_password_repository.dart';
import 'package:ilms/features/change_password/presentation/controllers/change_password_controller.dart';
import 'package:ilms/features/change_password/presentation/controllers/change_password_state.dart';

final changePasswordDataSourceProvider = Provider<ChangePasswordDataSource>((ref) {
  return MockChangePasswordDataSource();
});

final changePasswordRepositoryProvider = Provider<ChangePasswordRepository>((ref) {
  return ChangePasswordRepositoryImpl(ref.read(changePasswordDataSourceProvider));
});

final changePasswordControllerProvider =
    StateNotifierProvider.autoDispose<ChangePasswordController, ChangePasswordState>((ref) {
      return ChangePasswordController(ref.read(changePasswordRepositoryProvider));
    });
