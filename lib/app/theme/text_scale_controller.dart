import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/app/theme/text_scale.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';

class TextScaleController extends StateNotifier<AppTextScale> {
  TextScaleController(this._preferences) : super(_load(_preferences));

  static const _prefsKey = 'text_scale';

  final AppPreferences _preferences;

  static AppTextScale _load(AppPreferences preferences) {
    return appTextScaleFromStorage(preferences.getString(_prefsKey));
  }

  Future<void> setScale(AppTextScale scale) async {
    state = scale;
    final key = textScaleStorageKey(scale);
    if (key == null) {
      await _preferences.remove(_prefsKey);
    } else {
      await _preferences.setString(_prefsKey, key);
    }
  }
}

final textScaleControllerProvider = StateNotifierProvider<TextScaleController, AppTextScale>((ref) {
  return TextScaleController(AppPreferences.instance);
});
