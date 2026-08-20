# Legacy Overview — `ilms_flutter/lib/modules/premis`

Study reference for the existing Premise Census module. Package name in legacy code is `ils_bancian`.

---

## Directory Layout

```
premis/
├── controllers/       # ChangeNotifier providers (Provider package)
├── models/              # Input, search, filter, API response models
├── sections/            # One widget per form page (+ modals)
├── widgets/             # Module-scoped reusable UI
├── premis_dashboard_view.dart
├── premis_home_modal.dart
├── premis_search_view.dart
├── premis_form_view.dart
├── premis_submit_view.dart
├── premis_history_view.dart
├── premis_summary_view.dart
├── premis_draft_sheet.dart
├── premis_filter_modal.dart
├── premis_duplicate_search_view.dart
├── premis_photo_upload_sheet.dart
└── premis_unsave_draft_dialog.dart
```

Local SQLite code lives **outside** the module under:

```
ilms_flutter/lib/data/local/local-sqflite/
├── datasource/premis/   # One datasource per child table + orchestrator
├── dto/premis/
└── tables/premis-table/
```

Network layer: `ilms_flutter/lib/data/network/repositories/premis_repo.dart`

---

## Architecture (Legacy)

State management: **Provider + ChangeNotifier**.

```
PremisDashboardView / PremisHomeModal
    └── PremisSearchView (PremisSearchController)
            ├── PremisDraftCounter / PremisDraftSheet
            ├── PremisPendingSubmissionsBanner (PremisRetryController)
            ├── PremisPendingPhotosBanner (PremisPhotoRetryController)
            ├── PremisDocumentTile (list items)
            └── PremisFormView (PremisFormController)
                    ├── Page 1 — PremisCompDetailsSection   (PrCompDetailController)
                    ├── Page 2 — PremisDetailSection        (PrVisitController / PremisDetailController)
                    ├── Page 3 — PremisAddressSection       (PrAddressController)
                    ├── Page 4 — PremisLicenseSection       (PrLicenseController)
                    ├── Page 5 — PremisBusinessActivitySection (PrBusinessController)
                    ├── Page 6 — PremisRemarkSection        (PrRemarkController)
                    └── Page 7 — PremisCensusImageSection   (PrCencusImageController)
                            └── PremisSubmitView (status selection + submit)
```

`PremisFormController` is the central orchestrator. Each section controller implements `saveOffline(premisID:)` for local persistence.

> **New `ilms` form:** same 7 sections, but single scroll + sticky tab bar instead of `PageController` wizard. See [form-ui-design.md](form-ui-design.md).

---

## Controllers

| Controller | Responsibility |
|------------|----------------|
| `PremisFormController` | Form routing, validation, API create/update/duplicate, local save, lifecycle autosave |
| `PremisSearchController` | Paginated search, filters, draft counter |
| `PrCompDetailController` | Company & contact person (page 1) |
| `PrVisitController` / `PremisDetailController` | Premise visit details (page 2) |
| `PrAddressController` | Address selection via address search sub-flow (page 3) |
| `PrLicenseController` | License records list (page 4) |
| `PrBusinessController` | Business activity records (page 5) |
| `PrRemarkController` | Remarks list (page 6) |
| `PrCencusImageController` | Census photo capture/attach (page 7) |
| `PremisActivityCountProvider` | Daily activity summary for dashboard counters |
| `PremisManageAddressController` | Address lookup inside address search |
| `PremisRetryController` | Offline retry queue for failed submissions |
| `PremisPhotoUploadController` | Post-submit photo upload with per-image progress |
| `PremisPhotoRetryController` | Detect/resume photos not uploaded after app kill |
| `PremisDuplicateSearchController` | Duplicate-from-existing search flow |

---

## Screens & Entry Points

### Home integration (`general/home/home_view.dart`)

Permission-gated tiles open module modals. Premise uses `PremisHomeModal` → grid actions:

| Action (BM) | Screen |
|-------------|--------|
| Carian Bancian | `PremisSearchView` |
| Sejarah Bancian | `PremisHistoryView` |

`PremisDashboardView` is an alternate entry (banner + search shortcut); history handler is still a no-op stub.

### Search (`premis_search_view.dart`)

Main working screen:

- Custom search app bar with debounced query
- Filter modal (`premis_filter_modal.dart`)
- Paginated list (`PaginatedListView`)
- FAB → new premise form (create)
- Draft counter badge → opens `PremisDraftSheet`
- Banners for pending submissions and pending photo uploads
- Stream of unsaved edit-session visit numbers (tags on synced tiles)

Exit guard: if a transient draft form is in progress, shows dialog (Exit Anyway / Clear Draft).

---

## Models (Legacy)

| Model | Purpose |
|-------|---------|
| `PremiseInputModel` | Full census payload for create/update |
| `CompanyDetails`, `ContactPerson`, `PremiseDetails` | Pages 1–2 |
| `PremiseAddress` | Page 3 |
| `LicenseInformation` | Page 4 — auto-prefixes file no with `DBKL.JPPP/` |
| `BusinessActivity`, `Remark`, `ImageData` | Pages 5–7 |
| `PremisSearchModel` / `PremisSearchData` | Paginated search API response |
| `PremisSearchFilter` | Search filter params |
| `PremiseSummaryActivityResponse` | Dashboard activity counts |
| `PremisPhotoUpload` / `PhotoUploadTask` | Upload progress UI |

Serialization has two paths:

- `toJson()` / `fromJson()` — **create**
- `toJsonUpdate()` / `fromJsonUpdate()` — **update** (preserves server child row IDs)

The retry queue must parse with the matching parser per `action` (`create` vs `update`).

---

## Validation

Defined in `premis_step_validation.dart` and `PremisFormController.steps`.

- **Pages 1–3 validated** before Next: company/contact, premise details, address.
- **Pages 4–7 optional** — saved locally on Next but not blocking validation.
- Vacant premise shortcut (`isVacant`) can skip parts of the flow.

---

## Known Legacy Issues (from their README)

Already fixed in legacy (documented for awareness when porting):

- Draft persistence timing (background save, edit-session cleanup)
- `LicenseInformation` attachment base64 decode on view/edit/duplicate

Still open / design notes:

- `PremisDashboardView.onHistory` empty stub
- Commented census-year filter fields in search controller

See `ilms_flutter/lib/modules/premis/README.md` for the full audit list.
