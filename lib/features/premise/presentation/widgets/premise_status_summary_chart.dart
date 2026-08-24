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
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's Status Summary",
                  style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                ),
              ),
              // Data is cached locally once fetched — this is the only way
              // to pull a fresh count without leaving the page, so it needs
              // to be reachable from every state (data, empty, error), not
              // just tucked into the error retry.
              _RefreshButton(
                isRefreshing: summaryAsync.isRefreshing,
                onPressed: () => ref.invalidate(premiseStatusSummaryProvider),
              ),
            ],
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

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.isRefreshing, required this.onPressed});

  final bool isRefreshing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        tooltip: 'Refresh',
        onPressed: isRefreshing ? null : onPressed,
        icon: isRefreshing
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary.withValues(alpha: 0.6)),
              )
            : Icon(Icons.refresh_rounded, color: cs.primary),
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
      height: 100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 26, color: cs.onSurface.withValues(alpha: 0.35)),
            const SizedBox(height: 6),
            Text(
              'No visits recorded today',
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 2),
            Text(
              'Status counts will show up here once a census is submitted.',
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
            ),
          ],
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
