import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_list_controller.dart';
import 'package:ilms/features/premise/presentation/providers/premise_draft_providers.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_search_filter_sheet.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_search_record_tile.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_unsaved_edits_sheet.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/shared/ui/app_bars/app_search_app_bar.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

class PremiseListPage extends ConsumerStatefulWidget {
  const PremiseListPage({super.key, required this.module});

  final HomeModule module;

  @override
  ConsumerState<PremiseListPage> createState() => _PremisePageState();
}

class _PremisePageState extends ConsumerState<PremiseListPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _todayScrollController = ScrollController();
  final _historyScrollController = ScrollController();

  static const _tabs = PremiseListTab.values;

  PremiseListTab get _activeTab => _tabs[_tabController.index];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });

    _todayScrollController.addListener(() => _onScroll(PremiseListTab.today, _todayScrollController));
    _historyScrollController.addListener(() => _onScroll(PremiseListTab.history, _historyScrollController));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(premiseSearchControllerProvider(PremiseListTab.today).notifier).search();
      ref.read(premiseSearchControllerProvider(PremiseListTab.history).notifier).search();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _todayScrollController.dispose();
    _historyScrollController.dispose();
    super.dispose();
  }

  void _onScroll(PremiseListTab tab, ScrollController controller) {
    if (!controller.hasClients) return;
    final state = ref.read(premiseSearchControllerProvider(tab));
    if (!state.hasNextPage || state.isLoadingMore) return;

    final threshold = controller.position.maxScrollExtent - 200;
    if (controller.position.pixels >= threshold) {
      ref.read(premiseSearchControllerProvider(tab).notifier).loadMore();
    }
  }

  Future<void> _openFilterSheet() async {
    final tab = _activeTab;
    final applied = await showPremiseSearchFilterSheet(context, ref, tab);
    if (applied == true && mounted) {
      await ref.read(premiseSearchControllerProvider(tab).notifier).search();
    }
  }

  Future<void> _showAddOptions() async {
    final choice = await showAppBottomSheet<_PremiseAddChoice>(
      context: context,
      title: 'Add Premise',
      subtitle: 'Choose how you want to register this premise.',
      preset: AppBottomSheetPreset.compact,
      itemCount: 3,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _AddOptionTile(
              icon: Icons.add_business_outlined,
              title: 'New',
              subtitle: 'Register a new business premise',
              onTap: () => Navigator.of(context).pop(_PremiseAddChoice.newEntry),
            ),
            const SizedBox(height: 8),
            _AddOptionTile(
              icon: Icons.storefront_outlined,
              title: 'Vacant',
              subtitle: 'Record a vacant premise unit',
              onTap: () => Navigator.of(context).pop(_PremiseAddChoice.vacant),
            ),
            const SizedBox(height: 8),
            _AddOptionTile(
              icon: Icons.copy_all_outlined,
              title: 'Duplicate',
              subtitle: 'Copy data from a previous phase',
              onTap: () => Navigator.of(context).pop(_PremiseAddChoice.duplicate),
            ),
          ],
        );
      },
    );

    if (!mounted || choice == null) return;

    switch (choice) {
      case _PremiseAddChoice.newEntry:
        context.push(AppRoutes.premiseFormNewEntry());
      case _PremiseAddChoice.vacant:
        context.push(AppRoutes.premiseFormNewVacantEntry());
      case _PremiseAddChoice.duplicate:
        context.push(AppRoutes.premiseDuplicate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final searchState = ref.watch(premiseSearchControllerProvider(_activeTab));
    final draftCount = ref.watch(premiseDraftCountProvider).valueOrNull ?? 0;
    final unsavedEditCount = ref.watch(premiseEditSessionCountProvider).valueOrNull ?? 0;
    final chips = searchState.filter.activeChipLabels;

    return Scaffold(
      appBar: AppSearchAppBar(
        title: widget.module.title,
        filterChips: _activeTab == PremiseListTab.history ? chips : const [],
        onFilterTap: _activeTab == PremiseListTab.history ? _openFilterSheet : null,
        onClearFilters: _activeTab == PremiseListTab.history
            ? () {
                final tab = _activeTab;
                ref.read(premiseSearchControllerProvider(tab).notifier).resetFilter();
                ref.read(premiseSearchControllerProvider(tab).notifier).search();
              }
            : null,
        tailActions: _activeTab == PremiseListTab.today
            ? [
                IconButton(
                  tooltip: 'Unsaved edits',
                  onPressed: () => showPremiseUnsavedEditsSheet(context),
                  icon: Badge(
                    isLabelVisible: unsavedEditCount > 0,
                    label: Text('$unsavedEditCount'),
                    child: Icon(Icons.edit_note_rounded, color: cs.onPrimary),
                  ),
                ),
              ]
            : null,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text('Today', style: TextStyle(color: cs.onPrimary)),
            ),
            Tab(
              child: Text('History', style: TextStyle(color: cs.onPrimary)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOptions,
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: Column(
        children: [
          if (draftCount > 0)
            _DraftBanner(
              count: draftCount,
              accentColor: widget.module.color,
              onTap: () => context.push(AppRoutes.premiseDrafts),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PremiseListTabBody(
                  tab: PremiseListTab.today,
                  scrollController: _todayScrollController,
                  accentColor: widget.module.color,
                ),
                _PremiseListTabBody(
                  tab: PremiseListTab.history,
                  scrollController: _historyScrollController,
                  accentColor: widget.module.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiseListTabBody extends ConsumerWidget {
  const _PremiseListTabBody({required this.tab, required this.scrollController, required this.accentColor});

  final PremiseListTab tab;
  final ScrollController scrollController;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(premiseSearchControllerProvider(tab));
    final unsavedVisitNos = ref.watch(premiseEditSessionVisitNosProvider).valueOrNull ?? const <String>{};

    return AppListView(
      controller: scrollController,
      state: searchState.listState,
      itemCount: searchState.items.length,
      isLoadingMore: searchState.isLoadingMore,
      onRefresh: () => ref.read(premiseSearchControllerProvider(tab).notifier).search(isRefresh: true),
      onRetry: () => ref.read(premiseSearchControllerProvider(tab).notifier).search(),
      errorMessage: searchState.errorMessage,
      empty: AppListEmptyConfig(
        icon: Icons.search_off_outlined,
        title: tab == PremiseListTab.today ? 'No premises visited today' : 'No premise history found',
        subtitle: 'Try adjusting the date range or filters.',
      ),
      itemBuilder: (context, index) {
        final record = searchState.items[index];
        return PremiseSearchRecordTile(
          record: record,
          accentColor: accentColor,
          hasUnsavedEdit: tab == PremiseListTab.today && unsavedVisitNos.contains(record.visitNo),
          onTap: tab == PremiseListTab.today
              ? () => context.push(AppRoutes.premiseFormView(record.visitNo))
              : () => context.push(AppRoutes.premiseDetailView(record.visitNo)),
        );
      },
    );
  }
}

enum _PremiseAddChoice { newEntry, vacant, duplicate }

class _DraftBanner extends StatelessWidget {
  const _DraftBanner({required this.count, required this.accentColor, required this.onTap});

  final int count;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: accentColor.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.drafts_outlined, color: accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$count local draft${count == 1 ? '' : 's'} pending',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.45)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddOptionTile extends StatelessWidget {
  const _AddOptionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
