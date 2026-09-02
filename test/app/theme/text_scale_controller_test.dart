import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/text_scale.dart';
import 'package:ilms/app/theme/text_scale_controller.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPreferences.reset();
    await AppPreferences.init();
  });

  tearDown(AppPreferences.reset);

  test('defaults to medium when nothing is stored', () {
    final controller = TextScaleController(AppPreferences.instance);
    expect(controller.state, AppTextScale.medium);
  });

  test('setScale updates state and persists the selection', () async {
    final controller = TextScaleController(AppPreferences.instance);
    await controller.setScale(AppTextScale.large);
    expect(controller.state, AppTextScale.large);
    expect(AppPreferences.instance.getString('text_scale'), 'large');
  });

  test('persisted selection is restored on a new controller', () async {
    final controller = TextScaleController(AppPreferences.instance);
    await controller.setScale(AppTextScale.small);
    final restored = TextScaleController(AppPreferences.instance);
    expect(restored.state, AppTextScale.small);
  });

  test('setScale to medium removes the stored key', () async {
    final controller = TextScaleController(AppPreferences.instance);
    await controller.setScale(AppTextScale.large);
    await controller.setScale(AppTextScale.medium);
    expect(controller.state, AppTextScale.medium);
    expect(AppPreferences.instance.getString('text_scale'), isNull);
  });
}
