import 'package:ilms/features/home/domain/entities/home_module_group.dart';

abstract class HomeMenuDataSource {
  Future<List<HomeModuleGroup>> fetchGroups();
}
