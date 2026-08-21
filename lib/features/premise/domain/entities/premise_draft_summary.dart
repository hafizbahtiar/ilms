import 'package:equatable/equatable.dart';

/// How a local premise draft came to be — surfaced as a tag on draft list
/// tiles so users can tell a plain new entry apart from a vacant-lot entry
/// or a copy created via the duplicate flow.
enum PremiseDraftType { newEntry, vacant, duplicate }

extension PremiseDraftTypeStorage on PremiseDraftType {
  static PremiseDraftType fromStorage(String? value) {
    return PremiseDraftType.values.firstWhere((type) => type.name == value, orElse: () => PremiseDraftType.newEntry);
  }
}

/// List row for premise draft screens.
class PremiseDraftSummary extends Equatable {
  const PremiseDraftSummary({
    required this.id,
    required this.companyName,
    required this.traderName,
    required this.updatedAt,
    this.isEditSession = false,
    this.visitNo,
    this.draftType = PremiseDraftType.newEntry,
  });

  final int id;
  final String companyName;
  final String traderName;
  final DateTime updatedAt;
  final bool isEditSession;
  final PremiseDraftType draftType;

  /// Set for edit-session rows — the server record this is a pending local
  /// edit of. Needed to resume it via the view→edit flow rather than the
  /// plain local-draft-id flow.
  final String? visitNo;

  String get displayTitle {
    final company = companyName.trim();
    if (company.isNotEmpty) return company;
    final trader = traderName.trim();
    if (trader.isNotEmpty) return trader;
    return 'Untitled draft #$id';
  }

  String get displaySubtitle {
    final trader = traderName.trim();
    if (trader.isNotEmpty && trader != displayTitle) return trader;
    return 'Last saved ${_formatRelative(updatedAt)}';
  }

  static String _formatRelative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  List<Object?> get props => [id, companyName, traderName, updatedAt, isEditSession, visitNo, draftType];
}
