/// Pure encode/decode helpers for billboard remarks, ported from legacy
/// `RemarksDetailController` (`resolveRemarkOptions` / "Others" detection).
///
/// The server stores remarks as a single comma-joined string of option
/// codes, with an "Others" option (matched by description) that carries
/// free text instead of a code.
class BillboardRemarkOption {
  const BillboardRemarkOption({required this.code, required this.desc, required this.display});

  final String code;
  final String desc;

  /// Server-provided `display` label (e.g. `"O : STORE"`), preferred for
  /// showing to the user — see `generalLookupLabel` / `GeneralModel.apiDisplay`.
  final String display;

  bool get isOther => desc.trim().toLowerCase() == 'other';
}

/// Splits a legacy comma-joined remark string into known option codes plus
/// any unmatched tokens, which are treated as legacy free text and merged
/// into [otherText].
class ResolvedBillboardRemarks {
  const ResolvedBillboardRemarks({required this.codes, this.otherText});

  final List<String> codes;
  final String? otherText;
}

ResolvedBillboardRemarks resolveRemarkOptions(String? raw, List<BillboardRemarkOption> options) {
  final tokens = (raw ?? '').split(',').map((token) => token.trim()).where((token) => token.isNotEmpty).toList();

  final knownCodes = options.map((option) => option.code).toSet();
  final codes = <String>[];
  final freeText = <String>[];

  for (final token in tokens) {
    if (knownCodes.contains(token)) {
      codes.add(token);
    } else {
      freeText.add(token);
    }
  }

  return ResolvedBillboardRemarks(codes: codes, otherText: freeText.isEmpty ? null : freeText.join(', '));
}

/// Re-encodes selected codes plus optional free text back into the legacy
/// comma-joined string for submission.
String encodeRemarkOptions({required List<String> codes, String? otherText}) {
  final parts = [...codes];
  if (otherText != null && otherText.trim().isNotEmpty) {
    parts.add(otherText.trim());
  }
  return parts.join(', ');
}

bool isOtherRemarkOption(BillboardRemarkOption option) => option.isOther;
