import 'dart:developer' as dev;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ilms/shared/ui/media/camera/camera_status.dart';
import 'package:permission_handler/permission_handler.dart';

/// Manages camera permission, preview lifecycle, flash, exposure, zoom,
/// focus, lens selection, and capture.
class AppCameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  CameraDescription? _activeCamera;
  CameraDescription? _lastBackLens;

  CameraStatus _status = CameraStatus.uninitialized;
  CameraStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  FlashMode _flashMode = FlashMode.off;
  FlashMode get flashMode => _flashMode;

  // Exposure (brightness) range cached from the device after init.
  double _minExposureOffset = 0.0;
  double _maxExposureOffset = 0.0;
  double _exposureOffset = 0.0;
  double get minExposureOffset => _minExposureOffset;
  double get maxExposureOffset => _maxExposureOffset;
  double get exposureOffset => _exposureOffset;

  /// Whether the device exposes a usable exposure (brightness) range.
  bool get supportsExposureControl => _maxExposureOffset > _minExposureOffset;

  // Zoom range cached from the device after init.
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _zoom = 1.0;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  double get zoom => _zoom;
  bool get supportsZoom => _maxZoom > _minZoom;

  CameraController? get controller => _controller;
  bool get isInitialized => _status == CameraStatus.ready && (_controller?.value.isInitialized ?? false);
  bool get canSwitchCamera => _backLenses.isNotEmpty && _frontCameras.isNotEmpty;

  List<CameraDescription> get _backLenses =>
      (_cameras ?? const []).where((c) => c.lensDirection == CameraLensDirection.back).toList()..sort(_lensSortOrder);
  List<CameraDescription> get _frontCameras =>
      (_cameras ?? const []).where((c) => c.lensDirection == CameraLensDirection.front).toList();

  /// Back-facing lenses available on this device, ordered wide -> ultraWide ->
  /// telephoto -> unknown. Populated with more than one entry only when the
  /// platform reports multiple physical back cameras.
  List<CameraDescription> get availableBackLenses => _backLenses;
  bool get hasMultipleBackLenses => _backLenses.length > 1;
  bool get isUsingFrontCamera => _activeCamera?.lensDirection == CameraLensDirection.front;

  static int _lensRank(CameraDescription camera) => switch (camera.lensType) {
    CameraLensType.ultraWide => 0,
    CameraLensType.wide => 1,
    CameraLensType.telephoto => 2,
    CameraLensType.unknown => 1,
  };

  static int _lensSortOrder(CameraDescription a, CameraDescription b) => _lensRank(a).compareTo(_lensRank(b));

  Future<void> initialize() async {
    if (_status == CameraStatus.initializing) return;
    _status = CameraStatus.initializing;
    _errorMessage = null;

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      _status = permission.isPermanentlyDenied ? CameraStatus.permissionDeniedForever : CameraStatus.permissionDenied;
      return;
    }

    try {
      _cameras ??= await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _status = CameraStatus.error;
        _errorMessage = 'No camera found on this device.';
        return;
      }

      _activeCamera ??= _preferredCamera(_cameras!);
      await _startController(_activeCamera!);
      _status = CameraStatus.ready;
    } catch (e) {
      dev.log('Camera init failed: $e', name: 'AppCameraService');
      _status = CameraStatus.error;
      _errorMessage = 'Failed to start the camera.';
    }
  }

  CameraDescription _preferredCamera(List<CameraDescription> cameras) {
    final backLenses = cameras.where((c) => c.lensDirection == CameraLensDirection.back).toList()..sort(_lensSortOrder);
    if (backLenses.isNotEmpty) return backLenses.first;
    return cameras.first;
  }

  /// Toggle between the front camera and the last-used (or preferred) back
  /// lens. Does not affect which back lens is remembered.
  Future<void> toggleFrontBack() async {
    if (!isInitialized || !canSwitchCamera) return;

    final target = isUsingFrontCamera ? (_lastBackLens ?? _preferredCamera(_cameras!)) : _frontCameras.first;

    if (!isUsingFrontCamera) _lastBackLens = _activeCamera;
    await _switchTo(target);
  }

  /// Cycle to the next back-facing lens (e.g. wide -> ultra-wide ->
  /// telephoto -> wide). No-op if only one back lens is available.
  Future<void> cycleBackLens() async {
    if (!isInitialized || !hasMultipleBackLenses) return;

    final lenses = _backLenses;
    final current = isUsingFrontCamera ? (_lastBackLens ?? lenses.first) : _activeCamera!;
    final currentIndex = lenses.indexOf(current);
    final next = lenses[(currentIndex + 1) % lenses.length];

    _lastBackLens = next;
    await _switchTo(next);
  }

  Future<void> _switchTo(CameraDescription description) async {
    _status = CameraStatus.initializing;
    await _disposeController();
    _activeCamera = description;

    try {
      await _startController(description);
      _status = CameraStatus.ready;
    } catch (e) {
      dev.log('Camera switch failed: $e', name: 'AppCameraService');
      _status = CameraStatus.error;
      _errorMessage = 'Failed to switch camera.';
    }
  }

  Future<void> _startController(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller.initialize();
    _controller = controller;

    try {
      // Bakes the correct rotation into captured photos regardless of how
      // the phone is physically held, since the UI/preview orientation is
      // locked to portrait (see AppCameraPage) — otherwise a photo taken
      // while the phone is rotated would come out sideways.
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } catch (e) {
      dev.log('lockCaptureOrientation not supported: $e', name: 'AppCameraService');
    }

    _flashMode = FlashMode.off;
    await controller.setFlashMode(_flashMode);

    try {
      _minExposureOffset = await controller.getMinExposureOffset();
      _maxExposureOffset = await controller.getMaxExposureOffset();
      _exposureOffset = 0.0;
      await controller.setExposureOffset(_exposureOffset);
    } catch (e) {
      dev.log('Exposure not supported: $e', name: 'AppCameraService');
      _minExposureOffset = 0.0;
      _maxExposureOffset = 0.0;
    }

    try {
      _minZoom = await controller.getMinZoomLevel();
      _maxZoom = await controller.getMaxZoomLevel();
      _zoom = _minZoom;
    } catch (e) {
      dev.log('Zoom not supported: $e', name: 'AppCameraService');
      _minZoom = 1.0;
      _maxZoom = 1.0;
    }
  }

  Future<void> openSettings() => openAppSettings();

  Future<void> handleAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      await _disposeController();
    } else if (state == AppLifecycleState.resumed) {
      if (_status != CameraStatus.ready && _status != CameraStatus.initializing) {
        await initialize();
      }
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    if (controller == null) return;
    _controller = null;
    await controller.dispose();
  }

  Future<FlashMode> cycleFlashMode() async {
    if (!isInitialized) return _flashMode;

    _flashMode = switch (_flashMode) {
      FlashMode.off => FlashMode.torch,
      FlashMode.torch => FlashMode.auto,
      _ => FlashMode.off,
    };

    try {
      await _controller!.setFlashMode(_flashMode);
    } catch (e) {
      dev.log('Flash mode error: $e', name: 'AppCameraService');
    }
    return _flashMode;
  }

  // --- Exposure (brightness) ------------------------------------------------
  //
  // Slider/drag gestures fire dozens of events per second. Forwarding every
  // one straight to the native camera floods the HAL request queue and can
  // crash it ("Lost connection to device"). Instead we coalesce: keep only
  // the latest requested value and run a single call at a time.
  double? _pendingExposure;
  bool _exposureBusy = false;

  /// Set the exposure (brightness) offset, clamped to the device range.
  /// Calls are coalesced so a fast drag never floods the native camera.
  void setExposureOffset(double offset) {
    if (!isInitialized || !supportsExposureControl) return;

    _pendingExposure = offset.clamp(_minExposureOffset, _maxExposureOffset);
    _exposureOffset = _pendingExposure!; // optimistic UI value
    _drainExposure();
  }

  Future<void> _drainExposure() async {
    if (_exposureBusy) return;
    _exposureBusy = true;
    try {
      while (_pendingExposure != null) {
        final target = _pendingExposure!;
        _pendingExposure = null;
        try {
          _exposureOffset = await _controller!.setExposureOffset(target);
        } catch (e) {
          dev.log('Error setting exposure: $e', name: 'AppCameraService');
        }
      }
    } finally {
      _exposureBusy = false;
    }
  }

  // --- Zoom -----------------------------------------------------------------
  double? _pendingZoom;
  bool _zoomBusy = false;

  /// Set the zoom level, clamped to the device range. Calls are coalesced and
  /// no-op'd when the value hasn't meaningfully changed, so pinch gestures
  /// never flood the native camera with redundant `setZoomLevel` requests.
  void setZoom(double zoom) {
    if (!isInitialized || !supportsZoom) return;

    final clamped = zoom.clamp(_minZoom, _maxZoom);
    if ((clamped - _zoom).abs() < 0.01 && _pendingZoom == null) return;

    _pendingZoom = clamped;
    _zoom = clamped; // optimistic UI value
    _drainZoom();
  }

  Future<void> _drainZoom() async {
    if (_zoomBusy) return;
    _zoomBusy = true;
    try {
      while (_pendingZoom != null) {
        final target = _pendingZoom!;
        _pendingZoom = null;
        try {
          await _controller!.setZoomLevel(target);
        } catch (e) {
          dev.log('Error setting zoom: $e', name: 'AppCameraService');
        }
      }
    } finally {
      _zoomBusy = false;
    }
  }

  // --- Tap to focus -----------------------------------------------------------

  /// Point the focus and exposure metering at [point] (normalized 0..1
  /// within the preview), mirroring standard phone-camera tap-to-focus.
  Future<void> focusOnPoint(Offset point) async {
    if (!isInitialized) return;
    try {
      if (_controller!.value.focusPointSupported) {
        await _controller!.setFocusMode(FocusMode.auto);
        await _controller!.setFocusPoint(point);
      }
      if (_controller!.value.exposurePointSupported) {
        await _controller!.setExposureMode(ExposureMode.auto);
        await _controller!.setExposurePoint(point);
      }
    } catch (e) {
      dev.log('Error focusing on point: $e', name: 'AppCameraService');
    }
  }

  Future<XFile?> takePicture() async {
    if (!isInitialized) return null;

    try {
      return await _controller!.takePicture();
    } catch (e) {
      dev.log('Capture error: $e', name: 'AppCameraService');
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _status = CameraStatus.uninitialized;
  }
}
