import 'package:flutter/material.dart';
import 'package:ilms/shared/models/general_model.dart';

/// Standard picker label.
///
/// Priority:
/// 1. [GeneralModel.apiDisplay] when the API sends `display` (e.g. `"O : OTHER"`)
/// 2. [GeneralModel.desc] for user-facing text
/// 3. [GeneralModel.code] as a last-resort fallback
///
/// Callers should still persist/send [GeneralModel.code] — this is display only.
String generalLookupLabel(GeneralModel option) {
  final apiDisplay = option.apiDisplay?.trim();
  if (apiDisplay != null && apiDisplay.isNotEmpty) return apiDisplay;

  final desc = option.desc?.trim();
  if (desc != null && desc.isNotEmpty) return desc;

  return option.code?.trim() ?? '';
}

/// Same as [generalLookupLabel] but nullable for filter rows / chips.
String? generalLookupDisplay(GeneralModel? option) {
  if (option == null) return null;
  final label = generalLookupLabel(option);
  return label.isEmpty ? null : label;
}

/// Postcode picker shows `50000 - Kuala Lumpur` when city differs from code.
/// When [GeneralModel.apiDisplay] is set, or code/desc are identical, shows a
/// single value instead of `51000 - 51000`.
String generalPostcodeLabel(GeneralModel option) {
  final apiDisplay = option.apiDisplay?.trim();
  if (apiDisplay != null && apiDisplay.isNotEmpty) return apiDisplay;

  final code = option.code?.trim();
  final desc = option.desc?.trim();

  if (code != null && code.isNotEmpty && desc != null && desc.isNotEmpty) {
    if (code == desc) return desc;
    return '$code - $desc';
  }

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
