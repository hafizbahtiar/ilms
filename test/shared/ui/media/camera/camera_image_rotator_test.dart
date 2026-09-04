import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/media/camera/camera_image_rotator.dart';
import 'package:ilms/shared/ui/media/camera/camera_orientation.dart';

void main() {
  group('CameraImageRotator.degreesFor', () {
    // Confirmed on-device: the photo needs the OPPOSITE rotation direction
    // from the icon rotation (CameraDeviceOrientation.turns) to come out
    // right-side-up, not just correctly shaped. Using `turns` directly
    // produced a portrait-shaped but upside-down photo for both landscape
    // orientations.
    test('portraitUp needs no rotation', () {
      expect(CameraImageRotator.degreesFor(CameraDeviceOrientation.portraitUp), 0);
    });

    test('landscapeLeft rotates 270 clockwise to restore portrait, right-side up', () {
      expect(CameraImageRotator.degreesFor(CameraDeviceOrientation.landscapeLeft), 270);
    });

    test('portraitDown rotates 180', () {
      expect(CameraImageRotator.degreesFor(CameraDeviceOrientation.portraitDown), 180);
    });

    test('landscapeRight rotates 90 clockwise to restore portrait, right-side up', () {
      expect(CameraImageRotator.degreesFor(CameraDeviceOrientation.landscapeRight), 90);
    });

    test('is the opposite direction from the icon rotation for both landscape orientations', () {
      const landscapeOrientations = [CameraDeviceOrientation.landscapeLeft, CameraDeviceOrientation.landscapeRight];
      for (final orientation in landscapeOrientations) {
        final iconDegrees = (orientation.turns * 360).round() % 360;
        expect(CameraImageRotator.degreesFor(orientation), (360 - iconDegrees) % 360);
      }
    });
  });
}
