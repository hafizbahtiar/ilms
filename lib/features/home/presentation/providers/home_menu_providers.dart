import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/home/data/datasources/home_menu_data_source.dart';
import 'package:ilms/features/home/data/datasources/mock_home_menu_data_source.dart';
import 'package:ilms/features/home/data/repositories/home_menu_repository_impl.dart';
import 'package:ilms/features/home/domain/entities/home_module_group.dart';
import 'package:ilms/features/home/domain/repositories/home_menu_repository.dart';

final homeMenuDataSourceProvider = Provider<HomeMenuDataSource>((ref) {
  return const MockHomeMenuDataSource();
});

final homeMenuRepositoryProvider = Provider<HomeMenuRepository>((ref) {
  return HomeMenuRepositoryImpl(ref.read(homeMenuDataSourceProvider));
});

final homeMenuGroupsProvider = FutureProvider<List<HomeModuleGroup>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return const [];

  return ref.read(homeMenuRepositoryProvider).getGroups(user.permissions);
});
