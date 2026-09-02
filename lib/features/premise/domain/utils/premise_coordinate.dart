/// Returns `null` when [value] is empty or parses to zero (e.g. `0.000000`).
double? parsePremiseCoordinate(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;
  final parsed = double.tryParse(text);
  if (parsed == null || parsed == 0.0) return null;
  return parsed;
}

/// Normalizes a stored coordinate string — zero values become `null`.
String? normalizePremiseCoordinate(String? value) {
  if (parsePremiseCoordinate(value) == null) return null;
  return value?.trim();
}
