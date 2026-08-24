import 'package:flutter/material.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_search_record.dart';

class InvestigationSearchRecordTile extends StatelessWidget {
  const InvestigationSearchRecordTile({super.key, required this.record, required this.accentColor, this.onTap});

  final InvestigationSearchRecord record;
  final Color accentColor;
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.applicantName?.trim().isNotEmpty == true ? record.applicantName! : record.investigationNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (_clean(record.statusCode) case final status?) _StatusChip(label: status, color: accentColor),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                record.investigationNo,
                style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.55)),
              ),
              const Divider(height: 20),
              if (_clean(record.companyName) case final company?)
                _InfoRow(icon: Icons.apartment_outlined, label: company, color: accentColor),
              if (_clean(record.businessType) case final businessType?)
                _InfoRow(icon: Icons.storefront_outlined, label: businessType, color: accentColor),
              if (_clean(record.investigationOfficer) case final officer?)
                _InfoRow(icon: Icons.badge_outlined, label: officer, color: accentColor),
              if (_clean(record.investigationStartDate) case final date?)
                _InfoRow(icon: Icons.event_outlined, label: date, color: accentColor),
            ],
          ),
        ),
      ),
    );
  }

  String? _clean(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
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
