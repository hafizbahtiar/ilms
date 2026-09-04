import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/media/app_image_source.dart';

/// Opens a fullscreen pinch-to-zoom image viewer with slide-to-dismiss.
///
/// [onRotate], when provided, shows a rotate button that rotates the image
/// currently on screen — used by the camera's capture review, where photos
/// are still local and mutable. Other callers (viewing already-uploaded
/// photos) simply omit it and get no rotate button.
Future<void> showAppImageViewer(
  BuildContext context, {
  required List<AppImageItem> images,
  int initialIndex = 0,
  Future<AppImageItem?> Function(int index)? onRotate,
}) {
  if (images.isEmpty) return Future<void>.value();

  final index = initialIndex.clamp(0, images.length - 1);

  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppImageViewerPage(images: images, initialIndex: index, onRotate: onRotate);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class AppImageViewerPage extends StatefulWidget {
  const AppImageViewerPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.onRotate,
  });

  final List<AppImageItem> images;
  final int initialIndex;
  final Future<AppImageItem?> Function(int index)? onRotate;

  @override
  State<AppImageViewerPage> createState() => _AppImageViewerPageState();
}

class _AppImageViewerPageState extends State<AppImageViewerPage> {
  late final ExtendedPageController _pageController;
  late List<AppImageItem> _images;
  late int _currentIndex;
  bool _showChrome = true;
  bool _rotating = false;

  @override
  void initState() {
    super.initState();
    _images = List.of(widget.images);
    _currentIndex = widget.initialIndex;
    _pageController = ExtendedPageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    clearGestureDetailsCache();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _rotate() async {
    final onRotate = widget.onRotate;
    if (onRotate == null || _rotating) return;

    setState(() => _rotating = true);
    final rotated = await onRotate(_currentIndex);
    if (!mounted) return;

    setState(() {
      _rotating = false;
      if (rotated != null) _images[_currentIndex] = rotated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;

    return ExtendedImageSlidePage(
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
      onSlidingPage: (state) {
        final shouldShow = !state.isSliding;
        if (shouldShow != _showChrome) {
          setState(() => _showChrome = shouldShow);
        }
      },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExtendedImageGesturePageView.builder(
              controller: _pageController,
              itemCount: images.length,
              physics: const BouncingScrollPhysics(),
              canScrollPage: (details) => (details?.totalScale ?? 1.0) <= 1.0,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return AppImageSource.extendedImage(
                  images[index],
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.gesture,
                  enableSlideOutPage: true,
                  gestureConfig: GestureConfig(
                    inPageView: true,
                    initialScale: 1,
                    minScale: 0.8,
                    maxScale: 4,
                    cacheGesture: false,
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showChrome ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(
                  ignoring: !_showChrome,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        children: [
                          _ChromeButton(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          if (images.length > 1) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${_currentIndex + 1} / ${images.length}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Spacer(),
                          ],
                          if (widget.onRotate != null)
                            _ChromeButton(
                              icon: Icons.rotate_right_rounded,
                              onTap: _rotate,
                              busy: _rotating,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChromeButton extends StatelessWidget {
  const _ChromeButton({required this.icon, required this.onTap, this.busy = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy ? null : onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
