import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ilms/shared/ui/media/camera/camera_service.dart';
import 'package:ilms/shared/ui/media/camera/camera_scaffold.dart';

/// Full-screen camera capture page.
///
/// Returns the captured [File] via [Navigator.pop], or `null` when cancelled.
class AppCameraPage extends StatefulWidget {
  const AppCameraPage({super.key});

  static Future<File?> open(BuildContext context) {
    return Navigator.of(context).push<File?>(
      PageRouteBuilder<File?>(
        fullscreenDialog: true,
        opaque: true,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) => const AppCameraPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<AppCameraPage> createState() => _AppCameraPageState();
}

class _AppCameraPageState extends State<AppCameraPage> with WidgetsBindingObserver {
  final AppCameraService _cameraService = AppCameraService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    await _cameraService.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _switchCamera() async {
    await _cameraService.switchCamera();
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _cameraService.handleAppLifecycleState(state).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _capture() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    final image = await _cameraService.takePicture();
    if (!mounted) return;

    setState(() => _isProcessing = false);
    if (image == null) return;

    HapticFeedback.mediumImpact();
    Navigator.pop(context, File(image.path));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraScaffold(
      service: _cameraService,
      isProcessing: _isProcessing,
      onCapture: _capture,
      onClose: () => Navigator.pop(context),
      onRetry: _setupCamera,
      onSwitchCamera: _switchCamera,
      onOpenSettings: () async {
        await _cameraService.openSettings();
      },
    );
  }
}
