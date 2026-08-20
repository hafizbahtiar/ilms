# Migration Plan — Legacy → `ilms`

Practical mapping from `ilms_flutter` premise module to this codebase.

**Current priority:** Form UI first ([form-ui-design.md](form-ui-design.md)) — tab bar + scroll sections, one file per section.

---

## Stack Comparison

| Layer | Legacy (`ilms_flutter`) | Target (`ilms`) |
|-------|---------------------------|-----------------|
| State | Provider + ChangeNotifier | Riverpod (Notifier / AsyncNotifier) |
| Navigation | Imperative Navigator + routes enum | GoRouter |
| Form UX | 7-page wizard (`PageController`) | Single scroll + sticky tab bar |
| DI | `providers.dart` multi-provider | Riverpod providers |
| Network | Dio + `PremisRepo` | Existing `DioClient` + feature repository |
| Local DB | Drift (premise tables in shared DB) | Extend `AppDatabase` (later phase) |
| Auth | `AuthController` | `authControllerProvider` |
| UI chrome | Custom components (`ils_bancian/components/`) | `lib/shared/widgets/` |

---

## File Mapping

| Legacy | Target (proposed) |
|--------|-------------------|
| `modules/premis/premis_form_view.dart` | `presentation/pages/premise_form_page.dart` |
| `modules/premis/sections/premis_comp_details_section.dart` | `presentation/sections/company_contact_section.dart` |
| `modules/premis/sections/premis_detail_section.dart` | `presentation/sections/premise_details_section.dart` |
| `modules/premis/sections/premis_address_section.dart` | `presentation/sections/premise_address_section.dart` |
| `modules/premis/sections/premis_license_section.dart` | `presentation/sections/license_section.dart` |
| `modules/premis/sections/premis_business_activity_section.dart` | `presentation/sections/business_activity_section.dart` |
| `modules/premis/sections/premis_remark_section.dart` | `presentation/sections/remarks_section.dart` |
| `modules/premis/sections/premis_census_image_section.dart` | `presentation/sections/census_images_section.dart` |
| — | `presentation/sections/premise_form_sections.dart` (registry) |
| — | `presentation/widgets/premise_form_tab_bar.dart` |
| `modules/premis/premis_duplicate_search_view.dart` | `presentation/pages/premise_duplicate_search_page.dart` |
| `modules/premis/premis_duplicate_filter_modal.dart` | `presentation/widgets/premise_duplicate_filter_sheet.dart` |
| `modules/premis/controllers/premis_duplicate_search_controller.dart` | `presentation/providers/premise_duplicate_search_providers.dart` |
| `modules/premis/premis_draft_sheet.dart` | `presentation/widgets/premise_draft_sheet.dart` |
| `modules/premis/premis_history_view.dart` | `presentation/pages/premise_history_page.dart` |
| `modules/premis/controllers/premis_form_controller.dart` | `presentation/controllers/premise_form_controller.dart` |
| `modules/premis/models/premis_input_model.dart` | `data/models/` + `domain/entities/` |
| `data/.../premis_data_local_datasource.dart` | `data/datasources/local/premise_local_datasource.dart` |
| `data/network/repositories/premis_repo.dart` | `api_premise_data_source.dart` + `api_premise_duplicate_remote_data_source.dart` + repositories ✅ |
| `modules/general/controller/general_controller.dart` | `lib/shared/lookups/` + `ApiGeneralLookupDataSource` ✅ |

---

## Route Plan

Current:

```
/module/premise              →  PremisePage (placeholder)
/premise/form                →  PremiseFormPage (?mode, ?localId, ?i)
/premise/drafts              →  PremiseDraftsPage
/premise/duplicate-search    →  PremiseDuplicateSearchPage  ✅
```

Still planned:

```
/premise/search              # main search (PremisSearchView)
/premise/history
```

Wire home **New Entry** → `/premise/form?mode=create` ✅  
Wire home **Duplicate** → `/premise/duplicate-search` ✅

---

## Phased Delivery

### Phase 1 — Form UI (**now**)

- `premise_form_sections.dart` registry
- `premise_form_page.dart` — tab bar, scroll ↔ tab sync, submit bar
- Section widgets (one file per section) with mock/placeholder fields
- `premise_form_controller.dart` — state, submit-time validation (sections 1–3)
- GoRouter route for create mode
- No Drift / API required yet — in-memory or mock state OK

### Phase 2 — Form data layer

- Port `PremiseInputModel` → domain + JSON models
- Wire section controllers to real field state
- General lookup integration for dropdowns

### Phase 3 — Local persistence

- Drift tables + migrations
- Remapped save triggers (debounce, section exit, Save & Exit, lifecycle)
- Create + draft resume

### Phase 4 — Search & satellite flows

- Search page replaces placeholder `PremisePage` — **next**
- Drafts list ✅
- Duplicate search ✅ (API wired)
- View / edit modes — **not yet**
- API create/update/photo ✅

### Phase 5 — Offline resilience

- Pending submissions queue + retry UI — **not yet**
- Photo upload ✅ (inline after submit; no retry banner yet)

### Phase 6 — Polish

- History, filters, activity dashboard
- QR license scan
- Tests ported from legacy

---

## SOLID / Coupling Rules (match home feature pattern)

```
Presentation  →  Domain repository interfaces
Data          →  implements interfaces
              →  ApiDataSource / LocalDataSource split
Mock          →  swap provider binding only
```

Section files depend on **controller/provider** — not on each other. Page shell depends on **section registry** only.

Do **not**:

- Put field widgets in `premise_form_page.dart`
- Import Drift from widgets
- Hardcode routes in pages (use `AppRoutes` or item config)
- Duplicate `GeneralModel` — use `lib/shared/models/general_model.dart`

---

## Immediate Next Step

1. Main premise search page (`PremisSearchView`)
2. View / edit form modes with full detail load
3. Pending submission retry pipeline
4. Complete section UIs (license, address, business activity, remarks)

Session log: `docs/sessions/2026-08-20-premise-api-and-duplicate.md`
