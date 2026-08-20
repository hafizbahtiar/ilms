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
| `modules/premis/premis_search_view.dart` | `presentation/pages/premise_search_page.dart` |
| `modules/premis/premis_draft_sheet.dart` | `presentation/widgets/premise_draft_sheet.dart` |
| `modules/premis/premis_history_view.dart` | `presentation/pages/premise_history_page.dart` |
| `modules/premis/controllers/premis_form_controller.dart` | `presentation/controllers/premise_form_controller.dart` |
| `modules/premis/models/premis_input_model.dart` | `data/models/` + `domain/entities/` |
| `data/.../premis_data_local_datasource.dart` | `data/datasources/local/premise_local_datasource.dart` |
| `data/network/repositories/premis_repo.dart` | `data/datasources/api/premise_api_data_source.dart` + `data/repositories/premise_repository_impl.dart` |
| `modules/general/controller/general_controller.dart` | Shared `general` feature or lookup providers |

---

## Route Plan

Current:

```
/module/premise  →  PremisePage (placeholder)
```

Proposed (form first):

```
/premise/form                # ?mode=create|draft|edit|view|duplicate  ← Phase 1
/premise/form/:localId       # resume draft
/premise/search              # Phase 2+
/premise/drafts
/premise/history
/premise/duplicate-search
```

Wire home **New Entry** → `/premise/form?mode=create` when form shell exists.

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

- Search page replaces placeholder `PremisePage`
- Draft sheet, duplicate search
- View / edit / duplicate modes fully wired

### Phase 5 — Offline resilience

- Pending submissions queue + retry UI
- Photo upload + photo retry banner

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

1. [form-ui-design.md](form-ui-design.md) — tab bar + scroll spec
2. [form-flow-and-states.md](form-flow-and-states.md) — states & validation
3. Scaffold `premise_form_page.dart` + first section file

Local DB and search come **after** form UI is approved.
