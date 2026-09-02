import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static const primaryFamily = 'Poppins';

  static TextTheme poppinsTextTheme(TextTheme base) => GoogleFonts.poppinsTextTheme(base);

  static String? get primaryFamilyName => GoogleFonts.poppins().fontFamily;
}
