import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/app_typography.dart';

void main() {
  test('textTheme defines core Material roles with expected sizes', () {
    final theme = AppTypography.textTheme(brightness: Brightness.light, onSurface: const Color(0xFF111827));

    expect(theme.titleLarge?.fontSize, 20);
    expect(theme.titleLarge?.fontWeight, FontWeight.w700);
    expect(theme.bodyMedium?.fontSize, 14);
    expect(theme.labelSmall?.fontSize, 11);
  });

  test('textTheme scales font sizes with the provided factor', () {
    final theme = AppTypography.textTheme(
      brightness: Brightness.light,
      onSurface: const Color(0xFF111827),
      scale: 1.15,
    );

    expect(theme.titleLarge?.fontSize, closeTo(20 * 1.15, 0.001));
    expect(theme.bodyMedium?.fontSize, closeTo(14 * 1.15, 0.001));
  });
}
