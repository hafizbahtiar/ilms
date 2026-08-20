import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ilms/shared/ui/media/camera/camera_service.dart';
import 'package:ilms/shared/ui/media/camera/camera_status_view.dart';

/// Full-screen camera layout with edge-to-edge preview and overlay controls.
class CameraScaffold extends StatelessWidget {
  const CameraScaffold({
    super.key,
    required this.service,
    required this.isProcessing,
    required this.onCapture,
    required this.onClose,
    required this.onRetry,
    required this.onOpenSettings,
    required this.onSwitchCamera,
  });

  final AppCameraService service;
  final bool isProcessing;
  final VoidCallback onCapture;
  final VoidCallback onClose;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final VoidCallback onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: service.isInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                _CameraPreviewFill(controller: service.controller!),
                const _ViewfinderOverlay(),
                const _GradientOverlay(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0, 0.22]),
                const _GradientOverlay(begin: Alignment.bottomCenter, end: Alignment.topCenter, stops: [0, 0.34]),
                SafeArea(
                  child: Column(
                    children: [
                      _TopBar(onClose: onClose, service: service),
                      const Spacer(),
                      _BottomControls(
                        busy: isProcessing,
                        canSwitchCamera: service.canSwitchCamera,
                        onCapture: onCapture,
                        onSwitchCamera: onSwitchCamera,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : SafeArea(
              child: Center(
                child: CameraStatusView(
                  status: service.status,
                  message: service.errorMessage,
                  onRetry: onRetry,
                  onOpenSettings: onOpenSettings,
                  onClose: onClose,
                ),
              ),
            ),
    );
  }
}

class _CameraPreviewFill extends StatelessWidget {
  const _CameraPreviewFill({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewRatio = controller.value.aspectRatio;
        if (previewRatio == 0) {
          return Center(child: CameraPreview(controller));
        }

        final screenRatio = constraints.maxWidth / constraints.maxHeight;
        var scale = screenRatio / previewRatio;
        if (scale < 1) scale = 1 / scale;

        return ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: AspectRatio(aspectRatio: previewRatio, child: CameraPreview(controller)),
            ),
          ),
        );
      },
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
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          stops: stops,
          colors: [Colors.black.withValues(alpha: 0.72), Colors.transparent],
        ),
      ),
    );
  }
}

class _ViewfinderOverlay extends StatelessWidget {
  const _ViewfinderOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 96),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: CustomPaint(painter: _ViewfinderPainter(color: Colors.white.withValues(alpha: 0.55))),
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
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const corner = 22.0;
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

class _TopBar extends StatefulWidget {
  const _TopBar({required this.onClose, required this.service});

  final VoidCallback onClose;
  final AppCameraService service;

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          _CameraGlassButton(icon: Icons.close_rounded, onTap: widget.onClose),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Capture Photo',
                  style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text('Align the subject within the frame', style: textTheme.bodySmall?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          _FlashToggle(service: widget.service, onChanged: () => setState(() {})),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.busy,
    required this.canSwitchCamera,
    required this.onCapture,
    required this.onSwitchCamera,
  });

  final bool busy;
  final bool canSwitchCamera;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: canSwitchCamera
                    ? _CameraGlassButton(
                        icon: Icons.cameraswitch_rounded,
                        onTap: busy ? () {} : onSwitchCamera,
                        label: 'Flip',
                      )
                    : const SizedBox(width: 46),
              ),
              _CameraShutterButton(busy: busy, onTap: onCapture),
              const Expanded(child: SizedBox(width: 46)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            busy ? 'Saving photo…' : 'Tap to capture',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: Colors.white.withValues(alpha: 0.82), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FlashToggle extends StatelessWidget {
  const _FlashToggle({required this.service, required this.onChanged});

  final AppCameraService service;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final mode = service.flashMode;
    final active = mode != FlashMode.off;
    final icon = switch (mode) {
      FlashMode.torch => Icons.flash_on_rounded,
      FlashMode.auto => Icons.flash_auto_rounded,
      _ => Icons.flash_off_rounded,
    };

    return _CameraGlassButton(
      icon: icon,
      active: active,
      onTap: () async {
        await service.cycleFlashMode();
        onChanged();
      },
    );
  }
}

class _CameraGlassButton extends StatelessWidget {
  const _CameraGlassButton({required this.icon, required this.onTap, this.active = false, this.label});

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final String? label;
  static const double _size = 46;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _CameraShutterButton extends StatefulWidget {
  const _CameraShutterButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  State<_CameraShutterButton> createState() => _CameraShutterButtonState();
}

class _CameraShutterButtonState extends State<_CameraShutterButton> {
  static const double _size = 78;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.busy ? null : (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.busy ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 4),
                ),
              ),
              Container(
                width: _size - 16,
                height: _size - 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.busy ? Colors.white38 : Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
              ),
              if (widget.busy) const SizedBox(width: 28, height: 28, child: CircularProgressIndicator.adaptive()),
            ],
          ),
        ),
      ),
    );
  }
}
