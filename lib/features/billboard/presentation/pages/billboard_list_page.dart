import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/billboard/presentation/controllers/billboard_list_controller.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_draft_providers.dart';
import 'package:ilms/features/billboard/presentation/widgets/billboard_search_filter_sheet.dart';
import 'package:ilms/features/billboard/presentation/widgets/billboard_tile.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/shared/ui/app_bars/app_search_app_bar.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

/// Single-list billboard search page — unlike premise there's no
/// Today/History split.
class BillboardListPage extends ConsumerStatefulWidget {
  const BillboardListPage({super.key, required this.module});

  final HomeModule module;

  @override
  ConsumerState<BillboardListPage> createState() => _BillboardListPageState();
}

class _BillboardListPageState extends ConsumerState<BillboardListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(billboardListControllerProvider.notifier).search();
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
    final state = ref.read(billboardListControllerProvider);
    if (!state.hasNextPage || state.isLoadingMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(billboardListControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _openFilterSheet() async {
    final applied = await showBillboardSearchFilterSheet(context, ref);
    if (applied == true && mounted) {
      await ref.read(billboardListControllerProvider.notifier).search();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(billboardListControllerProvider);
    final chips = searchState.filter.activeChipLabels;
    final editSessionBillboardNos = ref.watch(billboardEditSessionBillboardNosProvider).valueOrNull ?? const {};

    return Scaffold(
      appBar: AppSearchAppBar(
        title: widget.module.title,
        filterChips: chips,
        onFilterTap: _openFilterSheet,
        onClearFilters: () {
          ref.read(billboardListControllerProvider.notifier).resetFilter();
          ref.read(billboardListControllerProvider.notifier).search();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.billboardFormNewEntry()),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: AppListView(
        controller: _scrollController,
        state: searchState.listState,
        itemCount: searchState.items.length,
        isLoadingMore: searchState.isLoadingMore,
        onRefresh: () => ref.read(billboardListControllerProvider.notifier).search(isRefresh: true),
        onRetry: () => ref.read(billboardListControllerProvider.notifier).search(),
        errorMessage: searchState.errorMessage,
        empty: const AppListEmptyConfig(
          icon: Icons.campaign_outlined,
          title: 'No billboards found',
          subtitle: 'Try adjusting the date range or filters.',
        ),
        itemBuilder: (context, index) {
          final record = searchState.items[index];
          return BillboardTile(
            record: record,
            accentColor: widget.module.color,
            hasUnsavedEdit: editSessionBillboardNos.contains(record.billboardNo),
            onTap: () => context.push(AppRoutes.billboardFormView(record.billboardNo)),
          );
        },
      ),
    );
  }
}
