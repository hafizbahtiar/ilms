import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Resets a rotated map back to north-up. Only visible while rotation ≠ 0.
class AppMapRotationResetButton extends StatefulWidget {
  const AppMapRotationResetButton({
    super.key,
    required this.mapController,
    this.onReset,
  });

  final MapController mapController;
  final VoidCallback? onReset;

  @override
  State<AppMapRotationResetButton> createState() => _AppMapRotationResetButtonState();
}

class _AppMapRotationResetButtonState extends State<AppMapRotationResetButton> {
  StreamSubscription<MapEvent>? _mapEvents;
  var _isRotated = false;

  @override
  void initState() {
    super.initState();
    _mapEvents = widget.mapController.mapEventStream.listen(_syncRotation);
  }

  @override
  void didUpdateWidget(covariant AppMapRotationResetButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapController != widget.mapController) {
      unawaited(_mapEvents?.cancel());
      _mapEvents = widget.mapController.mapEventStream.listen(_syncRotation);
      setState(() => _isRotated = false);
    }
  }

  @override
  void dispose() {
    unawaited(_mapEvents?.cancel());
    super.dispose();
  }

  void _syncRotation(MapEvent event) {
    if (!mounted) return;
    final rotated = event.camera.rotation.abs() > 0.5;
    if (rotated != _isRotated) {
      setState(() => _isRotated = rotated);
    }
  }

  void _resetRotation() {
    try {
      widget.mapController.rotate(0);
      widget.onReset?.call();
    } on Exception {
      // Map not mounted yet — ignore.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRotated) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: 'Reset rotation',
        onPressed: _resetRotation,
        icon: Icon(Icons.explore_rounded, color: cs.primary),
      ),
    );
  }
}
