import 'package:flutter/material.dart';
import 'package:ilms/shared/ui/media/camera/camera_status.dart';

/// Placeholder while the camera is loading, denied, or errored.
class CameraStatusView extends StatelessWidget {
  const CameraStatusView({
    super.key,
    required this.status,
    required this.onRetry,
    required this.onOpenSettings,
    required this.onClose,
    this.message,
  });

  final CameraStatus status;
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if (status == CameraStatus.uninitialized || status == CameraStatus.initializing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 52, height: 52, child: CircularProgressIndicator.adaptive()),
            const SizedBox(height: 18),
            Text(
              status == CameraStatus.initializing ? 'Starting camera…' : 'Preparing camera…',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 15),
            ),
          ],
        ),
      );
    }

    final (icon, title, body, actionLabel, action) = switch (status) {
      CameraStatus.permissionDenied => (
        Icons.no_photography_rounded,
        'Camera access required',
        'Allow camera access to take photos.',
        'Allow',
        onRetry,
      ),
      CameraStatus.permissionDeniedForever => (
        Icons.no_photography_rounded,
        'Camera access blocked',
        'Camera access is blocked. Open settings to enable it.',
        'Open Settings',
        onOpenSettings,
      ),
      _ => (
        Icons.error_outline_rounded,
        'Camera unavailable',
        message ?? 'Something went wrong while starting the camera.',
        'Try Again',
        onRetry,
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 56),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: action, child: Text(actionLabel)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onClose,
              child: const Text('Close', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
