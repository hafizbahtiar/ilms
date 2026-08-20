import 'package:flutter/services.dart';

/// Uppercases every character as the user types (legacy premise forms default).
class UppercaseTextFormatter extends TextInputFormatter {
  const UppercaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
