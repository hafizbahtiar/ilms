import 'package:equatable/equatable.dart';

/// How a local billboard draft came to be. Billboard has no vacant/duplicate
/// concept (unlike premise) — this exists purely so the shape matches
/// premise's draft system for future extensibility.
enum BillboardDraftType { newEntry }

/// List row for billboard draft screens.
class BillboardDraftSummary extends Equatable {
  const BillboardDraftSummary({
    required this.id,
    required this.mediaClientName,
    required this.description,
    required this.updatedAt,
    this.isEditSession = false,
    this.billboardNo,
  });

  final int id;
  final String mediaClientName;
  final String description;
  final DateTime updatedAt;
  final bool isEditSession;

  /// Set for edit-session rows — the server record this is a pending local
  /// edit of. Needed to resume it via the view→edit flow rather than the
  /// plain local-draft-id flow.
  final String? billboardNo;

  String get displayTitle {
    final client = mediaClientName.trim();
    if (client.isNotEmpty) return client;
    final desc = description.trim();
    if (desc.isNotEmpty) return desc;
    return 'Untitled draft #$id';
  }

  String get displaySubtitle {
    final desc = description.trim();
    if (desc.isNotEmpty && desc != displayTitle) return desc;
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
  List<Object?> get props => [id, mediaClientName, description, updatedAt, isEditSession, billboardNo];
}
