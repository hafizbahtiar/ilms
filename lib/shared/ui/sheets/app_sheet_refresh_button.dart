import 'package:flutter/material.dart';

/// Header refresh control for bottom sheets — rotates the refresh icon while
/// [isRefreshing] is true so users can see the action is in progress.
class AppSheetRefreshIconButton extends StatefulWidget {
  const AppSheetRefreshIconButton({
    super.key,
    required this.isRefreshing,
    required this.onPressed,
    this.tooltip = 'Refresh lookups',
  });

  final bool isRefreshing;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  State<AppSheetRefreshIconButton> createState() => _AppSheetRefreshIconButtonState();
}

class _AppSheetRefreshIconButtonState extends State<AppSheetRefreshIconButton> with SingleTickerProviderStateMixin {
  late final AnimationController _spinController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppSheetRefreshIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSpinAnimation();
  }

  @override
  void initState() {
    super.initState();
    _syncSpinAnimation();
  }

  void _syncSpinAnimation() {
    if (widget.isRefreshing) {
      if (!_spinController.isAnimating) {
        _spinController.repeat();
      }
    } else {
      _spinController
        ..stop()
        ..reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: widget.tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: widget.isRefreshing ? null : widget.onPressed,
      icon: RotationTransition(
        turns: _spinController,
        child: Icon(
          Icons.refresh_rounded,
          color: widget.isRefreshing ? cs.primary : cs.onSurface.withValues(alpha: 0.72),
        ),
      ),
    );
  }
}
