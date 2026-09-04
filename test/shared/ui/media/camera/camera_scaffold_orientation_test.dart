import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/media/camera/camera_orientation.dart';
import 'package:ilms/shared/ui/media/camera/camera_scaffold.dart';
import 'package:ilms/shared/ui/media/camera/camera_service.dart';
import 'package:sensors_plus/sensors_plus.dart';

const _g = 9.81;

AccelerometerEvent _event(double x, double y) => AccelerometerEvent(x, y, 0, DateTime.now());

class _FakeCameraService extends AppCameraService {
  @override
  bool get isInitialized => true;

  @override
  bool get canSwitchCamera => true;

  @override
  bool get hasMultipleBackLenses => true;

  @override
  bool get isUsingFrontCamera => false;

  @override
  FlashMode get flashMode => FlashMode.off;

  @override
  bool get supportsZoom => false;

  @override
  bool get supportsExposureControl => false;
}

Future<void> _pumpCamera(
  WidgetTester tester, {
  CameraOrientationController? orientationController,
}) {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: CameraScaffold(
        service: _FakeCameraService(),
        isProcessing: false,
        onCapture: () {},
        onClose: () {},
        onRetry: () {},
        onOpenSettings: () {},
        onSwitchCamera: () {},
        onCycleLens: () {},
        orientationController: orientationController,
        previewChild: const ColoredBox(color: Colors.black),
      ),
    ),
  );
}

/// Turns currently requested for the [AnimatedRotation] wrapping [icon].
double _turnsFor(WidgetTester tester, IconData icon) {
  final rotation = tester.widget<AnimatedRotation>(
    find.ancestor(
      of: find.byIcon(icon),
      matching: find.byType(AnimatedRotation),
    ),
  );
  return rotation.turns;
}

void main() {
  group('control glyphs follow the physical device orientation', () {
    late StreamController<AccelerometerEvent> sensor;
    late CameraOrientationController controller;

    setUp(() {
      sensor = StreamController<AccelerometerEvent>.broadcast();
      controller = CameraOrientationController(source: sensor.stream)..start();
    });

    tearDown(() async {
      controller.dispose();
      await sensor.close();
    });

    testWidgets('every control glyph starts upright', (tester) async {
      await _pumpCamera(tester, orientationController: controller);

      for (final icon in const [
        Icons.close_rounded,
        Icons.flash_off_rounded,
        Icons.cameraswitch_rounded,
        Icons.crop_free_rounded,
      ]) {
        expect(_turnsFor(tester, icon), 0, reason: '$icon');
      }
    });

    testWidgets('tilting to landscape rotates the glyphs a quarter turn', (tester) async {
      await _pumpCamera(tester, orientationController: controller);

      sensor.add(_event(_g, 0));
      await tester.pump();

      for (final icon in const [
        Icons.close_rounded,
        Icons.flash_off_rounded,
        Icons.cameraswitch_rounded,
        Icons.crop_free_rounded,
      ]) {
        expect(_turnsFor(tester, icon), 0.25, reason: '$icon');
      }
    });

    testWidgets('the opposite landscape rotates the short way round', (tester) async {
      await _pumpCamera(tester, orientationController: controller);

      sensor.add(_event(-_g, 0));
      await tester.pump();

      expect(_turnsFor(tester, Icons.close_rounded), -0.25);
    });

    testWidgets('the preview card and layout do not rotate with the device', (tester) async {
      await _pumpCamera(tester, orientationController: controller);
      final before = tester.getRect(find.byKey(CameraScaffold.previewCardKey));

      sensor.add(_event(_g, 0));
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byKey(CameraScaffold.previewCardKey)), before);
      // Only the glyphs are wrapped in a rotation, never the preview.
      expect(
        find.ancestor(
          of: find.byKey(CameraScaffold.previewCardKey),
          matching: find.byType(AnimatedRotation),
        ),
        findsNothing,
      );
    });

    testWidgets('labels stay upright so they never overflow their slot', (tester) async {
      await _pumpCamera(tester, orientationController: controller);
      final before = tester.getRect(find.text('Flip'));

      sensor.add(_event(_g, 0));
      await tester.pumpAndSettle();

      expect(tester.getRect(find.text('Flip')), before);
    });
  });

  testWidgets('glyphs render unrotated when no orientation controller is given', (tester) async {
    await _pumpCamera(tester);

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.byType(AnimatedRotation), findsNothing);
  });
}
