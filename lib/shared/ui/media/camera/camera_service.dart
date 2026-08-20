import 'dart:developer' as dev;

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:ilms/shared/ui/media/camera/camera_status.dart';
import 'package:permission_handler/permission_handler.dart';

/// Manages camera permission, preview lifecycle, flash, and capture.
class AppCameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  CameraDescription? _activeCamera;

  CameraStatus _status = CameraStatus.uninitialized;
  CameraStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  FlashMode _flashMode = FlashMode.off;
  FlashMode get flashMode => _flashMode;

  CameraController? get controller => _controller;
  bool get isInitialized => _status == CameraStatus.ready && (_controller?.value.isInitialized ?? false);
  bool get canSwitchCamera => (_cameras?.length ?? 0) > 1;

  Future<void> initialize() async {
    if (_status == CameraStatus.initializing) return;
    _status = CameraStatus.initializing;
    _errorMessage = null;

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      _status = permission.isPermanentlyDenied
          ? CameraStatus.permissionDeniedForever
          : CameraStatus.permissionDenied;
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
    return cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
  }

  Future<void> switchCamera() async {
    final cameras = _cameras;
    final active = _activeCamera;
    if (cameras == null || active == null || cameras.length < 2 || !isInitialized) return;

    final currentIndex = cameras.indexOf(active);
    final next = cameras[(currentIndex + 1) % cameras.length];

    _status = CameraStatus.initializing;
    await _disposeController();
    _activeCamera = next;

    try {
      await _startController(next);
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

    _flashMode = FlashMode.off;
    await controller.setFlashMode(_flashMode);
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
