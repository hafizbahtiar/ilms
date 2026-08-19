import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/config/app_flavor.dart';

void main() {
  test('fromName maps flavor strings', () {
    expect(AppFlavor.fromName('dev'), AppFlavor.dev);
    expect(AppFlavor.fromName('stg'), AppFlavor.stg);
    expect(AppFlavor.fromName('prod'), AppFlavor.prod);
  });

  test('fromName defaults to dev when empty', () {
    expect(AppFlavor.fromName(null), AppFlavor.dev);
    expect(AppFlavor.fromName(''), AppFlavor.dev);
  });
}
