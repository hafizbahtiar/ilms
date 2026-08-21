import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/premise/domain/entities/premise_status_summary.dart';
import 'package:ilms/features/premise/presentation/providers/premise_status_summary_providers.dart';
import 'package:ilms/shared/constants/home_modules.dart';

/// Fixed color per visit status, kept stable regardless of API ordering.
const Map<String, Color> _statusColors = {
  'LEGAL': Color(0xFF2E7D32),
  'EXPIRED': Color(0xFFC62828),
  'INSUFFICIENT': Color(0xFFEF6C00),
  'INACCURATE': Color(0xFFF9A825),
  'NO LICENSE': Color(0xFF6A1B9A),
  'EXCEPTIONAL': Color(0xFF00838F),
  'NOT ACCESS': Color(0xFF616161),
  'STORE': Color(0xFF1565C0),
  'VACANT': Color(0xFF8D6E63),
  'KIV': Color(0xFFAD1457),
};

const Color _fallbackStatusColor = Color(0xFF9E9E9E);

Color _colorForStatus(String status) => _statusColors[status.toUpperCase()] ?? _fallbackStatusColor;

/// Homepage donut chart of today's premise visit-status counts. Hides
/// itself entirely when the user lacks the premise module permission, or
/// when there's simply nothing to show yet.
class PremiseStatusSummaryChart extends ConsumerWidget {
  const PremiseStatusSummaryChart({super.key});

  static final _module = homeModulesById['premise']!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(authControllerProvider).user?.permissions ?? const [];
    if (!permissions.contains(_module.permission)) {
      return const SizedBox.shrink();
    }

    final summaryAsync = ref.watch(premiseStatusSummaryProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Status Summary",
            style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: _module.color),
          ),
          const SizedBox(height: 12),
          summaryAsync.when(
            data: (summary) => summary.total == 0
                ? _EmptyState(textTheme: textTheme, cs: cs)
                : _SummaryContent(summary: summary, textTheme: textTheme, cs: cs),
            loading: () => const _LoadingState(),
            error: (error, _) => _ErrorState(cs: cs, textTheme: textTheme),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.cs, required this.textTheme});

  final ColorScheme cs;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 18, color: cs.error),
            const SizedBox(width: 8),
            Text(
              'Unable to load status summary.',
              style: textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.textTheme, required this.cs});

  final TextTheme textTheme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: Text(
          'No data yet',
          style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.summary, required this.textTheme, required this.cs});

  final PremiseStatusSummary summary;
  final TextTheme textTheme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final nonZero = summary.visitStatus.where((item) => item.value > 0).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: PieChart(
            PieChartData(
              sections: nonZero
                  .map(
                    (item) => PieChartSectionData(
                      value: item.value.toDouble(),
                      color: _colorForStatus(item.status),
                      title: '',
                      radius: 20,
                    ),
                  )
                  .toList(),
              centerSpaceRadius: 28,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: ${summary.total}',
                style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                children: summary.visitStatus.map((item) => _LegendEntry(item: item, textTheme: textTheme)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.item, required this.textTheme});

  final PremiseVisitStatusCount item;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _colorForStatus(item.status), shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('${item.status} (${item.value})', style: textTheme.bodySmall),
      ],
    );
  }
}
