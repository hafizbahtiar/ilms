import 'package:ilms/features/home/data/datasources/home_menu_data_source.dart';
import 'package:ilms/features/home/domain/entities/home_module_group.dart';
import 'package:ilms/features/home/domain/repositories/home_menu_repository.dart';

class HomeMenuRepositoryImpl implements HomeMenuRepository {
  HomeMenuRepositoryImpl(this._dataSource);

  final HomeMenuDataSource _dataSource;

  @override
  Future<List<HomeModuleGroup>> getGroups(List<String> permissions) async {
    final groups = await _dataSource.fetchGroups();

    return [
      for (final group in groups)
        if (permissions.contains(group.permission))
          HomeModuleGroup(
            id: group.id,
            permission: group.permission,
            title: group.title,
            icon: group.icon,
            color: group.color,
            items: group.visibleItemsFor(permissions),
          ),
    ];
  }
}
