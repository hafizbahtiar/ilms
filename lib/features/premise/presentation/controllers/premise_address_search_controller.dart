import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_address_filter.dart';
import 'package:ilms/features/premise/domain/entities/premise_address_listing.dart';
import 'package:ilms/features/premise/presentation/providers/premise_address_listing_providers.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

/// UI filter for premise address catalog search (legacy cascade).
class PremiseAddressSearchFilterSelection {
  const PremiseAddressSearchFilterSelection({
    this.parliament,
    this.area,
    this.street,
    this.building,
    this.unitQuery = '',
  });

  final GeneralModel? parliament;
  final GeneralModel? area;
  final GeneralModel? street;
  final GeneralModel? building;
  final String unitQuery;

  PremiseAddressSearchFilterSelection copyWith({
    GeneralModel? parliament,
    GeneralModel? area,
    GeneralModel? street,
    GeneralModel? building,
    String? unitQuery,
    bool clearParliament = false,
    bool clearArea = false,
    bool clearStreet = false,
    bool clearBuilding = false,
  }) {
    return PremiseAddressSearchFilterSelection(
      parliament: clearParliament ? null : (parliament ?? this.parliament),
      area: clearArea ? null : (area ?? this.area),
      street: clearStreet ? null : (street ?? this.street),
      building: clearBuilding ? null : (building ?? this.building),
      unitQuery: unitQuery ?? this.unitQuery,
    );
  }

  PremiseAddressFilter toQueryFilter({required int page}) {
    return PremiseAddressFilter(
      page: page,
      unit: unitQuery.trim().isEmpty ? null : unitQuery.trim(),
      parliamentCode: parliament?.code,
      areaCode: area?.code,
      streetCode: street?.code,
      buildingCode: building?.code,
    );
  }
}

class PremiseAddressSearchState {
  const PremiseAddressSearchState({
    this.listState = AppListState.empty,
    this.items = const [],
    this.selected = const [],
    this.isLoadingMore = false,
    this.hasNextPage = false,
    this.nextPage = 1,
    this.errorMessage,
    this.filter = const PremiseAddressSearchFilterSelection(),
  });

  final AppListState listState;
  final List<PremiseAddressListing> items;
  final List<PremiseAddressListing> selected;
  final bool isLoadingMore;
  final bool hasNextPage;
  final int nextPage;
  final String? errorMessage;
  final PremiseAddressSearchFilterSelection filter;

  PremiseAddressSearchState copyWith({
    AppListState? listState,
    List<PremiseAddressListing>? items,
    List<PremiseAddressListing>? selected,
    bool? isLoadingMore,
    bool? hasNextPage,
    int? nextPage,
    String? errorMessage,
    PremiseAddressSearchFilterSelection? filter,
  }) {
    return PremiseAddressSearchState(
      listState: listState ?? this.listState,
      items: items ?? this.items,
      selected: selected ?? this.selected,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      nextPage: nextPage ?? this.nextPage,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

class PremiseAddressSearchController extends AutoDisposeNotifier<PremiseAddressSearchState> {
  bool _isFetching = false;
  Timer? _unitDebounce;

  @override
  PremiseAddressSearchState build() {
    ref.onDispose(() => _unitDebounce?.cancel());
    return const PremiseAddressSearchState();
  }

  PremiseAddressSearchFilterSelection snapshotFilter() => state.filter;

  void restoreFilter(PremiseAddressSearchFilterSelection snapshot) {
    state = state.copyWith(filter: snapshot);
  }

  void initialize({
    required List<PremiseAddress> initialAddresses,
    GeneralModel? companyArea,
    String? companyStreet1,
    String? companyStreet2,
  }) {
    final selected = initialAddresses
        .where((address) => address.premiseAddressId != null)
        .map(PremiseAddressListing.fromDomain)
        .where((item) => item.id > 0)
        .toList();

    state = PremiseAddressSearchState(
      selected: selected,
      filter: PremiseAddressSearchFilterSelection(area: companyArea),
    );

    unawaited(_fetch(page: 1));
    unawaited(
      _matchCompanyStreet(companyArea: companyArea, companyStreet1: companyStreet1, companyStreet2: companyStreet2),
    );
  }

  void setParliament(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        parliament: value,
        clearParliament: value == null,
        clearArea: true,
        clearStreet: true,
        clearBuilding: true,
      ),
    );
  }

  void setArea(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(area: value, clearArea: value == null, clearStreet: true, clearBuilding: true),
    );
  }

  void setStreet(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(street: value, clearStreet: value == null, clearBuilding: true),
    );
  }

  void setBuilding(GeneralModel? value) {
    state = state.copyWith(
      filter: state.filter.copyWith(building: value, clearBuilding: value == null),
    );
  }

  void setUnitQuery(String value) {
    state = state.copyWith(filter: state.filter.copyWith(unitQuery: value));
    _unitDebounce?.cancel();
    _unitDebounce = Timer(const Duration(milliseconds: 1500), () => _fetch(page: 1));
  }

  void resetFilter() {
    state = state.copyWith(filter: const PremiseAddressSearchFilterSelection());
  }

  void toggleSelection(PremiseAddressListing item) {
    final next = List<PremiseAddressListing>.of(state.selected);
    final index = next.indexWhere((selected) => selected.id == item.id);
    if (index >= 0) {
      next.removeAt(index);
    } else {
      next.add(item);
    }
    state = state.copyWith(selected: next);
  }

  bool isSelected(PremiseAddressListing item) => state.selected.any((selected) => selected.id == item.id);

  Future<void> applyFilter() => _fetch(page: 1);

  Future<void> refresh() => _fetch(page: 1);

  Future<void> loadMore() async {
    if (_isFetching || state.isLoadingMore || !state.hasNextPage) return;
    _isFetching = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final page = await ref
          .read(premiseAddressListingRepositoryProvider)
          .search(state.filter.toQueryFilter(page: state.nextPage));

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

  List<PremiseAddress> selectedAsDomain({required List<PremiseAddress> existingAddresses}) {
    final existingById = {
      for (final address in existingAddresses)
        if (address.premiseAddressId != null) address.premiseAddressId!: address,
    };

    return state.selected.map((listing) => listing.toDomain(existing: existingById[listing.id])).toList();
  }

  Future<void> _fetch({required int page}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (page == 1) {
      state = state.copyWith(listState: AppListState.loading, errorMessage: null);
    }

    try {
      final result = await ref
          .read(premiseAddressListingRepositoryProvider)
          .search(state.filter.toQueryFilter(page: page));

      state = state.copyWith(
        listState: result.items.isEmpty ? AppListState.empty : AppListState.content,
        items: result.items,
        hasNextPage: result.hasNextPage,
        nextPage: result.nextPage,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(listState: AppListState.error, errorMessage: error.toString());
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _matchCompanyStreet({GeneralModel? companyArea, String? companyStreet1, String? companyStreet2}) async {
    final areaCode = companyArea?.code;
    final keyword = (companyStreet1?.trim().isNotEmpty ?? false) ? companyStreet1!.trim() : companyStreet2?.trim();
    if (areaCode == null || areaCode.isEmpty || keyword == null || keyword.isEmpty) return;

    try {
      final streets = await ref.read(generalLookupRepositoryProvider).getStreets(areaCode, search: keyword);
      final matched = streets.isNotEmpty ? streets.first : null;
      if (matched == null) return;

      state = state.copyWith(filter: state.filter.copyWith(street: matched));
      await _fetch(page: 1);
    } catch (_) {
      // Best-effort pre-filter — listing still works with area-only filter.
    }
  }
}

final premiseAddressSearchControllerProvider =
    NotifierProvider.autoDispose<PremiseAddressSearchController, PremiseAddressSearchState>(
      PremiseAddressSearchController.new,
    );
