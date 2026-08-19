import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF001871);
  static const yellow = Color(0xFFFFE600);
  static const _ink = Color(0xFF111827);
  static const _lightSurface = Color(0xFFF7F9FD);
  static const _lightBackground = Color(0xFFF3F5FB);
  static const _darkSurface = Color(0xFF0C1430);
  static const _darkBackground = Color(0xFF081022);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final onSurface = isLight ? _ink : const Color(0xFFF3F5FB);
    final surface = isLight ? _lightSurface : _darkSurface;
    final background = isLight ? _lightBackground : _darkBackground;
    final cardColor = isLight ? Colors.white : const Color(0xFF111A3A);
    final outline = isLight ? const Color(0xFF9AA4C2) : const Color(0xFF4B5678);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: navy,
      onPrimary: Colors.white,
      primaryContainer: isLight ? const Color(0xFFD6DEFF) : const Color(0xFF1A2A6B),
      onPrimaryContainer: isLight ? navy : Colors.white,
      secondary: yellow,
      onSecondary: Colors.black,
      secondaryContainer: isLight ? const Color(0xFFFFF6B0) : const Color(0xFF4A4300),
      onSecondaryContainer: isLight ? _ink : yellow,
      error: isLight ? const Color(0xFFB3261E) : const Color(0xFFF2B8B5),
      onError: isLight ? Colors.white : const Color(0xFF601410),
      surface: surface,
      onSurface: onSurface,
      outline: outline,
      outlineVariant: isLight ? const Color(0xFFD5DBEA) : const Color(0xFF2A3458),
    );

    final radius = BorderRadius.circular(14);
    final buttonShape = RoundedRectangleBorder(borderRadius: radius);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      splashColor: yellow.withValues(alpha: 0.16),
      highlightColor: navy.withValues(alpha: 0.08),
      dividerColor: colorScheme.outlineVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? navy : _darkSurface,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: outline,
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: buttonShape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(48),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          side: const BorderSide(color: navy, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: navy, shape: buttonShape),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: yellow,
        foregroundColor: Colors.black,
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
          borderSide: const BorderSide(color: navy, width: 1.8),
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
          if (states.contains(WidgetState.selected)) return navy;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: outline, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return navy;
          return outline;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return yellow;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return navy;
          return outline;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? const Color(0xFFE8EDFF) : const Color(0xFF1A2A6B),
        selectedColor: yellow,
        labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: yellow,
        labelTextStyle: WidgetStatePropertyAll(TextStyle(color: onSurface, fontWeight: FontWeight.w600)),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.black);
          }
          return IconThemeData(color: onSurface);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: navy,
        unselectedItemColor: outline,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navy,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: yellow,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: navy),
      iconTheme: IconThemeData(color: onSurface),
    );
  }
}
