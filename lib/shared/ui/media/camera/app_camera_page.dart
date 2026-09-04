import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/media/app_image_viewer_page.dart';
import 'package:ilms/shared/ui/media/camera/camera_image_rotator.dart';
import 'package:ilms/shared/ui/media/camera/camera_orientation.dart';
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
  final CameraOrientationController _orientationController = CameraOrientationController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // The camera behaves like a stock camera app: the layout never rotates,
    // only the control glyphs do (driven by _orientationController). Locking
    // the UI to portrait is also what keeps captures upright — see
    // AppCameraService._startController's lockCaptureOrientation.
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    _orientationController.start();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    await _cameraService.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _switchCamera() async {
    await _cameraService.toggleFrontBack();
    if (mounted) setState(() {});
  }

  Future<void> _cycleLens() async {
    await _cameraService.cycleBackLens();
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

    // Sampled at the moment of the shutter press — the same sensor reading
    // already driving the (confirmed-working) icon rotation — so the photo
    // gets rotated to match exactly how the phone was actually held.
    final capturedAt = _orientationController.orientation;

    setState(() => _isProcessing = true);
    final image = await _cameraService.takePicture();
    if (!mounted) return;

    if (image == null) {
      setState(() => _isProcessing = false);
      return;
    }

    HapticFeedback.mediumImpact();

    // `lockCaptureOrientation` on the camera controller only promises
    // correct EXIF metadata — on several devices the JPEG still comes back
    // physically landscape-shaped. Force it into the same portrait shape the
    // screen is locked to, using our own sensor reading rather than trusting
    // the camera plugin/EXIF, so the thumbnail, the full-screen viewer, and
    // the backend upload all show it upright — as if it had been manually
    // rotated straight after a sideways snap.
    final captured = File(image.path);
    final corrected = await CameraImageRotator.correctForCapture(captured, capturedAt: capturedAt);
    if (!mounted) return;
    if (corrected.path != captured.path && captured.existsSync()) {
      unawaited(captured.delete());
    }

    setState(() {
      _isProcessing = false;
      _captures.add(corrected);
    });
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

  /// Rotates the capture at [index] and, once done, feeds the still-open
  /// viewer the resulting image so it reflects the rotation in place.
  Future<AppImageItem?> _rotateCapture(int index) async {
    if (index < 0 || index >= _captures.length) return null;
    final original = _captures[index];

    final rotated = await CameraImageRotator.rotateClockwise(original);
    if (!mounted) return null;

    setState(() => _captures[index] = rotated);

    if (rotated.path != original.path && original.existsSync()) {
      unawaited(original.delete());
    }
    return AppImageItem(localPath: rotated.path);
  }

  void _previewCapture(int index) {
    showAppImageViewer(
      context,
      images: _captures.map((file) => AppImageItem(localPath: file.path)).toList(),
      initialIndex: index,
      onRotate: _rotateCapture,
    );
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
    // Empty list restores whatever the platform manifest/plist allows.
    SystemChrome.setPreferredOrientations(const []);
    _orientationController.dispose();
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
      onPreviewCapture: _previewCapture,
      reviewScrollController: _reviewScrollController,
      onRetry: _setupCamera,
      onSwitchCamera: _switchCamera,
      onCycleLens: _cycleLens,
      onOpenSettings: _cameraService.openSettings,
      orientationController: _orientationController,
    );
  }
}
