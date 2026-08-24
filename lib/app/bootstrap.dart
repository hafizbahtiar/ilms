import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/config/app_flavor.dart';
import '../core/local/local_storage_bootstrap.dart';
import '../core/local/preferences/app_preferences.dart';
import '../core/local/secure/secure_token_store.dart';
import '../core/network/dio_client.dart';
import '../core/services/crash_log/crash_log_handler.dart';
import '../core/services/device_info_service.dart';
import '../features/auth/data/local/secure_auth_session_store.dart';
import '../flavors.dart' as flavors;
import 'app.dart';
import 'environment/environment_controller.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageBootstrap.init();

  final storedFlavor = AppPreferences.instance.getString(environmentOverridePrefsKey);
  final flavor = storedFlavor != null ? AppFlavor.fromName(storedFlavor) : AppFlavor.fromName(flavors.appFlavor);
  await AppConfig.init(flavor: flavor);
  DioClient.create(AppConfig.instance);
  await DeviceInfoService.init();
  CrashLogHandler.init();

  final sessionStore = SecureAuthSessionStore(
    secureTokenStore: const FlutterSecureTokenStore(),
    preferences: AppPreferences.instance,
  );
  final token = await sessionStore.restorableAccessToken();
  if (token != null) {
    DioClient.instance.setAccessToken(token);
  }

  runApp(const ProviderScope(child: App()));
}
