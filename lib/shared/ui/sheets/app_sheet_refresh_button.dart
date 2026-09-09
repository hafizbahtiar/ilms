import 'package:flutter/material.dart';

/// Header refresh control for bottom sheets — rotates the refresh icon while
/// the refresh callback is running so users can see the action is in progress.
class AppSheetRefreshIconButton extends StatefulWidget {
  const AppSheetRefreshIconButton({super.key, required this.onRefresh, this.tooltip = 'Refresh lookups'});

  final Future<void> Function() onRefresh;
  final String tooltip;

  @override
  State<AppSheetRefreshIconButton> createState() => _AppSheetRefreshIconButtonState();
}

class _AppSheetRefreshIconButtonState extends State<AppSheetRefreshIconButton> with SingleTickerProviderStateMixin {
  var _isRefreshing = false;

  late final AnimationController _spinController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _spinController.repeat();
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
        _spinController
          ..stop()
          ..reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: widget.tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: _isRefreshing ? null : _refresh,
      icon: RotationTransition(
        turns: _spinController,
        child: Icon(Icons.refresh_rounded, color: _isRefreshing ? cs.primary : cs.onSurface.withValues(alpha: 0.72)),
      ),
    );
  }
}
