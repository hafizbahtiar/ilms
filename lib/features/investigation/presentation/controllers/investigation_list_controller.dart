import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_search_filter.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_search_record.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_search_providers.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

/// Shared by both the search and history list pages — legacy has no
/// separate history endpoint; history simply hides the filter UI.
enum InvestigationListMode { search, history }

class InvestigationListState {
  const InvestigationListState({
    this.listState = AppListState.loading,
    this.items = const [],
    this.isLoadingMore = false,
    this.hasNextPage = false,
    this.nextPage = 1,
    this.errorMessage,
    this.filter = const InvestigationSearchFilter(),
  });

  final AppListState listState;
  final List<InvestigationSearchRecord> items;
  final bool isLoadingMore;
  final bool hasNextPage;
  final int nextPage;
  final String? errorMessage;
  final InvestigationSearchFilter filter;

  InvestigationListState copyWith({
    AppListState? listState,
    List<InvestigationSearchRecord>? items,
    bool? isLoadingMore,
    bool? hasNextPage,
    int? nextPage,
    String? errorMessage,
    InvestigationSearchFilter? filter,
  }) {
    return InvestigationListState(
      listState: listState ?? this.listState,
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      nextPage: nextPage ?? this.nextPage,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

class InvestigationListController extends FamilyNotifier<InvestigationListState, InvestigationListMode> {
  bool _isFetching = false;
  bool _paginationExhausted = false;

  @override
  InvestigationListState build(InvestigationListMode mode) {
    ref.keepAlive();
    return const InvestigationListState();
  }

  InvestigationSearchFilter snapshotFilter() => state.filter;

  void restoreFilter(InvestigationSearchFilter snapshot) {
    state = state.copyWith(filter: snapshot);
  }

  void resetFilter() {
    state = state.copyWith(filter: const InvestigationSearchFilter());
  }

  void setFilter(InvestigationSearchFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> search({bool isRefresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    _paginationExhausted = false;

    try {
      final keepItems = isRefresh && state.items.isNotEmpty;
      if (!keepItems) {
        state = state.copyWith(listState: AppListState.loading, errorMessage: null);
      }

      final page = await ref.read(investigationSearchRepositoryProvider).search(filter: state.filter, page: 1);

      state = state.copyWith(
        listState: page.items.isEmpty ? AppListState.empty : AppListState.content,
        items: page.items,
        hasNextPage: page.hasNextPage,
        nextPage: page.nextPage,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        listState: AppListState.error,
        errorMessage: error.toString().replaceFirst('ApiResponseException: ', ''),
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<void> loadMore() async {
    if (_isFetching || state.isLoadingMore || !state.hasNextPage || _paginationExhausted) {
      return;
    }
    _isFetching = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final requestedPage = state.nextPage;
      final page = await ref
          .read(investigationSearchRepositoryProvider)
          .search(filter: state.filter, page: requestedPage);

      final next = page.nextPage;
      if (!page.hasNextPage || next <= requestedPage) {
        _paginationExhausted = true;
      }

      state = state.copyWith(
        items: [...state.items, ...page.items],
        hasNextPage: page.hasNextPage && !_paginationExhausted,
        nextPage: next,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString().replaceFirst('ApiResponseException: ', ''),
      );
    } finally {
      _isFetching = false;
    }
  }
}

final investigationListControllerProvider =
    NotifierProvider.family<InvestigationListController, InvestigationListState, InvestigationListMode>(
      InvestigationListController.new,
    );
