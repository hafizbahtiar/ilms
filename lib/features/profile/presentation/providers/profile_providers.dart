import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/profile/data/datasources/api_profile_data_source.dart';
import 'package:ilms/features/profile/data/datasources/profile_data_source.dart';
import 'package:ilms/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ilms/features/profile/domain/repositories/profile_repository.dart';
import 'package:ilms/features/profile/presentation/controllers/profile_controller.dart';
import 'package:ilms/features/profile/presentation/controllers/profile_state.dart';

final profileDataSourceProvider = Provider<ProfileDataSource>((ref) {
  return ApiProfileDataSource();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.read(profileDataSourceProvider));
});

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController(ref.read(profileRepositoryProvider));
});
