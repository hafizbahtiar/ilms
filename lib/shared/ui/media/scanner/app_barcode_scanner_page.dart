import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ilms/shared/ui/media/camera/camera_status.dart';
import 'package:ilms/shared/ui/media/camera/camera_status_view.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

/// Full-screen barcode/QR scanner (sticker no., license QR, etc).
///
/// Returns the scanned raw value, or `null` when cancelled.
class AppBarcodeScannerPage extends StatefulWidget {
  const AppBarcodeScannerPage({super.key, this.title = 'Scan Code', this.subtitle = 'Align the code within the frame'});

  final String title;
  final String subtitle;

  static Future<String?> open(
    BuildContext context, {
    String title = 'Scan Code',
    String subtitle = 'Align the code within the frame',
  }) {
    return Navigator.of(context).push<String>(
      PageRouteBuilder<String>(
        fullscreenDialog: true,
        opaque: true,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) =>
            AppBarcodeScannerPage(title: title, subtitle: subtitle),
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
}

class _AppBarcodeScannerPageState extends State<AppBarcodeScannerPage> {
  // `useAppLifecycleState` (default true) already pauses/resumes the camera
  // on app background/foreground — no need to observe lifecycle ourselves.
  late final MobileScannerController _controller;
  var _handled = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _handled = true;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(value);
  }

  void _close() => Navigator.of(context).pop();

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, value, child) {
              if (!value.isRunning) return const SizedBox.shrink();
              return child!;
            },
            child: const _ScanViewfinderOverlay(),
          ),
          const _GradientOverlay(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0, 0.22]),
          const _GradientOverlay(begin: Alignment.bottomCenter, end: Alignment.topCenter, stops: [0, 0.3]),
          SafeArea(
            child: Column(
              children: [
                _TopBar(title: widget.title, onClose: _close, controller: _controller),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onClose, required this.controller});

  final String title;
  final VoidCallback onClose;
  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          _ScannerGlassButton(icon: Icons.close_rounded, onTap: onClose),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: controller,
            builder: (context, value, child) {
              final torchState = value.torchState;
              if (torchState == TorchState.unavailable) return const SizedBox(width: 46);

              final active = torchState == TorchState.on;
              return _ScannerGlassButton(
                icon: active ? Icons.flash_on_rounded : Icons.flash_off_rounded,
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
  const _ScannerGlassButton({required this.icon, required this.onTap, this.active = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  static const double _size = 46;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFE600) : Colors.black.withValues(alpha: 0.38),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: active ? Colors.black : Colors.white, size: _size * 0.46),
      ),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay({required this.begin, required this.end, required this.stops});

  final Alignment begin;
  final Alignment end;
  final List<double> stops;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            stops: stops,
            colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _ScanViewfinderOverlay extends StatelessWidget {
  const _ScanViewfinderOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 160),
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(painter: _ViewfinderPainter(color: Colors.white.withValues(alpha: 0.7))),
          ),
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  _ViewfinderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const corner = 26.0;
    final w = size.width;
    final h = size.height;

    void cornerLines(double x, double y, {required bool top, required bool left}) {
      final dx = left ? 1.0 : -1.0;
      final dy = top ? 1.0 : -1.0;
      canvas.drawLine(Offset(x, y), Offset(x + corner * dx, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + corner * dy), paint);
    }

    cornerLines(0, 0, top: true, left: true);
    cornerLines(w, 0, top: true, left: false);
    cornerLines(0, h, top: false, left: true);
    cornerLines(w, h, top: false, left: false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
