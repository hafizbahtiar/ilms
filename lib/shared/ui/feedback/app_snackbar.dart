import 'package:flutter/material.dart';

enum AppSnackbarType { info, success, warning, error }

class AppSnackbar {
  AppSnackbar._();

  /// Global toggle: set to `false` to switch every snackbar to fixed (non-floating).
  static bool useFloating = true;

  static void show(
    BuildContext context,
    String message, {
    AppSnackbarType type = AppSnackbarType.info,
    bool? floating,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFromMessenger(
      ScaffoldMessenger.of(context),
      message,
      type: type,
      floating: floating,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void showFromMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    AppSnackbarType type = AppSnackbarType.info,
    bool? floating,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFromMessenger(
      messenger,
      message,
      type: type,
      floating: floating,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    bool? floating,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFromMessenger(
      ScaffoldMessenger.of(context),
      message,
      type: AppSnackbarType.info,
      floating: floating,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void success(
    BuildContext context,
    String message, {
    bool? floating,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFromMessenger(
      ScaffoldMessenger.of(context),
      message,
      type: AppSnackbarType.success,
      floating: floating,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void successFromMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    bool? floating,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFromMessenger(
      messenger,
      message,
      type: AppSnackbarType.success,
      floating: floating,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    bool? floating,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFromMessenger(
      ScaffoldMessenger.of(context),
      message,
      type: AppSnackbarType.warning,
      floating: floating,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    bool? floating,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFromMessenger(
      ScaffoldMessenger.of(context),
      message,
      type: AppSnackbarType.error,
      floating: floating,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void errorFromMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    bool? floating,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showFromMessenger(
      messenger,
      message,
      type: AppSnackbarType.error,
      floating: floating,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void _showFromMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    required AppSnackbarType type,
    bool? floating,
    String? actionLabel,
    VoidCallback? onAction,
    required Duration duration,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: (floating ?? useFloating) ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
          backgroundColor: _background(messenger.context, type),
          duration: duration,
          action: actionLabel == null ? null : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
        ),
      );
  }

  static Color _background(BuildContext context, AppSnackbarType type) {
    final theme = Theme.of(context);
    switch (type) {
      case AppSnackbarType.info:
        return theme.snackBarTheme.backgroundColor ?? theme.colorScheme.inverseSurface;
      case AppSnackbarType.success:
        return const Color(0xFF2E7D32);
      case AppSnackbarType.warning:
        return const Color(0xFFB26A00);
      case AppSnackbarType.error:
        return theme.colorScheme.error;
    }
  }
}
