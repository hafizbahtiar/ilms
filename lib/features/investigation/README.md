# Investigation Feature (`ilms`)

Investigation (Siasatan) module for ILMS — inspection case management for
premises already on file. Unlike premise/billboard, cases **originate
elsewhere** (a separate case-management system); the mobile app only
searches, views, and edits existing investigations.

This feature uses clean architecture (domain / data / presentation),
Riverpod, GoRouter, and Drift. Behaviour and data contracts are inherited
from the legacy app in `ilms_flutter/lib/modules/siasatan`.

Design spec:
[`docs/superpowers/specs/2026-08-24-investigation-feature-design.md`](../../../docs/superpowers/specs/2026-08-24-investigation-feature-design.md)

---

## Current State (this repo)

| Area | Status |
|------|--------|
| Home entry | `InvestigationHomeSection` — View All (search), History |
| List | `InvestigationListPage` — shared search/history list, mode flag toggles the filter sheet |
| Form UI | Tab bar + scroll-sync sections (5 tabs): Applicant (read-only), Parlimen & Kawasan (read-only), Premis (editable), Photos, Minit |
| Edit-session drafts | Drift `investigation_draft_entries` — one row per investigation_no, JSON blob incl. pending photo bytes; Save & Exit sheet |
| API submit | `ApiInvestigationDataSource` — update, photo upload |
| Create flow | **Not built** — legacy has no working create path (dead code) |
| Senarai Kerja (work list) | **Not built** — legacy UI is unfinished/commented out; backend endpoints undocumented here |
| Dashboard analytics | **Not built** — legacy charts are hardcoded mock data |

**Auth required:** All investigation API calls use `DioClient` with bearer
token (login first). Route/home-section permission id: `view-mobile-investigation`.

---

## Target Structure (`ilms`)

```
lib/features/investigation/
├── README.md
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── exceptions/
├── data/
│   ├── datasources/
│   │   ├── api_investigation_data_source.dart
│   │   ├── api_investigation_detail_remote_data_source.dart
│   │   ├── api_investigation_search_remote_data_source.dart
│   │   ├── mock_* (tests only)
│   │   └── local/investigation_draft_local_data_source.dart
│   ├── mappers/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── pages/
    ├── sections/
    ├── widgets/
    ├── controllers/
    └── providers/
```

---

## Key User Flows

```
Home → Investigation group
  ├── View All → /investigation/list?mode=search
  └── History  → /investigation/list?mode=history
        └── tap a record → detail fetch → /investigation/form (view)
              └── Edit → edit 5-section form
                    ├── Save & Exit → local draft (Drift)
                    ├── Discard changes → delete local draft
                    └── Submit → update API → photo upload → back to list
```

| Action | Legacy screen | Route |
|--------|---------------|-------|
| View All | `SiasatanSearchView` | `/investigation/list?mode=search` |
| History | `SiasatanHistoryView` | `/investigation/list?mode=history` |
| View/Edit | `SiasatanFormView` | `/investigation/form?investigationNo=&mode=view\|edit` |
| Drafts | (new, no legacy equivalent screen) | `/investigation/drafts` |

---

## API Layer (production)

| Concern | Class | Provider |
|---------|-------|----------|
| Search / history | `ApiInvestigationSearchRemoteDataSource` | `investigationSearchRemoteDataSourceProvider` |
| Detail fetch | `ApiInvestigationDetailRemoteDataSource` | `investigationDetailRemoteDataSourceProvider` |
| Update / photo upload | `ApiInvestigationDataSource` | `investigationDataSourceProvider` |

Mock implementations (`MockInvestigationDataSource`,
`MockInvestigationSearchRemoteDataSource`) are **not** wired in production —
tests only.

---

## Not Built (see design spec's Non-goals)

- Create-case flow (legacy dead code — `SiasatanCreatePostModel`, `/create`)
- Senarai Kerja (work list) — backend endpoints exist, legacy UI unfinished
- Dashboard analytics charts — no real endpoint, legacy is mock data
- Documents section — modeled in the API response, no legacy screen renders it
- Cross-restart photo-upload retry queue — legacy explicitly cut this scope

---

## Tests

- `test/features/investigation/data/investigation_detail_mapper_test.dart`
- `test/features/investigation/data/investigation_draft_mapper_test.dart`
- `test/features/investigation/data/investigation_submit_payload_model_test.dart`
