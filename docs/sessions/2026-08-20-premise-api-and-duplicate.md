# Session — Premise API wiring & duplicate rules

**Date:** 2026-08-20  
**Scope:** Switch premise feature from mock to real API; refine duplicate payload rules.

---

## Goals

1. Use production API for premise (not mock) — duplicate search, submit, lookups.
2. Duplicate flow must **not** copy census images or remarks from source record.

---

## Completed

### API providers (mock → API)

| Provider | Implementation |
|----------|----------------|
| `premiseDuplicateRemoteDataSourceProvider` | `ApiPremiseDuplicateRemoteDataSource` |
| `premiseDataSourceProvider` | `ApiPremiseDataSource` |
| `generalLookupDataSourceProvider` | `ApiGeneralLookupDataSource` |

Mock classes remain for unit tests only.

### New shared / data files

| File | Role |
|------|------|
| `lib/core/network/form_data_builder.dart` | Nested multipart FormData (legacy `DioFormdataMixin` parity) |
| `lib/core/network/api_response_helper.dart` | `{status, message}` parsing + Dio error extraction |
| `lib/features/premise/data/mappers/premise_detail_mapper.dart` | Map `/api/premiseCensus/detail` → `PremiseDraftPayloadModel` |

### Endpoints wired

| Action | Endpoint |
|--------|----------|
| Duplicate search | `POST /api/premiseCensus/searchPrevPhase` |
| Eligibility | `POST /api/premiseCensus/checkDuplicatePhase` |
| Detail (duplicate) | `POST /api/premiseCensus/detail` |
| Create / update | `POST /api/premiseCensus/create` / `update` |
| Photo upload | `POST /api/premiseCensus/create-photo` |
| Lookups | `/api/listState`, `/api/listParliament`, `/api/searchAreaByParliament`, etc. |

### Duplicate payload rules

- `PremiseDetailMapper.fromApiDetailForDuplicate()` — company/contact/premise text fields only.
- **Excluded:** `images[]`, `remarks[]` (user captures new photos and adds remarks manually).
- Full detail mapping (`fromApiDetail`) kept for future view/edit flows.

### Other

- Photo upload passes `process: 'create' | 'update'` to match legacy.
- Exit confirmation uses bottom sheet (`premise_form_exit_sheet.dart`).
- Duplicate search uses `AppSearchAppBar`, cached lookups, `AppBottomSheetActionBar`.
- Session-scoped duplicate controller (`ref.keepAlive()`).

---

## Tests

124 tests passing (includes `premise_detail_mapper_test.dart`).

---

## Not in scope (next sessions)

- Main premise search page (`PremisSearchView` / `/premise/search`)
- View / edit modes with full detail load
- Edit session + pending submission retry pipeline
- Remarks / license / address / business activity sections (UI placeholders)
- `PremisePage` placeholder list still mock

---

## Key references

- Feature README: `lib/features/premise/README.md`
- Duplicate doc: `lib/features/premise/docs/duplicate-search.md`
- Legacy repo: `ilms_flutter/lib/data/network/repositories/premis_repo.dart`
