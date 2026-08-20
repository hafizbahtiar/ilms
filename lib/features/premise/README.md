# Premise Feature (`ilms`)

Premise Census module for ILMS — business premise field visits: search, create, edit, duplicate, offline draft, and submit.

This feature uses clean architecture (domain / data / presentation), Riverpod, GoRouter, and Drift. Behaviour and data contracts are inherited from the legacy app in `ilms_flutter/lib/modules/premis`.

---

## Current State (this repo)

| Area | Status |
|------|--------|
| Home entry | `PremiseHomeSection` — View All, New Entry, Drafts, **Duplicate** |
| Form UI | Tab bar + scroll-sync sections (7 tabs), explicit draft save |
| Local drafts | Drift `premise_draft_entries`, list page, duplicate/delete actions |
| Duplicate search | `/premise/duplicate-search` — filter, paginated **API** search, open as draft |
| Duplicate payload | Company/contact/details only — **no images, no remarks** |
| `PremisePage` | Placeholder — mock census list only |
| Main search | Not implemented yet |
| API submit | `ApiPremiseDataSource` — create, update, photo upload |
| Lookups | `ApiGeneralLookupDataSource` — cached in Drift (`lookup:*` keys) |

**Auth required:** All premise API calls use `DioClient` with bearer token (login first).

---

## Legacy Reference

Full behaviour lives in **`ilms_flutter`**. Read the docs below before implementing.

| Doc | Contents |
|-----|----------|
| [docs/form-ui-design.md](docs/form-ui-design.md) | **Form first** — tab bar + scroll-sync sections (food-menu UX) |
| [docs/form-flow-and-states.md](docs/form-flow-and-states.md) | Form states, validation, persistence (legacy vs new UI) |
| [docs/duplicate-search.md](docs/duplicate-search.md) | **Duplicate search** — filter, searchPrevPhase, draft rules |
| [docs/legacy-overview.md](docs/legacy-overview.md) | Legacy module layout, controllers, screens, navigation |
| [docs/local-persistence.md](docs/local-persistence.md) | SQLite schema, drafts, edit sessions, retry queue, photo upload |
| [docs/general-module-integration.md](docs/general-module-integration.md) | Shared lookup data, API + Drift cache |
| [docs/migration-plan.md](docs/migration-plan.md) | Mapping legacy → `ilms` target structure |

Legacy source README: `ilms_flutter/lib/modules/premis/README.md`  
Legacy duplicate reference: `ilms_flutter/lib/modules/premis/premis_duplicate_search_view.dart`

Session log (2026-08-20): [`docs/sessions/2026-08-20-premise-api-and-duplicate.md`](../../../docs/sessions/2026-08-20-premise-api-and-duplicate.md)

---

## Target Structure (`ilms`)

```
lib/features/premise/
├── README.md
├── docs/
├── domain/
│   ├── entities/
│   └── repositories/
├── data/
│   ├── datasources/
│   │   ├── api_premise_data_source.dart
│   │   ├── api_premise_duplicate_remote_data_source.dart
│   │   ├── mock_* (tests only)
│   │   └── local/premise_draft_local_data_source.dart
│   ├── mappers/
│   │   ├── premise_draft_mapper.dart
│   │   ├── premise_detail_mapper.dart
│   │   └── premise_form_mapper.dart
│   ├── models/
│   └── repositories/
└── presentation/
    ├── pages/
    │   ├── premise_form_page.dart
    │   ├── premise_drafts_page.dart
    │   └── premise_duplicate_page.dart
    ├── widgets/
    │   ├── premise_home_section.dart
    │   ├── premise_duplicate_filter_sheet.dart
    │   ├── premise_duplicate_record_tile.dart
    │   └── premise_form_exit_sheet.dart
    ├── controllers/
    │   ├── premise_duplicate_controller.dart
    │   └── premise_form_state.dart
    ├── sections/
    └── providers/
```

Shared network helpers used by premise API:

- `lib/core/network/form_data_builder.dart` — nested FormData for create/update/photo
- `lib/core/network/api_response_helper.dart` — status/message parsing

Principles carried forward from legacy:

- **Offline-first drafts** — explicit Save / Save & exit (no silent auto-save on back).
- **Duplicate from previous phase** — address filter → search → eligibility → detail → local draft.
- **Duplicate omits photos & remarks** — user re-captures images and enters remarks fresh.
- **General lookups** — dropdown values from API with Drift cache for offline reuse.

---

## Key User Flows

```
Home → Premise group
  ├── View All → /module/premise (placeholder list)
  ├── New Entry → /premise/form?mode=create
  ├── Drafts → /premise/drafts
  └── Duplicate → /premise/duplicate-search
        └── Filter → search → pick record → confirm
              └── checkDuplicatePhase → detail → Drift draft → form
```

| Action | Legacy screen | Route |
|--------|---------------|-------|
| View All | `PremisSearchView` | `/module/premise` |
| New Entry | `PremisFormView` (create) | `/premise/form?mode=create` |
| Drafts | `PremisDraftSheet` | `/premise/drafts` |
| Duplicate | `PremisDuplicateSearchView` | `/premise/duplicate-search` |

---

## API Layer (production)

| Concern | Class | Provider |
|---------|-------|----------|
| Duplicate search / detail | `ApiPremiseDuplicateRemoteDataSource` | `premiseDuplicateRemoteDataSourceProvider` |
| Create / update / photo | `ApiPremiseDataSource` | `premiseDataSourceProvider` |
| Lookups | `ApiGeneralLookupDataSource` | `generalLookupDataSourceProvider` |

Mock implementations (`MockPremiseDataSource`, `MockPremiseDuplicateRemoteDataSource`, `MockGeneralLookupDataSource`) are **not** wired in production — tests only.

---

## Related Code (this repo)

| File | Role |
|------|------|
| `lib/features/premise/presentation/widgets/premise_home_section.dart` | Premise home buttons + last draft card |
| `lib/app/router/app_router.dart` | Premise routes |
| `lib/core/local/database/app_database.dart` | Drift DB incl. `premise_draft_entries` |
| `lib/shared/lookups/` | Shared lookup repository + API data source |
| `lib/shared/ui/app_bars/app_search_app_bar.dart` | Duplicate search app bar |
| `lib/shared/ui/lists/app_list_view.dart` | Paginated / empty / error list scaffold |

---

## Implementation Order

### Done

1. Form UI shell + section files
2. Drift drafts + draft list page
3. Exit bottom sheet (Save & exit / Delete draft / Exit without saving)
4. Duplicate search page + session-scoped controller
5. Wire real API — duplicate search, check, detail, create/update, photo upload
6. Shared lookups via API + Drift cache
7. Duplicate detail excludes census images and remarks

### Next

8. Main premise search page (`PremisSearchView`)
9. View / edit modes with full detail load
10. Edit session + pending submission retry pipeline
11. Wire license, address, business activity, remarks sections (beyond placeholders)

---

## Tests

- `test/features/premise/data/premise_draft_repository_impl_test.dart`
- `test/features/premise/data/premise_draft_mapper_test.dart`
- `test/features/premise/data/premise_detail_mapper_test.dart`
- `test/features/premise/data/mock_premise_duplicate_remote_data_source_test.dart`
- `test/features/premise/presentation/premise_duplicate_controller_test.dart`

Legacy has extensive premise tests under `ilms_flutter/test/premis/` — port critical cases when wiring edit sessions and full submit payloads.
