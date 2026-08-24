# Investigation Feature — Design

Full clean-architecture port of the legacy Siasatan (Investigation)
module (`ilms_flutter/lib/modules/siasatan`) into
`lib/features/investigation`, following the conventions established by
`lib/features/premise` and `lib/features/billboard` (domain / data /
presentation, Riverpod, GoRouter). This is a from-scratch build in
this repo — only `presentation/widgets/investigation_home_section.dart`
exists today (a stub home-grid with disabled buttons).

"Siasatan" = "Investigation": inspection case management for premises
already on file. Unlike premise/billboard, cases **originate
elsewhere** (a separate case-management system) — the mobile app only
searches, views, and edits existing investigations. There is no
working create flow in legacy to port.

---

## Goals

- Match premise/billboard's architecture and naming conventions
  file-for-file where an investigation equivalent exists.
- Preserve legacy's data shape and business rules (read-only
  applicant/location sections, the one validated minutes section,
  edit-session Save & Exit with pending-photo persistence).
- Port only the **working** slice — legacy has three near-duplicate
  submit-payload shapes and two unfinished sub-features; only the live
  code path is modeled (see Non-goals).

## Non-goals (this phase)

- **Create-case flow** — `SiasatanCreatePostModel`, `BasicInfo`,
  `PremiseInvestigation`, `Cancellation`/`Approval` and the `/create`
  endpoint are dead code (no caller in legacy). Investigations are
  view/edit-only. If a create flow is ever needed it's new scope
  requiring its own requirements pass, not a port.
- **Senarai Kerja (work list)** — bulk add/remove investigation
  numbers to a personal list. Backend endpoints exist
  (`/listWorkItems`, `/addWorkItem`, `/deleteWorkItem`) but both
  legacy UIs are commented-out/scaffold. Documented as a future
  extension point in the README; not implemented.
- **`UpdateSiasatanPostModel`** (the flattened, `ad_*`-keyed shape) —
  superseded by `DetailsSiasatanData.toJsonUpdate()`, which is the
  shape the live repo method actually sends. Not ported.
- **Dashboard analytics charts** — legacy's line/pie/bar charts are
  hardcoded mock data with no real endpoint. Home entry stays a plain
  button group (View All / History), like premise/billboard's home
  sections.
- **Documents** (`Document` model) — present in the detail response
  but never rendered by any legacy section. Not modeled as a UI
  concern; can be added to the entity later if a screen needs it.
- **Cross-restart photo-upload retry queue** — legacy explicitly cut
  this scope for siasatan (unlike premise, which has one). Photo
  upload failures surface in the upload sheet for in-session retry
  only.

---

## Design Decisions

Approved by user before writing this spec.

1. **View/edit-only lifecycle** — `InvestigationFormMode` is
   `view | edit` only, no `create`/`duplicate`. This is the single
   biggest structural difference from premise/billboard's
   create-first form.
2. **Edit-session drafts use a Drift table**, not skipped like
   billboard. Legacy's Save & Exit (pause mid-edit, resume later,
   including pending unsent photo bytes) is real, actively-used
   behavior — dropping it would be a regression, not a simplification.
   One row per `(ownerUserId, investigationNo)`, JSON blob body
   (mirrors legacy's `SiasatanEditSessions` single-blob shape rather
   than premise's fully-structured draft table — the blob already
   round-trips through the same mapper used for submit, so a
   structured table would just duplicate that shape).
3. **Search and History share one list page/controller** with a
   `mode` flag (`search | history`) that only toggles filter-sheet
   visibility — exactly like legacy, which uses the same controller
   and view for both and has no separate history endpoint.
4. **Section validation stays interface-based** but the legacy
   footgun (a hand-maintained parallel `steps` array that must mirror
   `listPage` order, previously caused a silent all-sections-valid
   bug) is fixed structurally: validators are derived from the
   section list itself, not tracked in a second array.
5. **Applicant info and Parlimen/Kawasan sections are read-only
   display**, matching legacy's business rule (case record is
   authoritative; officer cannot edit identity or geographic
   classification from the mobile app).
6. **Photos are untyped** — legacy sends one fixed empty `photoType`
   with no per-image classification or description, unlike premise's
   typed census images. `InvestigationPhoto` has no `type`/`caption`
   fields to match.
7. **Minutes is two concepts in one section**: a read-only historical
   `InvestigationMinute` list (role/officer/date/text, shown in a
   sub-sheet) plus one editable `InvestigationMinutesEntry` per
   submit (date/time/text) — the only section with real validation.
8. **State management collapses legacy's 7 per-section controllers**
   into one `InvestigationFormState` / `InvestigationFormController`,
   mirroring premise/billboard's single-state-object pattern rather
   than porting a many-controller architecture.
9. **Data layer split by concern** (search / detail / draft
   repositories, each with `api_*`/`local_*` + `mock_*` datasource),
   matching premise/billboard's split even though legacy used one
   god-repo (`SiasatanRepo`) for everything.

---

## Domain Model

Aggregate root `InvestigationDetails` (mirrors `premise_form.dart` /
`billboard_form.dart`), composed of per-section entities:

| Entity | Fields | Notes |
|---|---|---|
| `InvestigationApplicantInfo` | `licenseFileNo`, `applicantName`, `identificationNo`, `companyName`, `registrationNo`, `businessTypes: List<InvestigationCodeDescription>`, `advertisementTypes: List<InvestigationCodeDescription>` | Read-only, sourced from case record. |
| `InvestigationLocation` | `parliamentCode`, `parliamentDesc`, `areaCode`, `areaDesc` | Read-only, fixed by case record (business rule). |
| `InvestigationPremiseDetails` | `premisePosition`, `premiseLeft/Right/Above/Below`, `buildingType`, `level`, `buildingStatus`, `premiseModification`(bool), `premiseLength/Width`(num), `similarPremisesCount`(int) | Fully editable; no mandatory fields. |
| `InvestigationBusinessActivity` | `floorLength/Width`(num), `openingTime`, `closingTime` | Entertainment/food-service specific; time-of-day fields. |
| `InvestigationPollutionDisturbance` | `placingFurniture`(bool, gates `chairCount`/`tableCount`/`stallCount`), `machineCount`, `hairSalonChairCount`, `roomCount`, `studentCount`, `petrolLiters`, `dieselLiters`, `gasLiters`, `otherActivities`(text) | Counters default 0, not null. |
| `InvestigationAdvertisement` | `displayed`(bool, gates `location`), `compliant`(bool, gates `nonCompliantReason`), `malayLanguage`(bool), `sizeCompliant`(bool), `spellingCompliant`(bool) | 3 independent boolean toggles + 2 gated fields. |
| `InvestigationPhoto` | `id`, `sequence`, `uploadedBy`, `uploadedAt`, `url?`, `bytes?` | Untyped (design decision 6). `bytes` set for unsent local picks; persisted to draft as base64. |
| `InvestigationMinute` | `minuteId`, `sequence`, `role`, `officer`, `date`, `minutes` | Historical, read-only list. |
| `InvestigationMinutesEntry` | `investigationDate`, `investigationTime`, `preparedBy`, `minutes`(text) | Editable, all 3 user-facing fields mandatory. |
| `InvestigationCodeDescription` | `code`, `description` | Shared value type for business/advertisement type lists. |

`InvestigationDetails`: `investigationNo`, `investigationId`,
`investigationStatus`, `applicant: InvestigationApplicantInfo`,
`location: InvestigationLocation`,
`premiseDetails: InvestigationPremiseDetails`,
`businessActivity: InvestigationBusinessActivity`,
`pollutionDisturbance: InvestigationPollutionDisturbance`,
`advertisement: InvestigationAdvertisement`,
`photos: List<InvestigationPhoto>`,
`minutes: List<InvestigationMinute>`,
`minutesEntry: InvestigationMinutesEntry`.

**Search/list**: `InvestigationSearchRecord` (`investigationNo`,
`investigationId`, `licenseFileNo`, `dateReceived`, `applicantName`,
`companyName`, `typeCode`, `priorityCode`, `statusCode`, `areaCode`,
`investigationOfficer`, `investigationStartDate`, `businessType`,
`createdDate`) + `InvestigationSearchResult` (paginated wrapper,
mirrors `premise_search_result.dart`). `InvestigationSearchFilter`:
`investigationNo`, `licenseNo`, `identificationNo`, `companyName`,
`registrationNo`, `parliamentCode`, `areaCode`, `statusCode`,
`officerName`, `dateReceived`, `investigationStartDateFrom/To`,
`businessTypeCode` — 11 filters.

**Draft**: `InvestigationDraftSummary` (`investigationNo`,
`savedAt`, `hasChanges`) — mirrors `premise_draft_summary.dart`,
listed on `InvestigationDraftsPage`.

**Submit result**: `InvestigationSubmitResult` (mirrors
`premise_submit_result.dart` / `billboard_submit_result.dart`).

---

## Directory / File Plan

```
lib/features/investigation/
├── README.md
├── domain/
│   ├── entities/
│   │   ├── investigation_applicant_info.dart
│   │   ├── investigation_location.dart
│   │   ├── investigation_premise_details.dart
│   │   ├── investigation_business_activity.dart
│   │   ├── investigation_pollution_disturbance.dart
│   │   ├── investigation_advertisement.dart
│   │   ├── investigation_photo.dart
│   │   ├── investigation_minute.dart
│   │   ├── investigation_minutes_entry.dart
│   │   ├── investigation_code_description.dart
│   │   ├── investigation_details.dart
│   │   ├── investigation_search_record.dart
│   │   ├── investigation_search_result.dart
│   │   ├── investigation_search_filter.dart
│   │   ├── investigation_draft_summary.dart
│   │   └── investigation_submit_result.dart
│   ├── repositories/
│   │   ├── investigation_repository.dart          # update + photo submit
│   │   ├── investigation_search_repository.dart
│   │   ├── investigation_detail_repository.dart
│   │   └── investigation_draft_repository.dart
│   └── exceptions/
│       └── investigation_exception.dart
├── data/
│   ├── datasources/
│   │   ├── api_investigation_data_source.dart
│   │   ├── api_investigation_search_remote_data_source.dart
│   │   ├── api_investigation_detail_remote_data_source.dart
│   │   ├── mock_investigation_data_source.dart      # tests only
│   │   ├── mock_investigation_search_remote_data_source.dart
│   │   ├── investigation_data_source.dart           # interfaces
│   │   ├── investigation_search_remote_data_source.dart
│   │   ├── investigation_detail_remote_data_source.dart
│   │   └── local/investigation_draft_local_data_source.dart
│   ├── models/
│   │   ├── investigation_submit_payload_model.dart  # toJsonUpdate() port
│   │   ├── investigation_search_models.dart
│   │   └── investigation_draft_payload_model.dart
│   ├── mappers/
│   │   ├── investigation_detail_mapper.dart
│   │   ├── investigation_form_mapper.dart
│   │   └── investigation_draft_mapper.dart
│   └── repositories/
│       ├── investigation_repository_impl.dart
│       ├── investigation_search_repository_impl.dart
│       ├── investigation_detail_repository_impl.dart
│       └── investigation_draft_repository_impl.dart
└── presentation/
    ├── pages/
    │   ├── investigation_list_page.dart             # search + history, mode flag
    │   ├── investigation_form_page.dart
    │   └── investigation_drafts_page.dart
    ├── sections/
    │   ├── investigation_form_sections.dart          # registry, mirrors premise_form_sections.dart
    │   ├── investigation_applicant_section.dart      # read-only
    │   ├── investigation_location_section.dart       # read-only
    │   ├── investigation_premise_details_section.dart
    │   ├── investigation_photo_section.dart
    │   └── investigation_minutes_section.dart
    ├── widgets/
    │   ├── investigation_home_section.dart           # already exists — rewire buttons
    │   ├── investigation_search_filter_sheet.dart
    │   ├── investigation_search_record_tile.dart
    │   ├── investigation_minute_history_sheet.dart   # legacy MinitSectionModal
    │   ├── investigation_photo_upload_sheet.dart
    │   ├── investigation_section_header.dart
    │   └── investigation_form_tab_bar.dart            # reuse premise's if generic enough
    ├── controllers/
    │   ├── investigation_form_state.dart              # InvestigationFormMode/Session/State
    │   └── investigation_list_controller.dart
    └── providers/
        ├── investigation_providers.dart
        ├── investigation_form_providers.dart
        ├── investigation_search_providers.dart
        └── investigation_draft_providers.dart
```

---

## State Management

- `InvestigationFormMode`: `view | edit` (no `create`/`duplicate` —
  design decision 1).
- `InvestigationFormSession`: `mode`, `instanceKey`, `investigationNo`
  (always present — there's no "new" case) — mirrors
  `PremiseFormSession`/`BillboardFormSession` minus create-only
  fields.
- `InvestigationFormController extends FamilyNotifier<InvestigationFormState, InvestigationFormSession>`:
  holds `applicant`, `location`, `premiseDetails`, `businessActivity`,
  `pollutionDisturbance`, `advertisement`, `photos`, `minutes`,
  `minutesEntry`, `activeSectionIndex`, `isSubmitting`,
  `hasUnsavedChanges`. Methods: `enterEditMode()`,
  `setPremiseField(...)`, `togglePlacingFurniture`,
  `toggleAdvertisementDisplayed/Compliant`, `addPhoto/removePhotoAt`,
  `setMinutesEntry(...)`, `saveDraft()`, `discardEditSession()`,
  `submit()`.
- `InvestigationFormFields`: `TextEditingController`s for every
  text/number field, grouped by section, disposed together.
- Section validators: `InvestigationSectionValidator` interface,
  derived per-section from `investigation_form_sections.dart`'s
  registry (design decision 4) — only the minutes section returns a
  real implementation; the rest use a shared always-valid instance.

## Screens & Navigation

| Route | Page | Notes |
|---|---|---|
| `/investigation/list` | `InvestigationListPage` | `?mode=search\|history` — search shows filter sheet + `AppSearchAppBar`, history hides it; both paginated via `AppListView`, tile tap → detail fetch → form page in view mode |
| `/investigation/form` | `InvestigationFormPage` | `?investigationNo=&mode=view\|edit` — single scroll + sticky tab bar, 5 sections; Edit menu item switches view→edit; Save & Exit / Discard / Exit-without-saving sheet on back (mirrors `premise_form_exit_sheet.dart`) |
| `/investigation/drafts` | `InvestigationDraftsPage` | List of paused edit sessions, resume or discard |

Home wiring (`investigation_home_section.dart`): **View All** →
`/investigation/list?mode=search`, **History** →
`/investigation/list?mode=history`. "New Case"/"Open Cases" buttons
are removed (no legacy equivalent working) rather than left as
permanent disabled stubs.

---

## Data Layer

- `InvestigationRepository` — `update(InvestigationDetails)`,
  `uploadPhoto(...)` — try/catch → `InvestigationException` subtypes,
  including a guard for the documented backend quirk (200 OK with
  `status: error, data: null`), same as premise/billboard.
- `InvestigationSearchRepository` — paginated search, reused for
  history (no separate endpoint, matching legacy).
- `InvestigationDetailRepository` — fetch full record by
  `investigationNo` for view/edit.
- `InvestigationDraftRepository` — Drift-backed edit-session
  save/load/discard, keyed by `(ownerUserId, investigationNo)`.
- Dropdown lookups (building type/status, parliament, area) reuse
  `lib/shared/lookups/`, exactly like premise/billboard — no
  investigation-specific lookup datasource.
- `mock_*` datasources are test-only, not wired in production (same
  rule as premise/billboard's README).

---

## Testing

Mirror premise/billboard's test layout:
- `test/features/investigation/data/investigation_detail_mapper_test.dart`
- `test/features/investigation/data/investigation_form_mapper_test.dart`
- `test/features/investigation/data/investigation_draft_mapper_test.dart`
- `test/features/investigation/data/investigation_draft_repository_impl_test.dart`
- `test/features/investigation/data/mock_investigation_search_remote_data_source_test.dart`
- `test/features/investigation/presentation/investigation_form_controller_test.dart`
- `test/features/investigation/presentation/investigation_list_controller_test.dart`

---

## Open Follow-ups (not this phase)

- **Senarai Kerja (work list)** — endpoints exist server-side; needs a
  fresh UI design pass since legacy never finished one (see
  Non-goals).
- **Create-case flow** — only if a real product need emerges; legacy
  has no working reference to port from.
- **Dashboard analytics** — no real endpoint to back it yet.
- **Documents section** — model exists in the API response but no
  legacy screen renders it; revisit if a requirement surfaces.
