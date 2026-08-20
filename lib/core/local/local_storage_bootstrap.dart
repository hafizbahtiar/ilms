import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/core/local/files/internal_storage_manager.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';

class LocalStorageBootstrap {
  static Future<void> init() async {
    await AppPreferences.init();
    InternalStorageManager.initialize(rootPath: 'ilms_storage');
    await AppDatabase.init();
  }

  static void resetForTests() {
    AppDatabase.reset();
    AppPreferences.reset();
  }
}
