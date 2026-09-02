import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme textTheme({required Brightness brightness, required Color onSurface, double scale = 1.0}) {
    final muted = onSurface.withValues(alpha: 0.7);

    TextStyle style({required double fontSize, required FontWeight fontWeight, Color? color}) {
      return TextStyle(fontSize: fontSize * scale, fontWeight: fontWeight, color: color ?? onSurface);
    }

    return TextTheme(
      displaySmall: style(fontSize: 32, fontWeight: FontWeight.w700),
      headlineSmall: style(fontSize: 24, fontWeight: FontWeight.w700),
      titleLarge: style(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: style(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: style(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: style(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: style(fontSize: 12, fontWeight: FontWeight.w400, color: muted),
      labelLarge: style(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: style(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: style(fontSize: 11, fontWeight: FontWeight.w500, color: muted),
    );
  }
}
