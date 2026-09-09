import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ilms/shared/ui/media/camera/camera_status.dart';
import 'package:ilms/shared/ui/media/camera/camera_status_view.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

/// Full-screen barcode/QR scanner (sticker no., license QR, etc).
///
/// Returns the scanned raw value, or `null` when cancelled.
///
class AppBarcodeScannerPage extends StatefulWidget {
  const AppBarcodeScannerPage({
    super.key,
    this.title = 'Scan Code',
    this.subtitle = 'Align the code within the frame',
    this.allowGallery = true,
    this.validator,
  });

  final String title;
  final String subtitle;
  final bool allowGallery;

  final String? Function(String sanitizedValue)? validator;

  static Future<String?> open(
    BuildContext context, {
    String title = 'Scan Code',
    String subtitle = 'Align the code within the frame',
    bool allowGallery = true,
    String? Function(String sanitizedValue)? validator,
  }) {
    return Navigator.of(context).push<String>(
      PageRouteBuilder<String>(
        fullscreenDialog: true,
        opaque: true,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) =>
            AppBarcodeScannerPage(title: title, subtitle: subtitle, allowGallery: allowGallery, validator: validator),
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
  State<AppBarcodeScannerPage> createState() => _AppBarcodeScannerPageState();

  static String sanitizeValue(String value) {
    return value.trim().replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '');
  }

  /// Geometry of the scan window, shared by the overlay painter and the
  /// chrome anchored around it. Keeping it in one place is what stops the
  /// helper text and the gallery button from drifting into the reticle on
  /// short (landscape) viewports.
  @visibleForTesting
  static Rect cutOutRect(Size size) {
    const topReserve = 96.0;
    const bottomReserve = 150.0;

    final side = math.min(
      math.min(size.shortestSide * 0.62, 300.0),
      math.max(size.height - topReserve - bottomReserve, 160.0),
    );
    final minCenterY = topReserve + side / 2;
    final maxCenterY = math.max(size.height - bottomReserve - side / 2, minCenterY);
    final centerY = math.min(math.max(size.height * 0.42, minCenterY), maxCenterY);

    return Rect.fromCenter(center: Offset(size.width / 2, centerY), width: side, height: side);
  }
}

class _AppBarcodeScannerPageState extends State<AppBarcodeScannerPage> with SingleTickerProviderStateMixin {
  // `useAppLifecycleState` (default true) already pauses/resumes the camera
  // on app background/foreground — no need to observe lifecycle ourselves.
  late final MobileScannerController _controller;
  late final AnimationController _sweep;
  var _handled = false;
  var _isAnalyzingImage = false;
  var _locked = false;
  String? _lastRejectedValue;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
    _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the platform "reduce motion" setting: without the sweep the
    // reticle simply sits still.
    if (MediaQuery.disableAnimationsOf(context)) {
      _sweep.stop();
    } else if (!_sweep.isAnimating && !_locked) {
      _sweep.repeat();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _handleValue(value);
  }

  Future<void> _handleValue(String rawValue) async {
    final value = AppBarcodeScannerPage.sanitizeValue(rawValue);
    if (value.isEmpty) return;

    final validationError = widget.validator?.call(value);
    if (validationError != null && validationError.isNotEmpty) {
      // The same rejected code re-enters the frame many times a second;
      // only speak up when it is a code we have not already rejected.
      if (_lastRejectedValue != value) {
        _lastRejectedValue = value;
        _showMessage(validationError);
      }
      return;
    }

    _handled = true;
    HapticFeedback.mediumImpact();
    await _controller.stop();
    if (!mounted) return;

    // Hold the locked reticle briefly so the inspector sees which read was
    // accepted before the page dismisses.
    _sweep.stop();
    setState(() => _locked = true);
    await Future<void>.delayed(const Duration(milliseconds: 240));
    if (!mounted) return;
    Navigator.of(context).pop(value);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _close() => Navigator.of(context).pop();

  Future<void> _pickFromGallery() async {
    if (_handled || _isAnalyzingImage) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (!mounted || picked == null) return;

    setState(() => _isAnalyzingImage = true);
    try {
      final capture = await _controller.analyzeImage(picked.path);
      final value = capture?.barcodes.isEmpty ?? true ? null : capture!.barcodes.first.rawValue;
      if (value == null || value.isEmpty) {
        _showMessage('No code found in that image. Try a sharper photo.');
        return;
      }
      await _handleValue(value);
    } on MobileScannerBarcodeException {
      _showMessage('No code found in that image. Try a sharper photo.');
    } catch (error) {
      _showMessage('Could not read the code: $error');
    } finally {
      if (mounted) setState(() => _isAnalyzingImage = false);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _sweep.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // MobileScanner must stay mounted for its controller to attach and
          // start the camera — it owns starting/stopping and its own
          // permission request internally. Loading/permission/error states
          // are rendered in-place via placeholderBuilder/errorBuilder rather
          // than by conditionally mounting this widget.
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            placeholderBuilder: (context) => Center(
              child: CameraStatusView(
                status: CameraStatus.initializing,
                onRetry: () {},
                onOpenSettings: openAppSettings,
                onClose: _close,
              ),
            ),
            errorBuilder: (context, error) => Center(
              child: CameraStatusView(
                status: switch (error.errorCode) {
                  MobileScannerErrorCode.permissionDenied => CameraStatus.permissionDenied,
                  _ => CameraStatus.error,
                },
                message: error.errorDetails?.message,
                onRetry: () => _controller.start(),
                onOpenSettings: openAppSettings,
                onClose: _close,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final cutOut = AppBarcodeScannerPage.cutOutRect(constraints.biggest);
              final bottomInset = MediaQuery.paddingOf(context).bottom;

              return Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _ScannerReticlePainter(
                          cutOut: cutOut,
                          sweep: _sweep,
                          locked: _locked,
                          showSweep: !_locked && !MediaQuery.disableAnimationsOf(context),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      bottom: false,
                      child: _TopBar(title: widget.title, onClose: _close, controller: _controller),
                    ),
                  ),
                  Positioned(
                    top: cutOut.bottom + 28,
                    left: 32,
                    right: 32,
                    child: IgnorePointer(
                      child: Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ),
                  ),
                  if (widget.allowGallery)
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: bottomInset + 28,
                      child: Center(
                        child: _GalleryButton(
                          busy: _isAnalyzingImage,
                          onPressed: _isAnalyzingImage || _locked ? null : _pickFromGallery,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

const _accent = Color(0xFFFFE600);
const _glassSize = 48.0;

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onClose, required this.controller});

  final String title;
  final VoidCallback onClose;
  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          _ScannerGlassButton(icon: Icons.close_rounded, semanticLabel: 'Close scanner', onTap: onClose),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: controller,
            builder: (context, value, child) {
              final torchState = value.torchState;
              if (torchState == TorchState.unavailable) {
                return const SizedBox(width: _glassSize);
              }

              final active = torchState == TorchState.on;
              return _ScannerGlassButton(
                icon: active ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                semanticLabel: active ? 'Turn torch off' : 'Turn torch on',
                active: active,
                onTap: controller.toggleTorch,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScannerGlassButton extends StatelessWidget {
  const _ScannerGlassButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: _glassSize,
          height: _glassSize,
          decoration: BoxDecoration(
            color: active ? _accent : Colors.black.withValues(alpha: 0.38),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Icon(icon, color: active ? Colors.black : Colors.white, size: _glassSize * 0.44),
        ),
      ),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  const _GalleryButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: busy
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.photo_library_outlined, size: 20),
      label: Text(busy ? 'Reading image…' : 'Scan from a photo'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white54,
        backgroundColor: Colors.black.withValues(alpha: 0.38),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: const StadiumBorder(),
      ),
    );
  }
}

/// Scrim, corner brackets and the scanning sweep. The brackets are drawn as
/// real L-shaped paths (an arc plus two arms), not as closed boxes.
class _ScannerReticlePainter extends CustomPainter {
  _ScannerReticlePainter({required this.cutOut, required this.sweep, required this.locked, required this.showSweep})
    : super(repaint: sweep);

  final Rect cutOut;
  final Animation<double> sweep;
  final bool locked;
  final bool showSweep;

  static const _borderWidth = 4.0;
  static const _armLength = 34.0;
  static const _radius = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(cutOut, const Radius.circular(_radius));

    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addRRect(rrect),
      Paint()..color = Colors.black.withValues(alpha: 0.66),
    );

    if (showSweep) {
      _paintSweep(canvas);
    }

    final stroke = Paint()
      ..color = locked ? _accent : Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_brackets(), stroke);
  }

  void _paintSweep(Canvas canvas) {
    // Ease the line to a pause at each end rather than bouncing mechanically.
    final t = Curves.easeInOutSine.transform((1 - math.cos(sweep.value * 2 * math.pi)) / 2);
    final y = cutOut.top + _borderWidth + t * (cutOut.height - _borderWidth * 2);
    final band = Rect.fromLTRB(cutOut.left, y - 26, cutOut.right, y + 2);

    canvas
      ..save()
      ..clipRRect(RRect.fromRectAndRadius(cutOut, const Radius.circular(_radius)))
      ..drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_accent.withValues(alpha: 0), _accent.withValues(alpha: 0.28)],
          ).createShader(band),
      )
      ..drawLine(
        Offset(cutOut.left, y),
        Offset(cutOut.right, y),
        Paint()
          ..color = _accent.withValues(alpha: 0.85)
          ..strokeWidth = 1.6,
      )
      ..restore();
  }

  Path _brackets() {
    final path = Path();
    for (final corner in _Corner.values) {
      final (x, y) = switch (corner) {
        _Corner.topLeft => (cutOut.left, cutOut.top),
        _Corner.topRight => (cutOut.right, cutOut.top),
        _Corner.bottomRight => (cutOut.right, cutOut.bottom),
        _Corner.bottomLeft => (cutOut.left, cutOut.bottom),
      };
      final sx = corner == _Corner.topRight || corner == _Corner.bottomRight ? -1.0 : 1.0;
      final sy = corner == _Corner.bottomLeft || corner == _Corner.bottomRight ? -1.0 : 1.0;

      path
        ..moveTo(x, y + sy * (_radius + _armLength))
        ..lineTo(x, y + sy * _radius)
        ..arcToPoint(Offset(x + sx * _radius, y), radius: const Radius.circular(_radius), clockwise: sx * sy > 0)
        ..lineTo(x + sx * (_radius + _armLength), y);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _ScannerReticlePainter oldDelegate) {
    return oldDelegate.cutOut != cutOut || oldDelegate.locked != locked || oldDelegate.showSweep != showSweep;
  }
}

enum _Corner { topLeft, topRight, bottomRight, bottomLeft }
