# Premise Feature (`ilms`)

Premise Census module for ILMS — business premise field visits: search, create, edit, duplicate, offline draft, and submit.

This feature is being rebuilt in `ilms` using clean architecture (domain / data / presentation), Riverpod, GoRouter, and Drift. Behaviour and data contracts are inherited from the legacy app in `ilms_flutter/lib/modules/premis`.

---

## Current State (this repo)

| Area | Status |
|------|--------|
| Home entry | Wired via dynamic home groups (`View All` → `/module/premise`) |
| `PremisePage` | Placeholder — mock census list only |
| Local DB | Shared `AppDatabase` exists (`KeyValueEntries` only); premise tables not yet added |
| Domain / data / form | Not implemented |

---

## Legacy Reference

Full behaviour lives in **`ilms_flutter`**. Read the docs below before implementing.

| Doc | Contents |
|-----|----------|
| [docs/form-ui-design.md](docs/form-ui-design.md) | **Form first** — tab bar + scroll-sync sections (food-menu UX) |
| [docs/form-flow-and-states.md](docs/form-flow-and-states.md) | Form states, validation, persistence (legacy vs new UI) |
| [docs/legacy-overview.md](docs/legacy-overview.md) | Legacy module layout, controllers, screens, navigation |
| [docs/local-persistence.md](docs/local-persistence.md) | SQLite schema, drafts, edit sessions, retry queue, photo upload |
| [docs/general-module-integration.md](docs/general-module-integration.md) | Shared lookup data (`GeneralController`), offline master cache |
| [docs/migration-plan.md](docs/migration-plan.md) | Mapping legacy → `ilms` target structure |

Legacy source README: `ilms_flutter/lib/modules/premis/README.md`

---

## Current Focus — Form First

Premise work starts with the **census form UI**, not search or local DB.

Design: **single scroll page + sticky tab bar** (same pattern as ecommerce / food delivery category menus):

1. Horizontal **tab bar** — one tab per section (7 tabs)
2. **Scroll → tab** — active tab follows the section in view
3. **Tab tap → scroll** — jumps to that section
4. **One file per section** — fields live in `presentation/sections/`, not in the page shell

Full spec: [docs/form-ui-design.md](docs/form-ui-design.md)

Legacy used a 7-page wizard (`PageController` + Next/Back). Same 7 sections and data — new presentation only.

---

## Target Structure (`ilms`)

```
lib/features/premise/
├── README.md
├── docs/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── exceptions/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── pages/
    │   └── premise_form_page.dart       # shell: tab bar + scroll + submit (no fields)
    ├── sections/                        # one file per form section
    │   ├── premise_form_sections.dart   # section registry (tabs, ids, order)
    │   ├── company_contact_section.dart
    │   ├── premise_details_section.dart
    │   ├── premise_address_section.dart
    │   ├── license_section.dart
    │   ├── business_activity_section.dart
    │   ├── remarks_section.dart
    │   └── census_images_section.dart
    ├── widgets/
    │   ├── premise_form_tab_bar.dart
    │   └── premise_section_header.dart
    ├── controllers/
    │   └── premise_form_controller.dart
    └── providers/
```

Principles carried forward from legacy:

- **Offline-first drafts** — every "Next" in create/draft/duplicate persists the current page to SQLite.
- **Edit sessions** — editing a submitted record uses a scratch local row (`isEditSession`), separate from new-premise drafts.
- **Retry queue** — failed create/update payloads stored in `pending_submissions` for manual retry.
- **Deferred photo upload** — census images can outlive the main submit; retried separately.
- **General lookups** — dropdown values from API with SQLite master-data fallback when offline.

---

## Key User Flows

```
Home → Premise group → View All
  └── Search (paginated API + filters)
        ├── Draft counter / Draft sheet
        ├── Pending submission banner (retry)
        ├── Pending photos banner (retry upload)
        └── Document tile → Form (tab bar + scroll sections) → Submit sheet
              ├── create / draft / duplicate / edit / view
              └── Save & Exit / background autosave
```

Entry actions (aligned with home mock config):

| Action | Legacy screen | Route (target) |
|--------|---------------|----------------|
| View All | `PremisSearchView` | `/module/premise` or `/premise/search` |
| New Entry | `PremisFormView` (create) | `/premise/form?mode=create` |
| Drafts | `PremisDraftSheet` | `/premise/drafts` |
| History | `PremisHistoryView` | `/premise/history` |

---

## Related Code (this repo)

| File | Role |
|------|------|
| `lib/features/home/data/datasources/mock_home_menu_data_source.dart` | Premise home group items |
| `lib/app/router/app_router.dart` | `/module/premise` → `PremisePage` |
| `lib/core/local/database/app_database.dart` | Shared Drift DB (premise tables TBD) |
| `lib/shared/models/general_model.dart` | Lookup item shape (same as legacy) |

---

## Implementation Order

### Now — Form UI (Phase 1)

1. Section registry + `premise_form_page.dart` shell (tab bar, scroll sync).
2. Section files one by one (company → details → address → …).
3. Form controller + submit-time validation (required sections 1–3).
4. Route `/premise/form?mode=create` from home **New Entry**.

See [docs/form-ui-design.md](docs/form-ui-design.md).

### Later

5. Domain entities + `PremiseInputModel` port.
6. Drift tables + offline save triggers ([local-persistence.md](docs/local-persistence.md)).
7. Search page, draft sheet, retry/photo pipeline.
8. History + remaining home routes.

---

## Tests (legacy reference)

Legacy has extensive premise tests under `ilms_flutter/test/premis/`. Port critical cases when implementing local persistence and form submit:

- Draft save/resume
- Edit session row lifecycle
- Pending submission retry (`create` vs `update` payload parsing)
- License ↔ business activity linking
- Photo upload seq numbering
