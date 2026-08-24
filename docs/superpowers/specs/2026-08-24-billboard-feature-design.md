# Billboard Feature — Design

Full clean-architecture port of the legacy Billboard Census module
(`ilms_flutter/lib/modules/billboard`) into `lib/features/billboard`,
following the exact conventions already established by
`lib/features/premise` (domain / data / presentation, Riverpod,
GoRouter). This is a from-scratch build in this repo — only
`presentation/widgets/billboard_home_section.dart` exists today (a
stub home-grid with disabled buttons).

---

## Goals

- Match premise's architecture and naming conventions file-for-file
  where a billboard equivalent exists, so the two features read as one
  system.
- Preserve legacy billboard's data shape and business rules (fields,
  cascading pickers, remark "Others" encode/decode, faces list).
- Do **not** blindly port legacy's UI mechanics where they conflict
  with premise's already-established UX (see Design Decisions below).

## Non-goals (this phase)

- Offline drafts / Drift persistence — legacy billboard has no
  precedent for this (confirmed: no local table, no `saveOffline`
  hooks anywhere in the 9 legacy section controllers). Submit is
  online-only, matching legacy.
- Pending-submission retry queue, photo-retry banner — same reason.
- Dashboard charts screen (`BillboardDashboardView` equivalent) — low
  priority, legacy version is hardcoded mock data with no real signal.
- "Map View" home button — no legacy screen backs it; deferred.

---

## Design Decisions

These deviate from a literal 1:1 port. Approved by user before writing
this spec.

1. **Validation stays light**, matching legacy — no required
   sections, no minimum-photo gate. All 9 sections are best-effort;
   only `hasChanges`-style dirty tracking, no blocking validation.
   Can be tightened later without an architecture change.
2. **Flatten legacy's per-section "summary + push-to-edit" screens**
   into premise's single-scroll + sticky-tab-bar, always-inline-editable
   convention (`premise_form_page.dart` pattern). Legacy's
   `CustomVerticalTab` wizard and per-section modal-edit screens are
   not ported as UI mechanics — only their field content is.
3. **Activity counter follows premise's summary-widget style**
   (`premise_status_summary_chart.dart`-equivalent) instead of
   legacy's `Platform.isIOS` branching popup/Cupertino-dialog widget.
4. **Media Owner, Asset Owner, and Location's media-client stay as 3
   separate entities/sections**, exactly as legacy models them — no
   conflation, even though the names are easy to confuse.
5. **GPS section reuses the existing `AppMapField`**
   (`lib/shared/ui/forms/app_map_field.dart`) rather than building a
   new map picker — it already provides current-location + coordinate
   picking.
6. **State management collapses legacy's 9 separate
   `BaseFormNotifier` subclasses into one `BillboardFormState` /
   `BillboardFormFields` / `BillboardFormController`**, mirroring
   premise's single-state-object pattern
   (`premise_form_state.dart` + `PremiseFormController`) rather than
   porting a 9-notifier architecture that premise's own migration plan
   already deprecates ("Provider + ChangeNotifier" → "Riverpod
   Notifier").
7. **Data layer is split by concern** (search / detail / status-summary
   / submit repositories, each with its own `api_*` + `mock_*`
   datasource), matching premise's 5-repository split — even though
   legacy billboard used one god-repo (`BillboardRepo`) for everything.

---

## Domain Model

Aggregate root `BillboardForm` (mirrors `premise_form.dart`), composed
of per-section entities:

| Entity | Fields | Notes |
|---|---|---|
| `BillboardDetails` | `phase`(code), `phaseDesc`, `description`, `billboardType`(code), `isLedBoard`(bool), `isLight`(bool), `isPotential`(bool), `hordingStartDate`, `hordingCompleteDate` | Yes/No fields default `false`, not null. `startDate` ≤ `completeDate` constraint. |
| `BillboardLocation` | `mediaClientName`, `mediaClientTel`, `unit`, `address` (single free-text field — legacy's unused `street1` is dropped, only `street2`'s role survives as `address`), `postal` (free-text 5-digit, not a dropdown), `building`, `parliamentCode`, `parliamentDesc`, `areaCode`, `areaDesc` | Parliament→Area cascade: changing parliament clears `area`; area picker is an async search filtered by `parliament` code. |
| `BillboardGps` | `latitude`(String), `longitude`(String) | Via `AppMapField`. |
| `BillboardMediaOwner` | `name`, `tel` | |
| `BillboardAssetOwner` | `code`, `desc` | Single dropdown. |
| `BillboardLicense` | `fileNo` | Single text field, no auto-prefix (unlike premise license). |
| `BillboardRemark` | `codes: List<String>`, `otherText: String?` | "Others" option triggers free text; encode/decode via ported `resolveRemarkOptions`/`isOtherRemarkOption` pure functions. |
| `BillboardFace` | `id`, `width`(int), `height`(int), `count`(int) | List section, add/edit/delete — mirrors premise's license list pattern. |
| `BillboardPhoto` | `id`, `url`, `bytes` | Flat list, no caption/type-code (unlike premise census images). |

`BillboardForm`: `billboardNo?`, `updatedAt?`, `localDraftId?` (unused
this phase, kept for parity/future), `details`, `location`, `gps`,
`mediaOwner`, `assetOwner`, `license`, `remark`, `faces: List<BillboardFace>`,
`photos: List<BillboardPhoto>`.

**Search/list**: `BillboardSearchRecord` (`billboardNo`, `billboardDate`,
`mediaOwnerClient`, `location`, `address`, `previewImage`, `startDate`,
`completeDate`) + `BillboardSearchResult` (paginated wrapper, mirrors
`premise_search_result.dart`). `BillboardSearchFilter`: `billType`,
`billDateRange`, `ledBoard`, `mediaOwner`, `mediaOwnerClient`, `street`,
`parliament`, `phase`, `assetOwner` — 9 filters.

**Dashboard summary**: `BillboardStatusSummary` (`dateFrom`, `dateTo`,
`total`, `types: List<BillboardTypeCount>`), mirrors
`premise_status_summary.dart`.

**Submit result**: `BillboardSubmitResult` (mirrors `premise_submit_result.dart`).

---

## Directory / File Plan

```
lib/features/billboard/
├── domain/
│   ├── entities/
│   │   ├── billboard_details.dart
│   │   ├── billboard_location.dart
│   │   ├── billboard_gps.dart
│   │   ├── billboard_media_owner.dart
│   │   ├── billboard_asset_owner.dart
│   │   ├── billboard_license.dart
│   │   ├── billboard_remark.dart
│   │   ├── billboard_face.dart
│   │   ├── billboard_photo.dart
│   │   ├── billboard_form.dart
│   │   ├── billboard_search_record.dart
│   │   ├── billboard_search_result.dart
│   │   ├── billboard_search_filter.dart
│   │   ├── billboard_status_summary.dart
│   │   └── billboard_submit_result.dart
│   ├── repositories/
│   │   ├── billboard_repository.dart              # create/update/photo submit
│   │   ├── billboard_search_repository.dart
│   │   ├── billboard_detail_repository.dart
│   │   └── billboard_status_summary_repository.dart
│   ├── exceptions/
│   │   └── billboard_exception.dart
│   └── utils/
│       └── billboard_remark_codec.dart             # ported resolveRemarkOptions / isOtherRemarkOption
├── data/
│   ├── datasources/
│   │   ├── api_billboard_data_source.dart
│   │   ├── api_billboard_search_remote_data_source.dart
│   │   ├── api_billboard_detail_remote_data_source.dart
│   │   ├── api_billboard_status_summary_remote_data_source.dart
│   │   ├── mock_billboard_data_source.dart          # tests only
│   │   ├── mock_billboard_search_remote_data_source.dart
│   │   └── billboard_data_source.dart               # interfaces
│   ├── models/
│   │   ├── billboard_submit_payload_model.dart
│   │   ├── billboard_search_models.dart
│   │   └── billboard_status_summary_model.dart
│   ├── mappers/
│   │   ├── billboard_form_mapper.dart
│   │   ├── billboard_detail_mapper.dart
│   │   └── billboard_status_summary_mapper.dart
│   └── repositories/
│       ├── billboard_repository_impl.dart
│       ├── billboard_search_repository_impl.dart
│       ├── billboard_detail_repository_impl.dart
│       └── billboard_status_summary_repository_impl.dart
└── presentation/
    ├── pages/
    │   ├── billboard_list_page.dart
    │   └── billboard_form_page.dart
    ├── sections/
    │   ├── billboard_form_sections.dart             # registry, mirrors premise_form_sections.dart
    │   ├── billboard_detail_section.dart
    │   ├── billboard_location_section.dart
    │   ├── billboard_gps_section.dart
    │   ├── billboard_media_owner_section.dart
    │   ├── billboard_asset_owner_section.dart
    │   ├── billboard_license_section.dart
    │   ├── billboard_remarks_section.dart
    │   ├── billboard_faces_section.dart
    │   └── billboard_photo_section.dart
    ├── widgets/
    │   ├── billboard_home_section.dart               # already exists — wire buttons
    │   ├── billboard_search_filter_sheet.dart
    │   ├── billboard_action_sheet.dart
    │   ├── billboard_activity_summary.dart            # premise-chart-style, not legacy popup
    │   ├── billboard_tile.dart
    │   ├── billboard_face_dialog.dart
    │   └── billboard_form_tab_bar.dart                 # reuse premise_form_tab_bar.dart if generic enough
    ├── controllers/
    │   └── billboard_form_state.dart                 # BillboardFormMode, BillboardFormSession, BillboardFormState, BillboardFormFields
    └── providers/
        ├── billboard_providers.dart
        ├── billboard_form_providers.dart
        ├── billboard_search_providers.dart
        └── billboard_status_summary_providers.dart
```

---

## State Management

- `BillboardFormMode`: `create | view | edit` (no `draft`/`duplicate` —
  no draft/duplicate flow this phase).
- `BillboardFormSession`: `mode`, `instanceKey`, `billboardNo?` (server
  id to load on view/edit) — mirrors `PremiseFormSession` minus
  `localDraftId`/`isVacantIntent`.
- `BillboardFormController extends FamilyNotifier<BillboardFormState, BillboardFormSession>`:
  holds `details`, `location`, `gps`, `mediaOwner`, `assetOwner`,
  `license`, `remark`, `faces`, `photos`, `activeSectionIndex`,
  `isSubmitting`. Methods: `selectPhase`, `selectBillboardType`,
  `setLed/setLight/setPotential`, `selectParliament` (resets area),
  `selectArea`, `setCoordinate`, `selectAssetOwner`,
  `addFace/updateFaceAt/removeFaceAt`, `addPhoto/removePhotoAt`,
  `toggleRemark/setOtherRemarkText`, `submit()`.
- `BillboardFormFields`: `TextEditingController`s for every text/number
  field, grouped by section (mirrors `PremiseFormFields` layout),
  disposed together.

## Screens & Navigation

| Route | Page | Notes |
|---|---|---|
| `/billboard/list` | `BillboardListPage` | Search app bar, activity summary, filter sheet, paginated `AppListView`, FAB → create, tile tap → action sheet (View/Update) |
| `/billboard/form` | `BillboardFormPage` | `?mode=create\|view\|edit&billboardNo=` — single scroll + sticky tab bar, 9 sections |

Home wiring (`billboard_home_section.dart`): **View All** →
`/billboard/list`, **New Entry** → `/billboard/form?mode=create`, **Map
View** stays disabled (no backing screen, out of scope).

---

## Data Layer

- `BillboardRepository` — `submitCreate(BillboardForm)`,
  `submitUpdate(BillboardForm)`, `uploadPhoto(...)`,
  `deletePhoto(...)` — try/catch → `BillboardException` subtypes,
  mirrors `premise_repository_impl.dart`.
- `BillboardSearchRepository` — paginated search + filters.
- `BillboardDetailRepository` — fetch full record by `billboardNo` for
  view/edit.
- `BillboardStatusSummaryRepository` — dashboard/list activity counts.
- Dropdown lookups (billboard type, LED, light, potential, asset
  owner, parliament, phase) reuse `lib/shared/lookups/` exactly like
  premise — no billboard-specific lookup datasource.
- `mock_*` datasources are test-only, not wired in production (same
  rule as premise's README).

---

## Testing

Mirror premise's test layout:
- `test/features/billboard/data/billboard_form_mapper_test.dart`
- `test/features/billboard/data/billboard_repository_impl_test.dart`
- `test/features/billboard/domain/billboard_remark_codec_test.dart`
  (port legacy's existing unit coverage for
  `resolveRemarkOptions`/`isOtherRemarkOption`)
- `test/features/billboard/presentation/billboard_form_controller_test.dart`

---

## Open Follow-ups (not this phase)

- Offline drafts, if ever wanted, is new scope beyond "port legacy" —
  needs its own brainstorming pass.
- Dashboard charts page, Map View overview — no legacy source to port
  from; would need fresh requirements.
