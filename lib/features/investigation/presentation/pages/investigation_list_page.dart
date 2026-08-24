import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/investigation/presentation/controllers/investigation_list_controller.dart';
import 'package:ilms/features/investigation/presentation/widgets/investigation_search_filter_sheet.dart';
import 'package:ilms/features/investigation/presentation/widgets/investigation_search_record_tile.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/shared/ui/app_bars/app_search_app_bar.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

/// Shared by both "View All" (search, with filter) and "History" (same
/// list, no filter UI) — legacy has no separate history endpoint.
class InvestigationListPage extends ConsumerStatefulWidget {
  const InvestigationListPage({super.key, required this.module, required this.mode});

  final HomeModule module;
  final InvestigationListMode mode;

  @override
  ConsumerState<InvestigationListPage> createState() => _InvestigationListPageState();
}

class _InvestigationListPageState extends ConsumerState<InvestigationListPage> {
  final _scrollController = ScrollController();

  bool get _isSearch => widget.mode == InvestigationListMode.search;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(investigationListControllerProvider(widget.mode).notifier).search();
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
    final state = ref.read(investigationListControllerProvider(widget.mode));
    if (!state.hasNextPage || state.isLoadingMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(investigationListControllerProvider(widget.mode).notifier).loadMore();
    }
  }

  Future<void> _openFilterSheet() async {
    final applied = await showInvestigationSearchFilterSheet(context, ref);
    if (applied == true && mounted) {
      await ref.read(investigationListControllerProvider(widget.mode).notifier).search();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(investigationListControllerProvider(widget.mode));
    final title = _isSearch ? widget.module.title : 'Investigation History';

    return Scaffold(
      appBar: _isSearch
          ? AppSearchAppBar(
              title: title,
              filterChips: const [],
              onFilterTap: _openFilterSheet,
              onClearFilters: () {
                ref.read(investigationListControllerProvider(widget.mode).notifier).resetFilter();
                ref.read(investigationListControllerProvider(widget.mode).notifier).search();
              },
            )
          : AppBar(title: Text(title), centerTitle: false),
      body: AppListView(
        controller: _scrollController,
        state: listState.listState,
        itemCount: listState.items.length,
        isLoadingMore: listState.isLoadingMore,
        onRefresh: () => ref.read(investigationListControllerProvider(widget.mode).notifier).search(isRefresh: true),
        onRetry: () => ref.read(investigationListControllerProvider(widget.mode).notifier).search(),
        errorMessage: listState.errorMessage,
        empty: AppListEmptyConfig(
          icon: Icons.search_off_outlined,
          title: _isSearch ? 'No investigations found' : 'No investigation history',
          subtitle: _isSearch ? 'Try adjusting your filters.' : 'Viewed and edited investigations will appear here.',
        ),
        itemBuilder: (context, index) {
          final record = listState.items[index];
          return InvestigationSearchRecordTile(
            record: record,
            accentColor: widget.module.color,
            onTap: () => context.push(AppRoutes.investigationFormView(record.investigationNo)),
          );
        },
      ),
    );
  }
}
