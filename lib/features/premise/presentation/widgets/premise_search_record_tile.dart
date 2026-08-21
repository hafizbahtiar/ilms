import 'package:flutter/material.dart';
import 'package:ilms/features/premise/domain/entities/premise_search_record.dart';

class PremiseSearchRecordTile extends StatelessWidget {
  const PremiseSearchRecordTile({
    super.key,
    required this.record,
    required this.accentColor,
    this.hasUnsavedEdit = false,
    this.onTap,
  });

  final PremiseSearchRecord record;
  final Color accentColor;

  /// True when there's a pending local unsaved edit for this record.
  final bool hasUnsavedEdit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.displayHeader,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    record.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (record.visitNo.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      record.visitNo,
                      style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.55)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (hasUnsavedEdit) const _UnsavedChip(),
                      if (record.visitStatus != null) _MetaChip(label: 'Status', value: record.visitStatus!),
                      if (record.phase != null) _MetaChip(label: 'Phase', value: record.phase!),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.35)),
            if (record.createdBy != null)
              _InfoRow(icon: Icons.person_outline, label: record.createdBy!, color: accentColor),
            if (record.visitDate != null)
              _InfoRow(icon: Icons.calendar_month_outlined, label: record.visitDate!, color: accentColor),
            if (_cleanAddress(record.address) case final address?)
              _InfoRow(icon: Icons.location_on_outlined, label: address, color: accentColor),
          ],
        ),
      ),
    );
  }

  String? _cleanAddress(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}

class _UnsavedChip extends StatelessWidget {
  const _UnsavedChip();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: cs.errorContainer, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note_rounded, size: 13, color: cs.onErrorContainer),
          const SizedBox(width: 3),
          Text(
            'Unsaved',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w700, color: cs.onErrorContainer),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
