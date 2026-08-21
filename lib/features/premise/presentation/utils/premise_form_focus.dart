import 'package:flutter/material.dart';

/// Clears keyboard / field focus after a premise form sheet or dialog closes.
void unfocusPremiseForm(BuildContext context) {
  if (!context.mounted) return;
  FocusManager.instance.primaryFocus?.unfocus();
  FocusScope.of(context).unfocus();
}

extension PremiseFormSheetFuture<T extends Object?> on Future<T> {
  /// Unfocuses any active field once this sheet future completes (pop or dismiss).
  Future<T> unfocusPremiseFormOnComplete(BuildContext context) {
    return whenComplete(() => unfocusPremiseForm(context));
  }
}
