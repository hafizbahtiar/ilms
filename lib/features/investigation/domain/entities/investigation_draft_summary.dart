import 'package:equatable/equatable.dart';

/// List row for the investigation edit-session drafts page — a paused
/// "Save & Exit" edit of an existing case (no new-entry draft type; every
/// investigation already exists on the server).
class InvestigationDraftSummary extends Equatable {
  const InvestigationDraftSummary({
    required this.investigationNo,
    required this.applicantName,
    required this.updatedAt,
  });

  final String investigationNo;
  final String applicantName;
  final DateTime updatedAt;

  String get displayTitle => applicantName.trim().isNotEmpty ? applicantName : investigationNo;

  String get displaySubtitle => 'Last saved ${_formatRelative(updatedAt)}';

  static String _formatRelative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  List<Object?> get props => [investigationNo, applicantName, updatedAt];
}
