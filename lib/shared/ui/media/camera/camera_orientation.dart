import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// The physical orientation of the handset, derived from the accelerometer.
///
/// This is deliberately *not* `DeviceOrientation` from `flutter/services`:
/// that reflects the **UI** orientation, which the camera page pins to
/// portrait. What the camera chrome needs is where gravity actually is, so
/// glyphs can stay upright while the layout does not move.
enum CameraDeviceOrientation {
  /// Held upright.
  portraitUp,

  /// Rotated a quarter turn anti-clockwise (top edge points left).
  landscapeLeft,

  /// Held upside down.
  portraitDown,

  /// Rotated a quarter turn clockwise (top edge points right).
  landscapeRight;

  /// Clockwise rotation, in turns, that keeps a glyph upright relative to
  /// gravity when the surrounding layout is locked to portrait.
  ///
  /// Normalised to `[0, 1)`; see [CameraOrientationController] for the
  /// shortest-path unwrapping used when animating between values.
  double get turns => index * 0.25;
}

/// Maps raw accelerometer readings onto a [CameraDeviceOrientation].
///
/// Pure, stateful-but-hardware-free, so the thresholding rules can be unit
/// tested without a device.
///
/// Axis convention (`sensors_plus` normalises iOS to match Android): with the
/// handset upright and facing the user, `x` grows to the right and `y` grows
/// towards the sky, and the reading is the vector pointing *away* from earth.
/// So upright gives `y ≈ +9.81`, and `x ≈ +9.81` means the right edge points
/// skyward — i.e. the top edge points left.
@visibleForTesting
class CameraOrientationResolver {
  CameraOrientationResolver({
    this.flatThreshold = 4.0,
    this.hysteresisDegrees = 15.0,
    CameraDeviceOrientation initial = CameraDeviceOrientation.portraitUp,
  }) : _current = initial;

  /// Minimum in-plane gravity (m/s^2) before a reading is trusted. Below this
  /// the handset is lying flat and its rotation about the screen normal is
  /// meaningless, so the last known orientation is held.
  final double flatThreshold;

  /// Extra rotation, past the 45 degree sector boundary, required before
  /// switching. Stops the icons flapping when held near a diagonal.
  final double hysteresisDegrees;

  CameraDeviceOrientation _current;
  CameraDeviceOrientation get current => _current;

  /// Folds one accelerometer sample in and returns the resulting orientation.
  CameraDeviceOrientation resolve(double x, double y) {
    final magnitude = math.sqrt(x * x + y * y);
    if (magnitude < flatThreshold) return _current;

    final degrees = (math.atan2(x, y) * 180 / math.pi + 360) % 360;
    final currentCenter = _current.index * 90.0;

    var delta = (degrees - currentCenter).abs() % 360;
    if (delta > 180) delta = 360 - delta;
    if (delta <= 45 + hysteresisDegrees) return _current;

    final sector = (((degrees + 45) ~/ 90) % 4).toInt();
    return _current = CameraDeviceOrientation.values[sector];
  }
}

/// Publishes the rotation (in turns) that camera chrome glyphs should adopt so
/// they stay upright while the phone is physically rotated.
///
/// The emitted value is *unwrapped*: it is always the representation of the
/// target angle nearest the previous value, so `AnimatedRotation` takes the
/// short way round (e.g. portrait -> landscape-right animates to `-0.25`, not
/// `0.75`).
///
/// If the sensor is unavailable — no accelerometer, or the plugin was not
/// registered because the app was hot-restarted instead of rebuilt — the
/// failure is logged and the value simply stays put. The chrome keeps working,
/// it just does not rotate.
class CameraOrientationController extends ValueNotifier<double> {
  CameraOrientationController({
    @visibleForTesting Stream<AccelerometerEvent>? source,
    CameraOrientationResolver? resolver,
  }) : _sensorStream = source,
       _resolver = resolver ?? CameraOrientationResolver(),
       super(0);

  final Stream<AccelerometerEvent>? _sensorStream;
  final CameraOrientationResolver _resolver;
  StreamSubscription<AccelerometerEvent>? _subscription;

  /// Last resolved physical orientation.
  CameraDeviceOrientation get orientation => _resolver.current;

  /// Begins listening to the accelerometer. Safe to call more than once.
  void start() {
    if (_subscription != null) return;
    try {
      final stream =
          _sensorStream ??
          accelerometerEventStream(
            samplingPeriod: SensorInterval.uiInterval,
          );
      _subscription = stream.listen(
        (event) => _apply(event.x, event.y),
        onError: (Object error) {
          dev.log('Accelerometer stream error: $error', name: 'CameraOrientationController');
        },
        cancelOnError: false,
      );
    } catch (e) {
      dev.log('Accelerometer unavailable: $e', name: 'CameraOrientationController');
    }
  }

  void _apply(double x, double y) {
    final resolved = _resolver.resolve(x, y);
    final next = nearestEquivalentTurns(value, resolved.turns);
    if (next != value) value = next;
  }

  /// Returns the representation of [target] (given in `[0, 1)`) closest to
  /// [previous], so rotation animates the short way round.
  @visibleForTesting
  static double nearestEquivalentTurns(double previous, double target) {
    return target + (previous - target).roundToDouble();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
