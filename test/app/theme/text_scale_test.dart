import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/text_scale.dart';

void main() {
  test('medium is the default factor', () {
    expect(appTextScaleFactor(AppTextScale.medium), 1.0);
  });

  test('all presets expose labels and ordered options', () {
    expect(textScaleOptions(), [AppTextScale.small, AppTextScale.medium, AppTextScale.large, AppTextScale.extraLarge]);
    expect(textScaleLabel(AppTextScale.large), 'Large');
  });

  test('medium has no storage key', () {
    expect(textScaleStorageKey(AppTextScale.medium), isNull);
    expect(textScaleStorageKey(AppTextScale.small), 'small');
  });
}
