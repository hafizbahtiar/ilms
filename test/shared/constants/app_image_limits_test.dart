import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/constants/app_image_limits.dart';

void main() {
  group('AppImageLimits', () {
    test('remainingImageSlots clamps at zero', () {
      expect(remainingImageSlots(currentCount: 28), 2);
      expect(remainingImageSlots(currentCount: 30), 0);
      expect(remainingImageSlots(currentCount: 40), 0);
    });

    test('canAddMoreImages respects default max', () {
      expect(canAddMoreImages(currentCount: 29), isTrue);
      expect(canAddMoreImages(currentCount: 30), isFalse);
    });
  });
}
