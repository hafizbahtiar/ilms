import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/environment/environment_controller.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:ilms/core/network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPreferences.reset();
    await AppPreferences.init();
  });

  tearDown(() {
    AppPreferences.reset();
    AppConfig.reset();
    DioClient.reset();
  });

  test('defaults to dev flavor when nothing is stored', () {
    final controller = EnvironmentController(AppPreferences.instance);

    expect(controller.state, AppFlavor.dev);
  });

  test('persisted override is restored on a new controller', () async {
    await AppPreferences.instance.setString(environmentOverridePrefsKey, 'stg');

    final controller = EnvironmentController(AppPreferences.instance);

    expect(controller.state, AppFlavor.stg);
  });

  test('setFlavor updates state, persists selection and rebuilds config/client', () async {
    final controller = EnvironmentController(AppPreferences.instance);

    await controller.setFlavor(AppFlavor.stg);

    expect(controller.state, AppFlavor.stg);
    expect(AppPreferences.instance.getString(environmentOverridePrefsKey), 'stg');
    expect(AppConfig.instance.flavor, AppFlavor.stg);
    expect(DioClient.instance, isNotNull);
  });

  test('setFlavor is a no-op when selecting the current flavor', () async {
    final controller = EnvironmentController(AppPreferences.instance);

    await controller.setFlavor(AppFlavor.dev);

    expect(controller.state, AppFlavor.dev);
    expect(AppPreferences.instance.getString(environmentOverridePrefsKey), isNull);
  });
}
