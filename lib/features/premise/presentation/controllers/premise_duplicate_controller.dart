import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_filter.dart';
import 'package:ilms/features/premise/domain/entities/premise_duplicate_record.dart';
import 'package:ilms/features/premise/presentation/providers/premise_duplicate_providers.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

/// UI filter selections for duplicate search (GeneralModel pickers).
class PremiseDuplicateFilterSelection {
  const PremiseDuplicateFilterSelection({
    this.parliament,
    this.area,
    this.street,
    this.building,
    this.unitNo,
  });

  final GeneralModel? parliament;
  final GeneralModel? area;
  final GeneralModel? street;
  final GeneralModel? building;
  final GeneralModel? unitNo;

  PremiseDuplicateFilterSelection copyWith({
    GeneralModel? parliament,
    GeneralModel? area,
    GeneralModel? street,
    GeneralModel? building,
    GeneralModel? unitNo,
    bool clearParliament = false,
    bool clearArea = false,
    bool clearStreet = false,
    bool clearBuilding = false,
    bool clearUnitNo = false,
  }) {
    return PremiseDuplicateFilterSelection(
      parliament: clearParliament ? null : (parliament ?? this.parliament),
      area: clearArea ? null : (area ?? this.area),
      street: clearStreet ? null : (street ?? this.street),
      building: clearBuilding ? null : (building ?? this.building),
      unitNo: clearUnitNo ? null : (unitNo ?? this.unitNo),
    );
  }

  PremiseDuplicateFilter toDomainFilter() {
    return PremiseDuplicateFilter(
      parliament: parliament?.desc ?? '',
      area: area?.desc ?? '',
      street: street?.desc ?? '',
      building: building?.desc ?? '',
      unit: unitNo?.desc ?? '',
    );
  }

  List<String> get activeChipLabels => [
        unitNo?.desc ?? '',
        building?.desc ?? '',
        street?.desc ?? '',
        parliament?.desc ?? '',
        area?.desc ?? '',
      ].where((value) => value.isNotEmpty).toList();

  bool get isEmpty =>
      parliament == null && area == null && street == null && building == null && unitNo == null;
}

class PremiseDuplicateState {
  const PremiseDuplicateState({
    this.hasSearched = false,
    this.listState = AppListState.empty,
    this.items = const [],
    this.isLoadingMore = false,
    this.hasNextPage = false,
    this.nextPage = 1,
    this.errorMessage,
    this.filter = const PremiseDuplicateFilterSelection(),
  });

  final bool hasSearched;
  final AppListState listState;
  final List<PremiseDuplicateRecord> items;
  final bool isLoadingMore;
  final bool hasNextPage;
  final int nextPage;
  final String? errorMessage;
  final PremiseDuplicateFilterSelection filter;

  PremiseDuplicateState copyWith({
    bool? hasSearched,
    AppListState? listState,
    List<PremiseDuplicateRecord>? items,
    bool? isLoadingMore,
    bool? hasNextPage,
    int? nextPage,
    String? errorMessage,
    PremiseDuplicateFilterSelection? filter,
  }) {
    return PremiseDuplicateState(
      hasSearched: hasSearched ?? this.hasSearched,
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

/// Session-scoped duplicate search controller.
///
/// Persists filter + result list across navigation (legacy `PremisDuplicateSearchController` parity).
/// Only the first-ever visit auto-opens the filter sheet when [PremiseDuplicateState.hasSearched] is false.
class PremiseDuplicateController extends Notifier<PremiseDuplicateState> {
  bool _isFetching = false;

  @override
  PremiseDuplicateState build() {
    ref.keepAlive();
    return const PremiseDuplicateState();
  }

  PremiseDuplicateFilterSelection snapshotFilter() => state.filter;

  void restoreFilter(PremiseDuplicateFilterSelection snapshot) {
    state = state.copyWith(filter: snapshot);
  }

  void setParliament(GeneralModel? value) {
    state = state.copyWith(filter: PremiseDuplicateFilterSelection(parliament: value));
  }

  void setArea(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(area: value, clearStreet: true, clearBuilding: true, clearUnitNo: true),
    );
  }

  void setStreet(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(street: value, clearBuilding: true, clearUnitNo: true),
    );
  }

  void setBuilding(GeneralModel? value) {
    state = state.copyWith(filter: state.filter.copyWith(building: value, clearUnitNo: true));
  }

  void setUnitNo(GeneralModel? value) {
    state = state.copyWith(filter: state.filter.copyWith(unitNo: value));
  }

  void resetFilter() {
    state = state.copyWith(filter: const PremiseDuplicateFilterSelection());
  }

  Future<void> search({bool isRefresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final keepItems = isRefresh && state.items.isNotEmpty;
      if (!keepItems) {
        state = state.copyWith(hasSearched: true, listState: AppListState.loading, errorMessage: null);
      }

      final page = await ref.read(premiseDuplicateRepositoryProvider).searchPreviousPhase(
            filter: state.filter.toDomainFilter(),
            page: 1,
          );

      state = state.copyWith(
        hasSearched: true,
        listState: page.items.isEmpty ? AppListState.empty : AppListState.content,
        items: page.items,
        hasNextPage: page.hasNextPage,
        nextPage: page.nextPage,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        hasSearched: true,
        listState: AppListState.error,
        errorMessage: error.toString(),
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<void> loadMore() async {
    if (_isFetching || state.isLoadingMore || !state.hasNextPage) return;
    _isFetching = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final page = await ref.read(premiseDuplicateRepositoryProvider).searchPreviousPhase(
            filter: state.filter.toDomainFilter(),
            page: state.nextPage,
          );

      state = state.copyWith(
        items: [...state.items, ...page.items],
        hasNextPage: page.hasNextPage,
        nextPage: page.nextPage,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, errorMessage: error.toString());
    } finally {
      _isFetching = false;
    }
  }

  Future<int> duplicateRecord(String visitNo) {
    return ref.read(premiseDuplicateRepositoryProvider).createDraftFromRecord(visitNo);
  }
}

final premiseDuplicateControllerProvider =
    NotifierProvider<PremiseDuplicateController, PremiseDuplicateState>(
  PremiseDuplicateController.new,
);
