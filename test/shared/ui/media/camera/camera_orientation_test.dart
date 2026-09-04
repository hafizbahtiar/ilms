import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/media/camera/camera_orientation.dart';
import 'package:sensors_plus/sensors_plus.dart';

const _g = 9.81;

AccelerometerEvent _event(double x, double y) => AccelerometerEvent(x, y, 0, DateTime.now());

void main() {
  group('CameraOrientationResolver', () {
    test('classifies the four upright orientations', () {
      // A fresh resolver per case: hysteresis is intentionally sticky.
      expect(
        CameraOrientationResolver().resolve(0, _g),
        CameraDeviceOrientation.portraitUp,
      );
      expect(
        CameraOrientationResolver().resolve(_g, 0),
        CameraDeviceOrientation.landscapeLeft,
      );
      expect(
        CameraOrientationResolver().resolve(0, -_g),
        CameraDeviceOrientation.portraitDown,
      );
      expect(
        CameraOrientationResolver().resolve(-_g, 0),
        CameraDeviceOrientation.landscapeRight,
      );
    });

    test('holds the last orientation while the phone lies flat', () {
      final resolver = CameraOrientationResolver();
      expect(resolver.resolve(_g, 0), CameraDeviceOrientation.landscapeLeft);

      // Face-up on a table: almost no gravity in the screen plane.
      expect(resolver.resolve(0.2, 0.1), CameraDeviceOrientation.landscapeLeft);
      expect(resolver.resolve(0, 0), CameraDeviceOrientation.landscapeLeft);
    });

    test('hysteresis keeps a near-diagonal tilt from flapping', () {
      final resolver = CameraOrientationResolver();
      expect(resolver.current, CameraDeviceOrientation.portraitUp);

      // 50 degrees towards landscape-left: past the 45 degree boundary but
      // inside the hysteresis margin, so it must not switch yet.
      expect(
        resolver.resolve(_g * 0.766, _g * 0.643),
        CameraDeviceOrientation.portraitUp,
      );

      // 70 degrees: clearly committed.
      expect(
        resolver.resolve(_g * 0.940, _g * 0.342),
        CameraDeviceOrientation.landscapeLeft,
      );
    });

    test('honours a custom hysteresis margin', () {
      final resolver = CameraOrientationResolver(hysteresisDegrees: 0);
      // 50 degrees now switches immediately.
      expect(
        resolver.resolve(_g * 0.766, _g * 0.643),
        CameraDeviceOrientation.landscapeLeft,
      );
    });

    test('turns map a quarter turn per step', () {
      expect(CameraDeviceOrientation.portraitUp.turns, 0);
      expect(CameraDeviceOrientation.landscapeLeft.turns, 0.25);
      expect(CameraDeviceOrientation.portraitDown.turns, 0.5);
      expect(CameraDeviceOrientation.landscapeRight.turns, 0.75);
    });
  });

  group('nearestEquivalentTurns', () {
    test('takes the short way round instead of three quarter turns', () {
      expect(CameraOrientationController.nearestEquivalentTurns(0, 0.75), -0.25);
      expect(CameraOrientationController.nearestEquivalentTurns(-0.25, 0.5), -0.5);
      expect(CameraOrientationController.nearestEquivalentTurns(0.25, 0.5), 0.5);
      expect(CameraOrientationController.nearestEquivalentTurns(0, 0.25), 0.25);
    });

    test('is idempotent for an unchanged orientation', () {
      expect(CameraOrientationController.nearestEquivalentTurns(-0.25, 0.75), -0.25);
    });
  });

  group('CameraOrientationController', () {
    late StreamController<AccelerometerEvent> sensor;
    late CameraOrientationController controller;

    setUp(() {
      sensor = StreamController<AccelerometerEvent>.broadcast();
      controller = CameraOrientationController(source: sensor.stream);
    });

    tearDown(() async {
      controller.dispose();
      await sensor.close();
    });

    test('publishes unwrapped turns as the phone rotates', () async {
      controller.start();
      final seen = <double>[];
      controller.addListener(() => seen.add(controller.value));

      sensor.add(_event(_g, 0));
      await pumpEventQueue();
      expect(controller.orientation, CameraDeviceOrientation.landscapeLeft);

      sensor.add(_event(-_g, 0));
      await pumpEventQueue();
      expect(controller.orientation, CameraDeviceOrientation.landscapeRight);

      expect(seen, [0.25, -0.25]);
    });

    test('does not notify when the orientation is unchanged', () async {
      controller.start();
      var notifications = 0;
      controller.addListener(() => notifications++);

      sensor.add(_event(0, _g));
      sensor.add(_event(0.5, _g));
      await pumpEventQueue();

      expect(notifications, 0);
      expect(controller.value, 0);
    });

    test('start is idempotent', () async {
      controller.start();
      controller.start();
      var notifications = 0;
      controller.addListener(() => notifications++);

      sensor.add(_event(_g, 0));
      await pumpEventQueue();

      expect(notifications, 1);
    });

    test('survives a sensor stream error', () async {
      controller.start();
      sensor.addError(Exception('no accelerometer'));
      await pumpEventQueue();

      sensor.add(_event(_g, 0));
      await pumpEventQueue();

      expect(controller.value, 0.25);
    });
  });

  group('rotating chrome', () {
    testWidgets('AnimatedRotation is not applied without a controller', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Icon(Icons.flash_off_rounded)),
      );
      expect(find.byType(AnimatedRotation), findsNothing);
    });
  });
}
