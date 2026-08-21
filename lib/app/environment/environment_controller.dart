import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:ilms/flavors.dart' as flavors;

const environmentOverridePrefsKey = 'env_flavor_override';

class EnvironmentController extends StateNotifier<AppFlavor> {
  EnvironmentController(this._preferences) : super(_load(_preferences));

  final AppPreferences _preferences;

  static AppFlavor _load(AppPreferences preferences) {
    final stored = preferences.getString(environmentOverridePrefsKey);
    if (stored != null) {
      return AppFlavor.fromName(stored);
    }
    return AppFlavor.fromName(flavors.appFlavor);
  }

  Future<void> setFlavor(AppFlavor flavor) async {
    if (flavor == state) return;

    await _preferences.setString(environmentOverridePrefsKey, flavor.name);

    AppConfig.reset();
    await AppConfig.init(flavor: flavor);

    DioClient.reset();
    DioClient.create(AppConfig.instance);

    state = flavor;
  }
}

final environmentControllerProvider = StateNotifierProvider<EnvironmentController, AppFlavor>((ref) {
  return EnvironmentController(AppPreferences.instance);
});
