import 'package:flutter/material.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_minute.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

/// Historical, read-only minute records (role/officer/date/text) — a
/// separate concept from the one editable minutes entry per submit.
Future<void> showInvestigationMinuteHistorySheet(BuildContext context, List<InvestigationMinute> minutes) {
  return showAppBottomSheet<void>(
    context: context,
    title: 'Minute History',
    subtitle: minutes.isEmpty ? 'No historical minutes recorded yet.' : null,
    preset: AppBottomSheetPreset.auto,
    itemCount: minutes.length,
    builder: (context, _) {
      if (minutes.isEmpty) {
        return const SizedBox(height: 40);
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [for (final minute in minutes) _MinuteTile(minute: minute)],
      );
    },
  );
}

class _MinuteTile extends StatelessWidget {
  const _MinuteTile({required this.minute});

  final InvestigationMinute minute;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final date = minute.date;
    final dateLabel = date == null
        ? '-'
        : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  minute.officer ?? minute.role ?? 'Unknown officer',
                  style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(dateLabel, style: textTheme.labelSmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: 6),
          Text(minute.minutes ?? '-', style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
