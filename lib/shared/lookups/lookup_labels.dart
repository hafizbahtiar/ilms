import 'package:flutter/material.dart';
import 'package:ilms/shared/models/general_model.dart';

/// Standard picker label: `CODE : Description`
String generalLookupLabel(GeneralModel option) {
  final code = option.code?.trim();
  final desc = option.desc?.trim();
  if (code != null && code.isNotEmpty && desc != null && desc.isNotEmpty) {
    return '$code : $desc';
  }
  return desc ?? code ?? '';
}

/// Postcode picker shows `50000 - Kuala Lumpur` style labels.
String generalPostcodeLabel(GeneralModel option) {
  final code = option.code?.trim();
  final desc = option.desc?.trim();
  if (code != null && desc != null) return '$code - $desc';
  return code ?? desc ?? '';
}

/// Parses labels produced by [generalLookupLabel] and [generalPostcodeLabel].
String? lookupCodeFromDisplay(String? display) {
  if (display == null || display.trim().isEmpty) return null;
  final trimmed = display.trim();
  if (trimmed.contains(' : ')) return trimmed.split(' : ').first.trim();
  if (trimmed.contains(' - ')) return trimmed.split(' - ').first.trim();
  return trimmed;
}

String? lookupDescFromDisplay(String? display) {
  if (display == null || display.trim().isEmpty) return null;
  final trimmed = display.trim();
  if (trimmed.contains(' : ')) {
    final desc = trimmed.split(' : ').sublist(1).join(' : ').trim();
    return desc.isEmpty ? null : desc;
  }
  if (trimmed.contains(' - ')) {
    final desc = trimmed.split(' - ').sublist(1).join(' - ').trim();
    return desc.isEmpty ? null : desc;
  }
  return null;
}

void applyGeneralLookupSelection({
  required TextEditingController controller,
  required GeneralModel item,
  String Function(GeneralModel)? label,
}) {
  controller.text = (label ?? generalLookupLabel)(item);
}
