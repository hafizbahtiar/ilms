import 'package:ilms/features/home/domain/entities/home_module_group.dart';

abstract class HomeMenuRepository {
  Future<List<HomeModuleGroup>> getGroups(List<String> permissions);
}
