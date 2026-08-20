import 'package:equatable/equatable.dart';

/// List row for premise draft screens.
class PremiseDraftSummary extends Equatable {
  const PremiseDraftSummary({
    required this.id,
    required this.companyName,
    required this.traderName,
    required this.updatedAt,
    this.isEditSession = false,
  });

  final int id;
  final String companyName;
  final String traderName;
  final DateTime updatedAt;
  final bool isEditSession;

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
  List<Object?> get props => [id, companyName, traderName, updatedAt, isEditSession];
}
