import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'app_typography.dart';

class AppTheme {
  static const navy = Color(0xFF001871);
  static const yellow = Color(0xFFFFE600);
  static const success = Color(0xFF2E7D32);
  static const successDark = Color(0xFF66BB6A);
  static const onSuccessLight = Colors.white;
  static const onSuccessDark = Color(0xFF0D2B14);
  static const _ink = Color(0xFF111827);
  static const _lightSurface = Color(0xFFF7F9FD);
  static const _lightBackground = Color(0xFFF3F5FB);

  /// Cool charcoal — night sky, not a navy-painted room.
  static const _night = Color(0xFF12151C);
  static const _panel = Color(0xFF181C26);
  static const _plate = Color(0xFF252A38);
  static const _tile = Color(0xFF333A4C);
  static const _ridge = Color(0xFF3C4458);
  static const _hairline = Color(0xFF4A5266);
  static const _mist = Color(0xFFE8EBF2);

  static ThemeData get light => lightFor();

  static ThemeData get dark => darkFor();

  static ThemeData lightFor({double textScale = 1.0}) => _build(Brightness.light, textScale: textScale);

  static ThemeData darkFor({double textScale = 1.0}) => _build(Brightness.dark, textScale: textScale);

  static ThemeData _build(Brightness brightness, {double textScale = 1.0}) {
    final isLight = brightness == Brightness.light;
    final onSurface = isLight ? _ink : _mist;
    final surface = isLight ? _lightSurface : _panel;
    final background = isLight ? _lightBackground : _night;
    final cardColor = isLight ? Colors.white : _plate;
    final outline = isLight ? const Color(0xFF9AA4C2) : const Color(0xFF8B93A5);
    // 60/30/10: charcoal carries the UI, navy is the banner, yellow is the lamp.
    final interactive = isLight ? navy : yellow;
    final onInteractive = isLight ? Colors.white : Colors.black;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: navy,
      onPrimary: Colors.white,
      primaryContainer: isLight ? const Color(0xFFD6DEFF) : const Color(0xFF1E2A44),
      onPrimaryContainer: isLight ? navy : _mist,
      secondary: yellow,
      onSecondary: Colors.black,
      secondaryContainer: isLight ? const Color(0xFFFFF6B0) : const Color(0xFF3D3800),
      onSecondaryContainer: isLight ? _ink : yellow,
      tertiary: isLight ? success : successDark,
      onTertiary: isLight ? onSuccessLight : onSuccessDark,
      tertiaryContainer: isLight ? const Color(0xFFC8E6C9) : const Color(0xFF1B5E20),
      onTertiaryContainer: isLight ? const Color(0xFF1B5E20) : const Color(0xFFC8E6C9),
      error: isLight ? const Color(0xFFB3261E) : const Color(0xFFF2B8B5),
      onError: isLight ? Colors.white : const Color(0xFF601410),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: background,
      surfaceContainerLow: isLight ? const Color(0xFFEEF2F8) : const Color(0xFF1E232E),
      surfaceContainer: isLight ? _lightSurface : cardColor,
      surfaceContainerHigh: isLight ? Colors.white : _tile,
      surfaceContainerHighest: isLight ? Colors.white : _ridge,
      outline: outline,
      outlineVariant: isLight ? const Color(0xFFD5DBEA) : _hairline,
    );

    final radius = BorderRadius.circular(14);
    final buttonShape = RoundedRectangleBorder(borderRadius: radius);
    final appBarForeground = isLight ? colorScheme.onPrimary : onSurface;
    final textTheme = AppFonts.poppinsTextTheme(
      AppTypography.textTheme(brightness: brightness, onSurface: onSurface, scale: textScale),
    );
    final fontFamily = AppFonts.primaryFamilyName;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: background,
      splashColor: yellow.withValues(alpha: 0.16),
      highlightColor: interactive.withValues(alpha: 0.12),
      dividerColor: colorScheme.outlineVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? navy : _panel,
        foregroundColor: appBarForeground,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: appBarForeground),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: appBarForeground),
        toolbarTextStyle: textTheme.titleMedium?.copyWith(color: appBarForeground),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: interactive,
          foregroundColor: onInteractive,
          disabledBackgroundColor: outline,
          disabledForegroundColor: onSurface.withValues(alpha: 0.38),
          minimumSize: const Size.fromHeight(48),
          shape: buttonShape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: colorScheme.onSecondary,
          minimumSize: const Size.fromHeight(48),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: interactive,
          side: BorderSide(color: interactive, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: interactive, shape: buttonShape),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: yellow,
        foregroundColor: colorScheme.onSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.5)),
        labelStyle: TextStyle(color: onSurface.withValues(alpha: 0.8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: interactive, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.error, width: 1.8),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return interactive;
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(onInteractive),
        side: BorderSide(color: outline, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return interactive;
          return outline;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isLight ? yellow : navy;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isLight ? navy : yellow;
          }
          return outline;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? const Color(0xFFE8EDFF) : _tile,
        selectedColor: yellow,
        labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        secondaryLabelStyle: TextStyle(color: colorScheme.onSecondary, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: yellow,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(color: onSurface, fontWeight: FontWeight.w600)),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onSecondary);
          }
          return IconThemeData(color: onSurface);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: interactive,
        unselectedItemColor: outline,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navy,
        contentTextStyle: TextStyle(color: colorScheme.onPrimary),
        actionTextColor: yellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: interactive),
      iconTheme: IconThemeData(color: onSurface),
    );
  }
}
