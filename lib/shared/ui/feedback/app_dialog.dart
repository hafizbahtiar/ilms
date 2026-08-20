import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoAlertDialog, CupertinoDialogAction;
import 'package:flutter/material.dart';

enum AppDialogActionStyle { text, filled, destructive }

class AppDialogAction<T> {
  const AppDialogAction(
    this.label, {
    this.value,
    this.style = AppDialogActionStyle.text,
    this.autoPop = true,
    this.onPressed,
  });

  final String label;
  final T? value;
  final AppDialogActionStyle style;
  final bool autoPop;
  final FutureOr<void> Function()? onPressed;
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  Widget? icon,
  List<AppDialogAction<T>> actions = const [],
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  final platform = Theme.of(context).platform;
  final isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  return showAdaptiveDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      final dialogContent = _buildContent(message, content);

      if (isCupertino) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: dialogContent,
          actions: _buildCupertinoActions(context, actions),
        );
      }

      return AlertDialog(
        icon: icon,
        title: Text(title),
        content: dialogContent,
        actions: _buildMaterialActions(context, actions),
      );
    },
  );
}

Future<bool> confirmAppDialog({
  required BuildContext context,
  required String title,
  String? message,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Confirm',
  AppDialogActionStyle confirmStyle = AppDialogActionStyle.filled,
  bool barrierDismissible = true,
}) async {
  final confirmed = await showAppDialog<bool>(
    context: context,
    title: title,
    message: message,
    barrierDismissible: barrierDismissible,
    actions: [
      AppDialogAction(cancelLabel, value: false),
      AppDialogAction(confirmLabel, value: true, style: confirmStyle),
    ],
  );
  return confirmed ?? false;
}

Widget? _buildContent(String? message, Widget? content) {
  if (content != null) return content;
  if (message == null) return null;
  return Text(message);
}

List<Widget> _buildMaterialActions<T>(BuildContext context, List<AppDialogAction<T>> actions) {
  final colorScheme = Theme.of(context).colorScheme;

  return [
    for (final action in actions)
      switch (action.style) {
        AppDialogActionStyle.filled => FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: () => _handleAction(context, action),
          child: Text(action.label),
        ),
        AppDialogActionStyle.destructive => TextButton(
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          onPressed: () => _handleAction(context, action),
          child: Text(action.label),
        ),
        AppDialogActionStyle.text => TextButton(
          onPressed: () => _handleAction(context, action),
          child: Text(action.label),
        ),
      },
  ];
}

List<Widget> _buildCupertinoActions<T>(BuildContext context, List<AppDialogAction<T>> actions) {
  return [
    for (final action in actions)
      CupertinoDialogAction(
        isDefaultAction: action.style == AppDialogActionStyle.filled,
        isDestructiveAction: action.style == AppDialogActionStyle.destructive,
        onPressed: () => _handleAction(context, action),
        child: Text(action.label),
      ),
  ];
}

Future<void> _handleAction<T>(BuildContext context, AppDialogAction<T> action) async {
  if (action.autoPop) {
    Navigator.of(context, rootNavigator: true).pop<T>(action.value);
  }

  final callback = action.onPressed;
  if (callback != null) {
    await callback();
  }
}
