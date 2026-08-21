import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_search_filter.dart';
import 'package:ilms/features/premise/domain/entities/premise_search_record.dart';
import 'package:ilms/features/premise/presentation/providers/premise_search_providers.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

class PremiseSearchFilterSelection {
  const PremiseSearchFilterSelection({
    this.dateRange,
    this.phase,
    this.companyName = '',
    this.traderName = '',
    this.licenseNo = '',
    this.licenseFileNo = '',
    this.parliament,
    this.area,
    this.street,
    this.building,
    this.unitNo,
  });

  final DateTimeRange? dateRange;
  final GeneralModel? phase;
  final String companyName;
  final String traderName;
  final String licenseNo;
  final String licenseFileNo;
  final GeneralModel? parliament;
  final GeneralModel? area;
  final GeneralModel? street;
  final GeneralModel? building;
  final GeneralModel? unitNo;

  static DateTimeRange defaultDateRange([DateTime? now]) {
    final today = now ?? DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    return DateTimeRange(start: normalized, end: normalized);
  }

  /// Default range for the History tab — a rolling 7-day window ending today
  /// (e.g. today 21/08/2026 → defaults from 14/08/2026).
  static DateTimeRange historyDefaultDateRange([DateTime? now]) {
    final today = now ?? DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    return DateTimeRange(start: normalizedToday.subtract(const Duration(days: 7)), end: normalizedToday);
  }

  bool get isDefaultDateRange {
    final range = dateRange ?? defaultDateRange();
    final today = DateTime.now();
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    final normalizedToday = DateTime(today.year, today.month, today.day);
    return start == normalizedToday && end == normalizedToday;
  }

  String get dateRangeLabel {
    final range = dateRange ?? defaultDateRange();
    return '${formatIsoDate(range.start)} - ${formatIsoDate(range.end)}';
  }

  PremiseSearchFilterSelection copyWith({
    DateTimeRange? dateRange,
    GeneralModel? phase,
    String? companyName,
    String? traderName,
    String? licenseNo,
    String? licenseFileNo,
    GeneralModel? parliament,
    GeneralModel? area,
    GeneralModel? street,
    GeneralModel? building,
    GeneralModel? unitNo,
    bool clearPhase = false,
    bool clearParliament = false,
    bool clearArea = false,
    bool clearStreet = false,
    bool clearBuilding = false,
    bool clearUnitNo = false,
  }) {
    return PremiseSearchFilterSelection(
      dateRange: dateRange ?? this.dateRange,
      phase: clearPhase ? null : (phase ?? this.phase),
      companyName: companyName ?? this.companyName,
      traderName: traderName ?? this.traderName,
      licenseNo: licenseNo ?? this.licenseNo,
      licenseFileNo: licenseFileNo ?? this.licenseFileNo,
      parliament: clearParliament ? null : (parliament ?? this.parliament),
      area: clearArea ? null : (area ?? this.area),
      street: clearStreet ? null : (street ?? this.street),
      building: clearBuilding ? null : (building ?? this.building),
      unitNo: clearUnitNo ? null : (unitNo ?? this.unitNo),
    );
  }

  PremiseSearchFilter toDomainFilter() {
    return PremiseSearchFilter(
      unit: unitNo?.desc ?? '',
      building: building?.desc ?? '',
      street: street?.desc ?? '',
      area: area?.desc ?? '',
      parliament: parliament?.desc ?? '',
      phase: phase?.code ?? '',
      companyName: companyName.trim(),
      traderName: traderName.trim(),
      licenseNo: licenseNo.trim(),
      licenseFileNo: licenseFileNo.trim(),
    );
  }

  List<String> get activeChipLabels => [
    if (!isDefaultDateRange) dateRangeLabel,
    phase?.desc ?? '',
    companyName.trim(),
    traderName.trim(),
    licenseNo.trim(),
    licenseFileNo.trim(),
    unitNo?.desc ?? '',
    building?.desc ?? '',
    street?.desc ?? '',
    parliament?.desc ?? '',
    area?.desc ?? '',
  ].where((value) => value.isNotEmpty).toList();
}

class PremiseListState {
  const PremiseListState({
    this.hasSearched = false,
    this.listState = AppListState.loading,
    this.items = const [],
    this.isLoadingMore = false,
    this.hasNextPage = false,
    this.nextPage = 1,
    this.errorMessage,
    this.filter = const PremiseSearchFilterSelection(),
  });

  final bool hasSearched;
  final AppListState listState;
  final List<PremiseSearchRecord> items;
  final bool isLoadingMore;
  final bool hasNextPage;
  final int nextPage;
  final String? errorMessage;
  final PremiseSearchFilterSelection filter;

  PremiseListState copyWith({
    bool? hasSearched,
    AppListState? listState,
    List<PremiseSearchRecord>? items,
    bool? isLoadingMore,
    bool? hasNextPage,
    int? nextPage,
    String? errorMessage,
    PremiseSearchFilterSelection? filter,
  }) {
    return PremiseListState(
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

enum PremiseListTab { today, history }

class PremiseListController extends FamilyNotifier<PremiseListState, PremiseListTab> {
  bool _isFetching = false;
  bool _paginationExhausted = false;

  DateTimeRange _defaultDateRangeForTab() => arg == PremiseListTab.today
      ? PremiseSearchFilterSelection.defaultDateRange()
      : PremiseSearchFilterSelection.historyDefaultDateRange();

  @override
  PremiseListState build(PremiseListTab arg) {
    ref.keepAlive();
    return PremiseListState(filter: PremiseSearchFilterSelection(dateRange: _defaultDateRangeForTab()));
  }

  String get _dateFrom => formatIsoDate((state.filter.dateRange ?? _defaultDateRangeForTab()).start);

  String get _dateTo => formatIsoDate((state.filter.dateRange ?? _defaultDateRangeForTab()).end);

  PremiseSearchFilterSelection snapshotFilter() => state.filter;

  void restoreFilter(PremiseSearchFilterSelection snapshot) {
    state = state.copyWith(filter: snapshot);
  }

  void resetFilter() {
    state = state.copyWith(filter: PremiseSearchFilterSelection(dateRange: _defaultDateRangeForTab()));
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(filter: state.filter.copyWith(dateRange: range ?? _defaultDateRangeForTab()));
  }

  void setPhase(GeneralModel? value) {
    state = state.copyWith(filter: state.filter.copyWith(phase: value, clearPhase: value == null));
  }

  void setCompanyName(String value) => state = state.copyWith(filter: state.filter.copyWith(companyName: value));

  void setTraderName(String value) => state = state.copyWith(filter: state.filter.copyWith(traderName: value));

  void setLicenseNo(String value) => state = state.copyWith(filter: state.filter.copyWith(licenseNo: value));

  void setLicenseFileNo(String value) => state = state.copyWith(filter: state.filter.copyWith(licenseFileNo: value));

  void setParliament(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        parliament: value,
        clearParliament: value == null,
        clearArea: true,
        clearStreet: true,
        clearBuilding: true,
        clearUnitNo: true,
      ),
    );
  }

  void setArea(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        area: value,
        clearArea: value == null,
        clearStreet: true,
        clearBuilding: true,
        clearUnitNo: true,
      ),
    );
  }

  void setStreet(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        street: value,
        clearStreet: value == null,
        clearBuilding: true,
        clearUnitNo: true,
      ),
    );
  }

  void setBuilding(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(building: value, clearBuilding: value == null, clearUnitNo: true),
    );
  }

  void setUnitNo(GeneralModel? value) {
    state = state.copyWith(filter: state.filter.copyWith(unitNo: value, clearUnitNo: value == null));
  }

  Future<void> search({bool isRefresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    _paginationExhausted = false;

    try {
      final keepItems = isRefresh && state.items.isNotEmpty;
      if (!keepItems) {
        state = state.copyWith(hasSearched: true, listState: AppListState.loading, errorMessage: null);
      }

      final page = await ref.read(premiseSearchRepositoryProvider).search(
            filter: state.filter.toDomainFilter(),
            dateFrom: _dateFrom,
            dateTo: _dateTo,
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
        errorMessage: error.toString().replaceFirst('ApiResponseException: ', ''),
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<void> loadMore() async {
    if (_isFetching || state.isLoadingMore || !state.hasNextPage || _paginationExhausted) return;
    _isFetching = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final requestedPage = state.nextPage;
      final page = await ref.read(premiseSearchRepositoryProvider).search(
            filter: state.filter.toDomainFilter(),
            dateFrom: _dateFrom,
            dateTo: _dateTo,
            page: requestedPage,
          );

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

final premiseSearchControllerProvider =
    NotifierProvider.family<PremiseListController, PremiseListState, PremiseListTab>(PremiseListController.new);
