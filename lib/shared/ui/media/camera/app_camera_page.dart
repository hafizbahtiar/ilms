import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/media/camera/camera_service.dart';
import 'package:ilms/shared/ui/media/camera/camera_scaffold.dart';

/// Full-screen camera with multi-capture review before accepting photos.
///
/// Returns captured files when the user taps **Done**, or an empty list when cancelled.
class AppCameraPage extends StatefulWidget {
  const AppCameraPage({super.key, this.maxPhotos});

  /// Optional cap on how many photos can be captured in one session.
  final int? maxPhotos;

  static Future<List<File>> open(BuildContext context, {int? maxPhotos}) {
    return Navigator.of(context)
        .push<List<File>>(
          PageRouteBuilder<List<File>>(
            fullscreenDialog: true,
            opaque: true,
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 220),
            pageBuilder: (context, animation, secondaryAnimation) => AppCameraPage(maxPhotos: maxPhotos),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                child: child,
              );
            },
          ),
        )
        .then((value) => value ?? const []);
  }

  @override
  State<AppCameraPage> createState() => _AppCameraPageState();
}

class _AppCameraPageState extends State<AppCameraPage> with WidgetsBindingObserver {
  final AppCameraService _cameraService = AppCameraService();
  final List<File> _captures = [];
  final ScrollController _reviewScrollController = ScrollController();
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

  bool get _canCaptureMore {
    final max = widget.maxPhotos;
    if (max == null) return true;
    return _captures.length < max;
  }

  Future<void> _capture() async {
    if (_isProcessing || !_canCaptureMore) return;

    setState(() => _isProcessing = true);
    final image = await _cameraService.takePicture();
    if (!mounted) return;

    setState(() => _isProcessing = false);
    if (image == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _captures.add(File(image.path)));
    _scrollReviewToEnd();
  }

  void _scrollReviewToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_reviewScrollController.hasClients) return;
      _reviewScrollController.animateTo(
        _reviewScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _removeCapture(int index) {
    setState(() => _captures.removeAt(index));
  }

  Future<void> _close() async {
    if (_captures.isEmpty) {
      Navigator.pop(context, const <File>[]);
      return;
    }

    final discard = await confirmAppDialog(
      context: context,
      title: 'Discard photos?',
      message: 'You have ${_captures.length} unsaved photo${_captures.length == 1 ? '' : 's'}.',
      cancelLabel: 'Keep editing',
      confirmLabel: 'Discard',
      confirmStyle: AppDialogActionStyle.destructive,
    );

    if (discard == true && mounted) {
      Navigator.pop(context, const <File>[]);
    }
  }

  void _acceptCaptures() {
    Navigator.pop(context, List<File>.unmodifiable(_captures));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _reviewScrollController.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraScaffold(
      service: _cameraService,
      isProcessing: _isProcessing,
      captures: _captures,
      canCaptureMore: _canCaptureMore,
      onCapture: _capture,
      onClose: _close,
      onDone: _captures.isEmpty ? null : _acceptCaptures,
      onRemoveCapture: _removeCapture,
      reviewScrollController: _reviewScrollController,
      onRetry: _setupCamera,
      onSwitchCamera: _switchCamera,
      onOpenSettings: _cameraService.openSettings,
    );
  }
}
