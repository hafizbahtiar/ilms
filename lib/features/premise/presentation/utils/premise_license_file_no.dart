import 'package:flutter/services.dart';

/// Legacy parity for premise license file numbers (`DBKL.JPPP/#####/##/####/####`).
abstract final class PremiseLicenseFileNo {
  static const prefix = 'DBKL.JPPP/';
  static const hint = 'XXXXX / XX / XXXX / XXXX';
  static const maskedLength = 18;

  static String removePrefix(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.startsWith(prefix)) return value.substring(prefix.length);
    return value;
  }

  static String formatForSubmit(String? value) {
    if (value == null || value.isEmpty) return '';
    final trimmed = value.replaceAll(' ', '');
    if (trimmed.startsWith(prefix)) return trimmed;
    return '$prefix$trimmed';
  }

  static String display(String? value) {
    final formatted = formatForSubmit(value);
    return formatted.isEmpty ? '-' : formatted;
  }

  static String? validateMasked(String? value) {
    if (value == null || value.trim().isEmpty) return 'File no is required';
    if (value.length != maskedLength) return 'File no is invalid';
    return null;
  }

  static String _sanitize(String input) {
    return input.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').toUpperCase();
  }

  static String _applyMask(String raw) {
    const segments = [5, 2, 4, 4];
    final buffer = StringBuffer();
    var index = 0;

    for (final length in segments) {
      if (index >= raw.length) break;
      if (buffer.isNotEmpty) buffer.write('/');
      final end = (index + length).clamp(0, raw.length);
      buffer.write(raw.substring(index, end));
      index += length;
    }

    return buffer.toString();
  }

  static TextEditingValue maskValue(String input, {TextSelection? selection}) {
    final raw = _sanitize(input);
    final capped = raw.length > 15 ? raw.substring(0, 15) : raw;
    final masked = _applyMask(capped);
    return TextEditingValue(
      text: masked,
      selection: selection ?? TextSelection.collapsed(offset: masked.length),
    );
  }
}

/// Applies `#####/##/####/####` while the user types (legacy mask).
class LicenseFileNoMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return PremiseLicenseFileNo.maskValue(newValue.text);
  }
}
