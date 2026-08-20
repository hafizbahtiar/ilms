# Duplicate Search

Clone an existing **previous-phase** premise record into a new local draft form.

Legacy reference: `ilms_flutter/lib/modules/premis/premis_duplicate_search_view.dart`

---

## User flow

```
Home → Premise → Duplicate
  └── Filter sheet (auto-opens on first visit)
        └── Apply → searchPrevPhase list
              └── Tap record → confirm dialog
                    └── checkCanDuplicate → load detail → save draft → open form
```

| Step | Legacy | `ilms` |
|------|--------|--------|
| Entry | Home modal action | Home `Duplicate` button → `/premise/duplicate-search` |
| Filter | `PremisDuplicateFilterModal` (address only) | `showPremiseDuplicateFilterSheet` |
| Search API | `PremisRepo.searchPrevPhase` | `PremiseDuplicateRepository.searchPreviousPhase` |
| Eligibility + draft | `duplicateFromSearch()` | `PremiseDuplicateRepository.createDraftFromRecord()` |

---

## What gets duplicated

When detail is loaded for duplicate, **`PremiseDetailMapper.fromApiDetailForDuplicate`** maps only:

| Copied | Not copied |
|--------|------------|
| Company & contact text fields | Census images |
| Premise details (trader, types, dimensions) | Remarks |
| State/postcode codes (for lookup cascade) | Server IDs (`visit_no`, row ids) |

User must capture new photos and add remarks manually after duplicate — same intent as legacy (duplicate mode does not pre-fill census images).

Full detail mapping (`fromApiDetail`) is reserved for future view/edit flows and **includes** images.

---

## Filter fields

Duplicate search exposes **address criteria only** (legacy hides company/trader/license text fields):

1. Parliament
2. Area (requires parliament)
3. Street (requires area)
4. Building (requires street)
5. Unit No. (requires building or street)

Filter sends **description** values to API (`GeneralModel.desc`), matching legacy `PremisSearchFilter`.

Cascading lookups are fetched via shared lookup providers (`generalParliamentsProvider`, `generalStreetsProvider`, etc.) backed by `ApiGeneralLookupDataSource`.

Filter state persists in `PremiseDuplicateController` across visits (legacy parity):

- **First visit** (`hasSearched == false`): filter starts empty; sheet auto-opens once.
- **Return visit** with results already loaded: sheet is **not** forced open; filter + list stay as left.
- **Cancel / close sheet without Apply**: snapshot taken before open is restored.
- **Reset** inside sheet clears working filter only; **Apply** commits and runs search.

Lookup lists are cached locally in Drift (`lookup:*` keys). Use the refresh icon in the filter sheet header to refetch from API (`refreshAllGeneralLookups`).

Filter sheet uses shared [`AppBottomSheetActionBar`](../../../shared/ui/sheets/app_bottom_sheet_action_bar.dart) pinned at the bottom (legacy `BottomActionBar`).

Search list uses [`AppSearchAppBar`](../../../shared/ui/app_bars/app_search_app_bar.dart) with filter chips.

---

## API endpoints (production)

| Action | Endpoint | Notes |
|--------|----------|-------|
| Search | `POST /api/premiseCensus/searchPrevPhase` | FormData body + `page` / `per_page` query |
| Eligibility | `POST /api/premiseCensus/checkDuplicatePhase` | JSON `{ visit_no }` — `is_current_phase == false` → allowed |
| Detail | `POST /api/premiseCensus/detail` | FormData `{ visit_no }` → `fromApiDetailForDuplicate` |

Production wiring: `ApiPremiseDuplicateRemoteDataSource` via `premiseDuplicateRemoteDataSourceProvider`.

FormData encoding: `lib/core/network/form_data_builder.dart` (nested bracket notation for create/update parity).

Mock implementations remain for unit tests only: `MockPremiseDuplicateRemoteDataSource`, catalog in `mock_premise_duplicate_remote_data_source.dart`.

---

## Key files

| File | Role |
|------|------|
| `presentation/pages/premise_duplicate_page.dart` | Search list + idle state |
| `presentation/controllers/premise_duplicate_controller.dart` | Session-scoped filter + results (`keepAlive`) |
| `presentation/widgets/premise_duplicate_filter_sheet.dart` | Address filter bottom sheet |
| `presentation/widgets/premise_duplicate_record_tile.dart` | Result row UI |
| `presentation/providers/premise_duplicate_providers.dart` | Repository wiring (API) |
| `domain/repositories/premise_duplicate_repository.dart` | Duplicate search + create draft |
| `data/datasources/api_premise_duplicate_remote_data_source.dart` | API implementation |
| `data/datasources/premise_duplicate_remote_data_source.dart` | Abstract remote layer |
| `data/repositories/premise_duplicate_repository_impl.dart` | DTO → domain + draft orchestration |
| `data/mappers/premise_detail_mapper.dart` | Detail JSON → draft payload |

---

## Tests

- `test/features/premise/data/premise_detail_mapper_test.dart`
- `test/features/premise/data/mock_premise_duplicate_remote_data_source_test.dart`
- `test/features/premise/presentation/premise_duplicate_controller_test.dart`
