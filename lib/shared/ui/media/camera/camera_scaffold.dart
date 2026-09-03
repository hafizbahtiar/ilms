import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ilms/shared/ui/media/camera/camera_gesture_overlay.dart';
import 'package:ilms/shared/ui/media/camera/camera_service.dart';
import 'package:ilms/shared/ui/media/camera/camera_status_view.dart';

/// Camera layout matching the legacy boxed preview: top chrome, a rounded
/// native-aspect preview card, optional capture strip, then shutter controls.
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
    required this.onCycleLens,
    this.captures = const [],
    this.canCaptureMore = true,
    this.onDone,
    this.onRemoveCapture,
    this.reviewScrollController,
    @visibleForTesting this.previewChild,
  });

  static const previewCardKey = Key('cameraPreviewCard');

  final AppCameraService service;
  final bool isProcessing;
  final List<File> captures;
  final bool canCaptureMore;
  final VoidCallback onCapture;
  final VoidCallback onClose;
  final VoidCallback? onDone;
  final ValueChanged<int>? onRemoveCapture;
  final ScrollController? reviewScrollController;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final VoidCallback onSwitchCamera;
  final VoidCallback onCycleLens;

  /// Skips native [CameraPreview] so widget tests can drive gestures.
  @visibleForTesting
  final Widget? previewChild;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: service.isInitialized
            ? Column(
                children: [
                  _TopBar(
                    onClose: onClose,
                    service: service,
                    captureCount: captures.length,
                    onDone: onDone,
                  ),
                  Expanded(child: _previewCard()),
                  if (captures.isNotEmpty)
                    _CaptureReviewStrip(
                      captures: captures,
                      scrollController: reviewScrollController,
                      onRemove: onRemoveCapture,
                    ),
                  _BottomControls(
                    busy: isProcessing,
                    canSwitchCamera: service.canSwitchCamera,
                    canCycleLens:
                        service.hasMultipleBackLenses &&
                        !service.isUsingFrontCamera,
                    canCaptureMore: canCaptureMore,
                    onCapture: onCapture,
                    onSwitchCamera: onSwitchCamera,
                    onCycleLens: onCycleLens,
                  ),
                ],
              )
            : Center(
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

  Widget _previewCard() {
    final controller = service.controller;
    final preview =
        previewChild ??
        (controller != null && controller.value.isInitialized
            ? CameraPreview(controller)
            : const ColoredBox(color: Colors.black));

    if (controller == null || !controller.value.isInitialized) {
      return _boxedPreview(aspect: 3 / 4, child: preview);
    }

    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final ratio = value.aspectRatio;
        return _boxedPreview(
          aspect: ratio == 0 ? 3 / 4 : 1 / ratio,
          child: preview,
        );
      },
    );
  }

  Widget _boxedPreview({required double aspect, required Widget child}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AspectRatio(
          key: previewCardKey,
          aspectRatio: aspect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CameraGestureOverlay(service: service, child: child),
          ),
        ),
      ),
    );
  }
}

class _CaptureReviewStrip extends StatelessWidget {
  const _CaptureReviewStrip({
    required this.captures,
    this.scrollController,
    this.onRemove,
  });

  final List<File> captures;
  final ScrollController? scrollController;
  final ValueChanged<int>? onRemove;

  static const _thumbSize = 84.0;
  static const _removeButtonOverflow = 8.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${captures.length} photo${captures.length == 1 ? '' : 's'} captured',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (captures.length > 3) ...[
            const SizedBox(height: 4),
            Text(
              'Swipe to review all',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: Colors.white60),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: _thumbSize + _removeButtonOverflow,
            child: ListView.separated(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                _removeButtonOverflow,
                16,
                0,
              ),
              itemCount: captures.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _CaptureThumb(
                  file: captures[index],
                  index: index,
                  size: _thumbSize,
                  onRemove: onRemove == null ? null : () => onRemove!(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureThumb extends StatelessWidget {
  const _CaptureThumb({
    required this.file,
    required this.index,
    required this.size,
    this.onRemove,
  });

  final File file;
  final int index;
  final double size;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: -6,
              right: -6,
              child: Material(
                color: Colors.black.withValues(alpha: 0.72),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onRemove,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatefulWidget {
  const _TopBar({
    required this.onClose,
    required this.service,
    required this.captureCount,
    this.onDone,
  });

  final VoidCallback onClose;
  final AppCameraService service;
  final int captureCount;
  final VoidCallback? onDone;

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _CameraGlassButton(icon: Icons.close_rounded, onTap: widget.onClose),
          const Spacer(),
          _FlashToggle(
            service: widget.service,
            onChanged: () => setState(() {}),
          ),
          if (widget.onDone != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: widget.onDone,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: const Color(0xFFFFE600),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                'Done (${widget.captureCount})',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.busy,
    required this.canSwitchCamera,
    required this.canCycleLens,
    required this.canCaptureMore,
    required this.onCapture,
    required this.onSwitchCamera,
    required this.onCycleLens,
  });

  final bool busy;
  final bool canSwitchCamera;
  final bool canCycleLens;
  final bool canCaptureMore;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;
  final VoidCallback onCycleLens;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        child: Row(
          children: [
            Expanded(
              child: canSwitchCamera
                  ? _CameraGlassButton(
                      icon: Icons.cameraswitch_rounded,
                      onTap: busy || !canCaptureMore ? () {} : onSwitchCamera,
                      label: 'Flip',
                    )
                  : const SizedBox(width: 46),
            ),
            _CameraShutterButton(
              busy: busy || !canCaptureMore,
              onTap: onCapture,
            ),
            Expanded(
              child: canCycleLens
                  ? _CameraGlassButton(
                      icon: Icons.crop_free_rounded,
                      onTap: busy || !canCaptureMore ? () {} : onCycleLens,
                      label: 'Lens',
                    )
                  : const SizedBox(width: 46),
            ),
          ],
        ),
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
  const _CameraGlassButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.label,
  });

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
              color: active
                  ? const Color(0xFFFFE600)
                  : Colors.black.withValues(alpha: 0.38),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Icon(
              icon,
              color: active ? Colors.black : Colors.white,
              size: _size * 0.48,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
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
  static const double _size = 74;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.busy ? null : (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.busy ? null : widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.86 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: widget.busy ? 0.5 : 1,
                    ),
                    width: 3,
                  ),
                ),
              ),
              Container(
                width: _size - 14,
                height: _size - 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.busy ? Colors.white38 : Colors.white,
                ),
              ),
              if (widget.busy)
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
