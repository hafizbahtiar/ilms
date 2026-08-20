# General Module Integration

Shared lookup/dropdown data used across Premise (and Billboard, Investigation) in legacy.

---

## Location

```
ilms_flutter/lib/modules/general/
├── controller/general_controller.dart   # Main API
├── controller/dropdown_provider.dart
└── home/home_view.dart                  # Module launcher

ilms_flutter/lib/data/network/
├── repositories/general_repo.dart
└── model/general_model.dart

ilms_flutter/lib/data/local/.../master/
└── master_data_local_datasource.dart    # Offline fallback
```

`ilms` already has `lib/shared/models/general_model.dart` with the same `{ code, desc, type }` shape.

---

## `GeneralController` Behaviour

Singleton-style `ChangeNotifier` that:

1. Fetches lookup lists from API by `GeneralDataType` enum.
2. Caches results in memory (`Map<GeneralDataType, List<GeneralModel>>`).
3. Shows dropdown via `CustomDropdownSheet` with adaptive height:
   - Short lists (≤8 items, e.g. Yes/No) — compact sheet, no search.
   - Long lists — 70% height + search filter.
4. On `DioException` connection error → falls back to `MasterDataLocalDatasource.getDataByTable()`.

Useful sync helpers:

- `cachedListData(type)` — read cache without await
- `resolveLabel(type, code)` — code → description for display
- `clearCache` / `clearAllCache`

---

## Premise Usage

Section controllers call `GeneralController.show()` or `getListData()` for fields such as:

- Visit status, business type, premise type
- Parliament / area / postcode cascades (some via dedicated address API)
- Remark codes
- Yes/No toggles (`GeneralDataType` yes/no shortcut — always 2 items)

Address search is a **separate sub-flow** (`PremisManageAddressController`, `premis_address_search_view.dart`) — not part of GeneralController.

---

## Offline Master Data

Master tables synced to SQLite for offline dropdown fallback. Legacy maps `GeneralDataType` → master table name via `type.getMasterTable()`.

When porting to `ilms`:

| Concern | Suggestion |
|---------|------------|
| API | `GeneralRepository` + `ApiGeneralDataSource` |
| Cache | In-memory provider + optional Drift master tables |
| UI | Reuse app bottom sheet / dialog patterns from `lib/shared/widgets/` |
| Type safety | Replace stringly `GeneralDataType` enum with sealed class or codegen |

Premise form sections should depend on **`GeneralRepository` abstraction**, not concrete API — same loose-coupling pattern as home menu mock → API swap.

---

## Home Module Launcher Pattern

Legacy `HomeView` builds permission-filtered `HomeItem` list → each opens a modal (`PremisHomeModal`, etc.) with action grid.

`ilms` equivalent (already started):

- `HomeModuleGroup` + `HomeModuleItem` in home feature
- Premise group items: View All, New Entry, Drafts (routes TBD)

Legacy `PremisHomeModal` actions map directly to home items:

| Legacy modal | Home item (mock) |
|--------------|------------------|
| Carian Bancian | View All |
| (FAB on search) New | New Entry |
| Draft counter | Drafts |
| Sejarah Bancian | History (not in mock yet) |

---

## Target (`ilms`)

```
lib/features/general/          # or lib/shared/lookups/
├── domain/
│   └── repositories/general_repository.dart
├── data/
│   ├── api_general_data_source.dart
│   └── local_master_data_source.dart
└── presentation/
    └── providers/general_lookup_provider.dart
```

Premise sections inject lookup provider — never import API client directly.
