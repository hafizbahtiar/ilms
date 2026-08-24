import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_search_filter.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_search_record.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_search_providers.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

/// Filter selection for the billboard search sheet — mirrors the 9 filters
/// the design doc lists (`BillboardSearchFilter`).
class BillboardSearchFilterSelection {
  const BillboardSearchFilterSelection({
    this.dateRange,
    this.billType,
    this.ledBoard,
    this.mediaOwner = '',
    this.mediaOwnerClient = '',
    this.street = '',
    this.parliament,
    this.phase,
    this.assetOwner,
  });

  final DateTimeRange? dateRange;
  final GeneralModel? billType;
  final GeneralModel? ledBoard;
  final String mediaOwner;
  final String mediaOwnerClient;
  final String street;
  final GeneralModel? parliament;
  final GeneralModel? phase;
  final GeneralModel? assetOwner;

  /// Anchor point for opening the date-range picker when nothing is picked
  /// yet — purely a UI default for the picker widget itself. Does NOT mean
  /// a date filter is active: legacy sends no date bounds at all until the
  /// user actually picks a range (`billDateRange` starts `null`), and
  /// [toDomainFilter] mirrors that by leaving `dateFrom`/`dateTo` empty
  /// while [dateRange] is null.
  static DateTimeRange defaultDateRange([DateTime? now]) {
    final today = now ?? DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    return DateTimeRange(start: normalized.subtract(const Duration(days: 7)), end: normalized);
  }

  /// Empty until the user actually picks a range — never implies an active
  /// filter that wasn't explicitly chosen.
  String get dateRangeLabel {
    final range = dateRange;
    if (range == null) return '';
    return '${formatIsoDate(range.start)} - ${formatIsoDate(range.end)}';
  }

  BillboardSearchFilterSelection copyWith({
    DateTimeRange? dateRange,
    GeneralModel? billType,
    GeneralModel? ledBoard,
    String? mediaOwner,
    String? mediaOwnerClient,
    String? street,
    GeneralModel? parliament,
    GeneralModel? phase,
    GeneralModel? assetOwner,
    bool clearBillType = false,
    bool clearLedBoard = false,
    bool clearParliament = false,
    bool clearPhase = false,
    bool clearAssetOwner = false,
  }) {
    return BillboardSearchFilterSelection(
      dateRange: dateRange ?? this.dateRange,
      billType: clearBillType ? null : (billType ?? this.billType),
      ledBoard: clearLedBoard ? null : (ledBoard ?? this.ledBoard),
      mediaOwner: mediaOwner ?? this.mediaOwner,
      mediaOwnerClient: mediaOwnerClient ?? this.mediaOwnerClient,
      street: street ?? this.street,
      parliament: clearParliament ? null : (parliament ?? this.parliament),
      phase: clearPhase ? null : (phase ?? this.phase),
      assetOwner: clearAssetOwner ? null : (assetOwner ?? this.assetOwner),
    );
  }

  BillboardSearchFilter toDomainFilter() {
    // No date bounds at all until the user picks one — matches legacy
    // (`billDateRange?.start… .orEmpty()`), which does not default to any
    // implicit range. Silently scoping every fresh page-load to "last 7
    // days" hid most records behind an unrequested filter.
    final range = dateRange;
    return BillboardSearchFilter(
      billType: billType?.code ?? '',
      dateFrom: range == null ? '' : formatIsoDate(range.start),
      dateTo: range == null ? '' : formatIsoDate(range.end),
      ledBoard: ledBoard?.code ?? '',
      mediaOwner: mediaOwner.trim(),
      mediaOwnerClient: mediaOwnerClient.trim(),
      assetOwner: assetOwner?.code ?? '',
      street: street.trim(),
      parliament: parliament?.code ?? '',
      phase: phase?.code ?? '',
    );
  }

  List<String> get activeChipLabels => [
    dateRangeLabel,
    billType?.desc ?? '',
    ledBoard?.desc ?? '',
    mediaOwner.trim(),
    mediaOwnerClient.trim(),
    street.trim(),
    parliament?.desc ?? '',
    phase?.desc ?? '',
    assetOwner?.desc ?? '',
  ].where((value) => value.isNotEmpty).toList();
}

class BillboardListState {
  const BillboardListState({
    this.listState = AppListState.loading,
    this.items = const [],
    this.isLoadingMore = false,
    this.hasNextPage = false,
    this.nextPage = 1,
    this.errorMessage,
    this.filter = const BillboardSearchFilterSelection(),
  });

  final AppListState listState;
  final List<BillboardSearchRecord> items;
  final bool isLoadingMore;
  final bool hasNextPage;
  final int nextPage;
  final String? errorMessage;
  final BillboardSearchFilterSelection filter;

  BillboardListState copyWith({
    AppListState? listState,
    List<BillboardSearchRecord>? items,
    bool? isLoadingMore,
    bool? hasNextPage,
    int? nextPage,
    String? errorMessage,
    BillboardSearchFilterSelection? filter,
  }) {
    return BillboardListState(
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

class BillboardListController extends Notifier<BillboardListState> {
  bool _isFetching = false;
  bool _paginationExhausted = false;

  @override
  BillboardListState build() {
    ref.keepAlive();
    return const BillboardListState();
  }

  BillboardSearchFilterSelection snapshotFilter() => state.filter;

  void restoreFilter(BillboardSearchFilterSelection snapshot) {
    state = state.copyWith(filter: snapshot);
  }

  void resetFilter() {
    state = state.copyWith(filter: const BillboardSearchFilterSelection());
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(filter: state.filter.copyWith(dateRange: range));
  }

  void setBillType(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(billType: value, clearBillType: value == null),
    );
  }

  void setLedBoard(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(ledBoard: value, clearLedBoard: value == null),
    );
  }

  void setMediaOwner(String value) => state = state.copyWith(filter: state.filter.copyWith(mediaOwner: value));

  void setMediaOwnerClient(String value) =>
      state = state.copyWith(filter: state.filter.copyWith(mediaOwnerClient: value));

  void setStreet(String value) => state = state.copyWith(filter: state.filter.copyWith(street: value));

  void setParliament(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(parliament: value, clearParliament: value == null),
    );
  }

  void setPhase(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(phase: value, clearPhase: value == null),
    );
  }

  void setAssetOwner(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(assetOwner: value, clearAssetOwner: value == null),
    );
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

      final page = await ref
          .read(billboardSearchRepositoryProvider)
          .search(filter: state.filter.toDomainFilter(), page: 1);

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
    if (_isFetching || state.isLoadingMore || !state.hasNextPage || _paginationExhausted) return;
    _isFetching = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final requestedPage = state.nextPage;
      final page = await ref
          .read(billboardSearchRepositoryProvider)
          .search(filter: state.filter.toDomainFilter(), page: requestedPage);

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

final billboardListControllerProvider = NotifierProvider<BillboardListController, BillboardListState>(
  BillboardListController.new,
);
