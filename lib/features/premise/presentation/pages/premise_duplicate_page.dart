import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_record.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_duplicate_controller.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_duplicate_filter_sheet.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_duplicate_record_tile.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/shared/ui/app_bars/app_search_app_bar.dart';
import 'package:ilms/shared/ui/feedback/app_dialog.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

class PremiseDuplicatePage extends ConsumerStatefulWidget {
  const PremiseDuplicatePage({super.key});

  @override
  ConsumerState<PremiseDuplicatePage> createState() => _PremiseDuplicatePageState();
}

class _PremiseDuplicatePageState extends ConsumerState<PremiseDuplicatePage> {
  static final _module = homeModulesById['premise']!;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!ref.read(premiseDuplicateControllerProvider).hasSearched) {
        _openFilterSheet();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final state = ref.read(premiseDuplicateControllerProvider);
    if (!state.hasNextPage || state.isLoadingMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(premiseDuplicateControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _openFilterSheet() async {
    final applied = await showPremiseDuplicateFilterSheet(context, ref);
    if (applied == true && mounted) {
      await ref.read(premiseDuplicateControllerProvider.notifier).search();
    }
  }

  Future<void> _confirmDuplicate(PremiseDuplicateRecord record) async {
    final label = record.displayHeader;
    final confirmed = await confirmAppDialog(
      context: context,
      title: 'Duplicate Premise',
      message: 'Duplicate premise data for "$label"? A new form will be created using this record\'s details.',
      confirmLabel: 'Duplicate',
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator.adaptive()),
    );

    try {
      final draftId = await ref.read(premiseDuplicateControllerProvider.notifier).duplicateRecord(record.visitNo);
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push(AppRoutes.premiseFormDraft(draftId));
      AppSnackbar.success(context, 'Duplicate form ready.');
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();
      final message = error.toString().replaceFirst('Exception: ', '');
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(premiseDuplicateControllerProvider);
    final chips = searchState.filter.activeChipLabels;

    return Scaffold(
      appBar: AppSearchAppBar(
        title: 'Duplicate Premise',
        filterChips: chips,
        onFilterTap: _openFilterSheet,
        onClearFilters: () {
          ref.read(premiseDuplicateControllerProvider.notifier).resetFilter();
          ref.read(premiseDuplicateControllerProvider.notifier).search();
        },
        showResetChip: false,
      ),
      body: searchState.hasSearched
          ? AppListView(
              controller: _scrollController,
              state: searchState.listState,
              itemCount: searchState.items.length,
              itemBuilder: (context, index) {
                final record = searchState.items[index];
                return PremiseDuplicateRecordTile(
                  record: record,
                  accentColor: _module.color,
                  onTap: () => _confirmDuplicate(record),
                );
              },
              empty: AppListEmptyConfig(
                icon: Icons.search_off_rounded,
                title: 'No records found',
                subtitle: 'Try adjusting the address filter and search again.',
                actionLabel: 'Open Filter',
                onAction: _openFilterSheet,
              ),
              errorMessage: searchState.errorMessage ?? 'Unable to load duplicate search results.',
              onRefresh: () => ref.read(premiseDuplicateControllerProvider.notifier).search(isRefresh: true),
              onRetry: () => ref.read(premiseDuplicateControllerProvider.notifier).search(),
              isLoadingMore: searchState.isLoadingMore,
            )
          : _NoSearchYetState(onOpenFilter: _openFilterSheet),
    );
  }
}

class _NoSearchYetState extends StatelessWidget {
  const _NoSearchYetState({required this.onOpenFilter});

  final VoidCallback onOpenFilter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 64, color: cs.onSurface.withValues(alpha: 0.28)),
            const SizedBox(height: 16),
            Text(
              'Belum ada carian',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Isi alamat premis dalam filter dan tekan Apply untuk papar senarai duplicate.',
              style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.62)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onOpenFilter,
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Buka Filter'),
            ),
          ],
        ),
      ),
    );
  }
}
