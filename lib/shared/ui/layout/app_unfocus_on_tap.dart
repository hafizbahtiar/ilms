import 'package:flutter/material.dart';

/// Dismisses the current field's focus (and its keyboard) when the user taps
/// anywhere within [child] that isn't already handled by a more specific
/// gesture — e.g. tapping empty space on a form page. Mirrors legacy forms'
/// tap-outside-to-unfocus behavior.
class AppUnfocusOnTap extends StatelessWidget {
  const AppUnfocusOnTap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
