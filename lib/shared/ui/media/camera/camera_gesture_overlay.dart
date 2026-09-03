import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ilms/shared/ui/media/camera/camera_service.dart';

/// Wraps the camera preview and provides the standard phone-camera gestures:
///
///  * Pinch to zoom (two fingers), with a transient zoom pill.
///  * Tap to focus -> draws a focus box at the tap point.
///  * A brightness (exposure) slider that appears beside the focus box; drag
///    the handle up/down to brighten/darken, just like the stock camera.
///
/// All camera calls go through [AppCameraService], which coalesces them so
/// fast gestures never flood the native camera.
class CameraGestureOverlay extends StatefulWidget {
  const CameraGestureOverlay({
    super.key,
    required this.service,
    required this.child,
  });

  final AppCameraService service;
  final Widget child;

  @override
  State<CameraGestureOverlay> createState() => _CameraGestureOverlayState();
}

class _CameraGestureOverlayState extends State<CameraGestureOverlay> {
  static const double _boxSize = 80;
  static const double _sliderWidth = 34;
  static const double _sliderHeight = 170;
  static const double _gap = 10;
  static const Duration _autoHide = Duration(seconds: 3);
  static const Color _accent = Color(0xFFFFE600);

  AppCameraService get _service => widget.service;

  Offset? _focusPoint;
  bool _showFocusUi = false;
  Timer? _focusHideTimer;

  // UI-only exposure value, kept continuous so the handle slides smoothly
  // instead of snapping to the device's integer EV steps.
  double _exposureValue = 0.0;

  bool _showZoom = false;
  double _baseZoom = 1.0;
  Timer? _zoomHideTimer;

  @override
  void initState() {
    super.initState();
    _exposureValue = _service.exposureOffset;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = _service.zoom;
    if (details.pointerCount >= 2) _hideFocusUi();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    // Only treat genuine two-finger gestures as zoom. Single-finger pans also
    // arrive here with scale == 1.0; forwarding those floods the camera with
    // redundant setZoomLevel(1.0) calls.
    if (details.pointerCount < 2) return;

    _focusHideTimer?.cancel();
    _service.setZoom(_baseZoom * details.scale);
    setState(() {
      _showFocusUi = false;
      _focusPoint = null;
      _showZoom = true;
    });

    _zoomHideTimer?.cancel();
    _zoomHideTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showZoom = false);
    });
  }

  void _onTapUp(TapUpDetails details, Size size) {
    final local = details.localPosition;
    _service.focusOnPoint(
      Offset(
        (local.dx / size.width).clamp(0.0, 1.0),
        (local.dy / size.height).clamp(0.0, 1.0),
      ),
    );
    setState(() {
      _focusPoint = local;
      _showFocusUi = true;
    });
    _restartFocusHide();
  }

  void _hideFocusUi() {
    _focusHideTimer?.cancel();
    if (!mounted || (!_showFocusUi && _focusPoint == null)) return;
    setState(() {
      _showFocusUi = false;
      _focusPoint = null;
    });
  }

  void _onExposureDrag(double dy) {
    if (!_service.supportsExposureControl) return;
    final min = _service.minExposureOffset;
    final max = _service.maxExposureOffset;
    final range = max - min;
    if (range <= 0) return;

    // Drag up => brighter. The full slider travel covers the whole EV range.
    final next = (_exposureValue - dy / _sliderHeight * range).clamp(min, max);
    _service.setExposureOffset(next);
    setState(() => _exposureValue = next);
    _restartFocusHide();
  }

  void _restartFocusHide() {
    _focusHideTimer?.cancel();
    _focusHideTimer = Timer(_autoHide, () {
      if (mounted) _hideFocusUi();
    });
  }

  @override
  void dispose() {
    _focusHideTimer?.cancel();
    _zoomHideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onTapUp: (details) => _onTapUp(details, size),
          child: Stack(
            alignment: Alignment.center,
            children: [
              widget.child,
              if (_showZoom) _ZoomIndicator(zoom: _service.zoom),
              if (_showFocusUi && _focusPoint != null) _buildFocusOverlay(size),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFocusOverlay(Size size) {
    final hasExposure = _service.supportsExposureControl;
    // The cluster is the focus box plus (optionally) the brightness slider to
    // its right, vertically centered on each other. Clamp the anchor so the
    // whole cluster stays on-screen.
    final clusterWidth = _boxSize + (hasExposure ? _gap + _sliderWidth : 0);
    final clusterHeight = hasExposure ? _sliderHeight : _boxSize;

    final cx = _focusPoint!.dx.clamp(
      clusterWidth / 2,
      size.width - clusterWidth / 2,
    );
    final cy = _focusPoint!.dy.clamp(
      clusterHeight / 2,
      size.height - clusterHeight / 2,
    );

    return Positioned(
      left: cx - clusterWidth / 2,
      top: cy - clusterHeight / 2,
      child: AnimatedOpacity(
        opacity: _showFocusUi ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _FocusBox(size: _boxSize),
            if (hasExposure) ...[
              const SizedBox(width: _gap),
              _ExposureSlider(
                width: _sliderWidth,
                height: _sliderHeight,
                min: _service.minExposureOffset,
                max: _service.maxExposureOffset,
                value: _exposureValue,
                onDragDelta: _onExposureDrag,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ZoomIndicator extends StatelessWidget {
  const _ZoomIndicator({required this.zoom});

  final double zoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${zoom.toStringAsFixed(1)}x',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _FocusBox extends StatefulWidget {
  const _FocusBox({required this.size});

  final double size;

  @override
  State<_FocusBox> createState() => _FocusBoxState();
}

class _FocusBoxState extends State<_FocusBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..forward();

  late final Animation<double> _scale = Tween<double>(
    begin: 1.35,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          border: Border.all(
            color: _CameraGestureOverlayState._accent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _ExposureSlider extends StatelessWidget {
  const _ExposureSlider({
    required this.width,
    required this.height,
    required this.min,
    required this.max,
    required this.value,
    required this.onDragDelta,
  });

  final double width;
  final double height;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onDragDelta;

  static const double _handleSize = 26;

  @override
  Widget build(BuildContext context) {
    final fraction = max > min
        ? ((value - min) / (max - min)).clamp(0.0, 1.0)
        : 0.5;
    final travel = height - _handleSize;
    final handleTop = (1 - fraction) * travel; // top = brighter

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (d) => onDragDelta(d.delta.dy),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 2,
                height: height,
                color: _CameraGestureOverlayState._accent.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
            Positioned(
              top: handleTop,
              left: (width - _handleSize) / 2,
              child: Container(
                width: _handleSize,
                height: _handleSize,
                decoration: const BoxDecoration(
                  color: _CameraGestureOverlayState._accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
