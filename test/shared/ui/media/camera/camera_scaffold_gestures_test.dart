import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/media/camera/camera_gesture_overlay.dart';
import 'package:ilms/shared/ui/media/camera/camera_scaffold.dart';
import 'package:ilms/shared/ui/media/camera/camera_service.dart';

// 1x1 transparent PNG, just enough for Image.file to decode without error.
const _onePixelPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class _FakeCameraService extends AppCameraService {
  double _zoom = 1.0;
  double _exposure = 0.0;
  Offset? lastFocus;
  final zoomCalls = <double>[];

  @override
  bool get isInitialized => true;

  @override
  bool get supportsZoom => true;

  @override
  double get minZoom => 1.0;

  @override
  double get maxZoom => 8.0;

  @override
  double get zoom => _zoom;

  @override
  void setZoom(double zoom) {
    _zoom = zoom.clamp(minZoom, maxZoom);
    zoomCalls.add(_zoom);
  }

  @override
  bool get supportsExposureControl => true;

  @override
  double get minExposureOffset => -2.0;

  @override
  double get maxExposureOffset => 2.0;

  @override
  double get exposureOffset => _exposure;

  @override
  void setExposureOffset(double offset) {
    _exposure = offset.clamp(minExposureOffset, maxExposureOffset);
  }

  @override
  Future<void> focusOnPoint(Offset point) async {
    lastFocus = point;
  }

  @override
  bool get canSwitchCamera => false;

  @override
  bool get hasMultipleBackLenses => false;

  @override
  bool get isUsingFrontCamera => false;

  @override
  FlashMode get flashMode => FlashMode.off;

  @override
  Future<FlashMode> cycleFlashMode() async => flashMode;
}

Future<void> _pumpCamera(
  WidgetTester tester,
  _FakeCameraService service, {
  VoidCallback? onDone,
  List<File> captures = const [],
  ValueChanged<int>? onRemoveCapture,
  ValueChanged<int>? onPreviewCapture,
}) {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: CameraScaffold(
        service: service,
        isProcessing: false,
        onCapture: () {},
        onClose: () {},
        onRetry: () {},
        onOpenSettings: () {},
        onSwitchCamera: () {},
        onCycleLens: () {},
        onDone: onDone,
        captures: captures,
        onRemoveCapture: onRemoveCapture,
        onPreviewCapture: onPreviewCapture,
        previewChild: const ColoredBox(color: Colors.black),
      ),
    ),
  );
}

Future<void> _pinchOut(WidgetTester tester, Offset center) async {
  final first = await tester.startGesture(center + const Offset(-20, 0));
  final second = await tester.startGesture(center + const Offset(20, 0));
  await tester.pump();
  await first.moveBy(const Offset(-80, 0));
  await second.moveBy(const Offset(80, 0));
  await tester.pump();
  await first.up();
  await second.up();
  await tester.pump();
}

void main() {
  testWidgets('two-finger pinch zooms through camera chrome overlays', (
    tester,
  ) async {
    final service = _FakeCameraService();
    await _pumpCamera(tester, service);

    final center = tester.getCenter(find.byType(CameraGestureOverlay));
    await _pinchOut(tester, center);

    expect(service.zoomCalls, isNotEmpty);
    expect(service.zoom, greaterThan(1.0));
  });

  testWidgets('tap focuses and sun slider adjusts brightness', (tester) async {
    final service = _FakeCameraService();
    await _pumpCamera(tester, service);

    final center = tester.getCenter(find.byType(CameraGestureOverlay));
    await tester.tapAt(center);
    await tester.pump();

    expect(service.lastFocus, isNotNull);
    expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);

    await tester.drag(
      find.byIcon(Icons.wb_sunny_rounded),
      const Offset(0, -40),
    );
    await tester.pump();

    expect(service.exposureOffset, greaterThan(0));
  });

  testWidgets('brightness slider hides after idle timeout', (tester) async {
    final service = _FakeCameraService();
    await _pumpCamera(tester, service);

    final center = tester.getCenter(find.byType(CameraGestureOverlay));
    await tester.tapAt(center);
    await tester.pump();
    expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.wb_sunny_rounded), findsNothing);
  });

  testWidgets('pinch hides the brightness slider', (tester) async {
    final service = _FakeCameraService();
    await _pumpCamera(tester, service);

    final center = tester.getCenter(find.byType(CameraGestureOverlay));
    await tester.tapAt(center);
    await tester.pump();
    expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);

    await _pinchOut(tester, center);
    await tester.pump();
    expect(find.byIcon(Icons.wb_sunny_rounded), findsNothing);
  });

  testWidgets('preview sits in a wide rounded box, not full-screen crop', (
    tester,
  ) async {
    final service = _FakeCameraService();
    await _pumpCamera(tester, service);

    final overlaySize = tester.getSize(find.byType(CameraGestureOverlay));
    expect(overlaySize.width, greaterThan(370));
    expect(overlaySize.height, lessThan(700));
    expect(find.byKey(CameraScaffold.previewCardKey), findsOneWidget);
  });

  testWidgets('flash stays available when Done is shown', (tester) async {
    final service = _FakeCameraService();
    await _pumpCamera(tester, service, onDone: () {});

    expect(find.textContaining('Done'), findsOneWidget);
    expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);
  });

  group('capture review strip', () {
    late File capture;

    setUp(() {
      capture = File('${Directory.systemTemp.path}/camera_scaffold_test_${DateTime.now().microsecondsSinceEpoch}.png')
        ..writeAsBytesSync(_onePixelPng);
    });

    tearDown(() {
      if (capture.existsSync()) capture.deleteSync();
    });

    testWidgets('tapping a thumbnail opens the preview for that index', (tester) async {
      int? previewedIndex;
      final service = _FakeCameraService();
      await _pumpCamera(
        tester,
        service,
        captures: [capture],
        onPreviewCapture: (index) => previewedIndex = index,
      );

      await tester.tap(find.byType(Image));
      await tester.pump();

      expect(previewedIndex, 0);
    });
  });
}
