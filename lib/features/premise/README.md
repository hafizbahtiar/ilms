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
| **Premise address** | Listing picker via `/api/listPremiseAddress` — multi-select, advance filter, unit search, postcode from API |
| **License section** | Add/edit sheet — legacy file-no mask, QR scan, business activities per license |
| **License QR** | Scan (camera or gallery) → `/api/premiseCensus/licenseQrLink` → auto-fill license + company fields |
| **Company prefill** | QR → company name + register no; address tile → **Set as Company Address** |
| Company & contact | Full fields + sticker barcode scan (`AppBarcodeScannerPage`) |
| Business activity | Add/edit sheet with lookup-driven fields |
| Remarks | Add/edit sheet with remark codes |
| Census images | Camera/gallery pick, min-count validation, post-submit upload sheet |
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
Legacy address picker: `ilms_flutter/lib/modules/premis/sections/premis_address_section.dart`

Session log (2026-08-20): [`docs/sessions/2026-08-20-premise-api-and-duplicate.md`](../../../docs/sessions/2026-08-20-premise-api-and-duplicate.md)

---

## Target Structure (`ilms`)

```
lib/features/premise/
├── README.md
├── docs/
├── domain/
│   ├── entities/
│   │   ├── premise_address.dart
│   │   ├── premise_address_filter.dart
│   │   ├── premise_address_listing.dart
│   │   └── premise_license_qr_data.dart
│   └── repositories/
│       ├── premise_address_listing_repository.dart
│       └── premise_license_qr_repository.dart
├── data/
│   ├── datasources/
│   │   ├── api_premise_data_source.dart
│   │   ├── api_premise_duplicate_remote_data_source.dart
│   │   ├── api_premise_address_listing_remote_data_source.dart
│   │   ├── api_premise_license_qr_remote_data_source.dart
│   │   ├── mock_* (tests only)
│   │   └── local/premise_draft_local_data_source.dart
│   ├── mappers/
│   │   ├── premise_draft_mapper.dart
│   │   ├── premise_detail_mapper.dart
│   │   ├── premise_form_mapper.dart
│   │   └── premise_license_qr_mapper.dart
│   ├── models/
│   └── repositories/
└── presentation/
    ├── pages/
    │   ├── premise_form_page.dart
    │   ├── premise_drafts_page.dart
    │   └── premise_duplicate_page.dart
    ├── widgets/
    │   ├── premise_home_section.dart
    │   ├── premise_address_search_sheet.dart
    │   ├── premise_address_search_filter_sheet.dart
    │   ├── premise_license_sheet.dart
    │   ├── premise_business_activity_sheet.dart
    │   ├── premise_remark_sheet.dart
    │   ├── premise_duplicate_filter_sheet.dart
    │   ├── premise_duplicate_record_tile.dart
    │   └── premise_form_exit_sheet.dart
    ├── controllers/
    │   ├── premise_duplicate_controller.dart
    │   ├── premise_address_search_controller.dart
    │   └── premise_form_state.dart
    ├── sections/
    │   ├── premise_form_sections.dart
    │   ├── license_section.dart
    │   ├── premise_address_section.dart
    │   ├── company_contact_section.dart
    │   ├── business_activity_section.dart
    │   ├── remarks_section.dart
    │   └── census_images_section.dart
    ├── utils/
    │   ├── premise_license_file_no.dart
    │   └── premise_address_location.dart
    └── providers/
        ├── premise_form_providers.dart
        ├── premise_address_listing_providers.dart
        └── premise_license_qr_providers.dart
```

Shared network helpers used by premise API:

- `lib/core/network/form_data_builder.dart` — nested FormData for create/update/photo
- `lib/core/network/api_response_helper.dart` — status/message parsing

Shared scanner (license QR, sticker no.):

- `lib/shared/ui/media/scanner/app_barcode_scanner_page.dart` — camera scan + optional gallery decode (`allowGallery`, default `true`)

Principles carried forward from legacy:

- **Offline-first drafts** — explicit Save / Save & exit (no silent auto-save on back).
- **Duplicate from previous phase** — address filter → search → eligibility → detail → local draft.
- **Duplicate omits photos & remarks** — user re-captures images and enters remarks fresh.
- **General lookups** — dropdown values from API with Drift cache for offline reuse.
- **Premise address from catalog** — pick from `/api/listPremiseAddress`, not manual floor/block entry.
- **License file no. mask** — `DBKL.JPPP/#####/##/####/####` (legacy parity).

---

## Form Sections (tab order)

| Tab | Section | Key behaviour |
|-----|---------|---------------|
| License | `license_section.dart` | Tile list; add/edit via `premise_license_sheet.dart` |
| Business | `business_activity_section.dart` | Standalone business activities + per-license activities in license sheet |
| Address | `premise_address_section.dart` | Catalog multi-select; tile actions: Pick Location, Set as Company Address, Delete |
| Remarks | `remarks_section.dart` | Remark codes + free text |
| Images | `census_images_section.dart` | Min photo count enforced on submit |
| Company | `company_contact_section.dart` | Company/contact fields; sticker scan |
| Details | `premise_details_section.dart` | Premise metadata + lookups |

Registry: `premise_form_sections.dart`

---

## Premise Address (legacy flow)

**Add** opens `premise_address_search_sheet.dart`:

- Search by unit no.; advance filter (parliament → area → street → building) with searchable pickers
- Company area/street from Section 1 pre-seeded into filter when available
- Multi-select from paginated `/api/listPremiseAddress`
- **Save** replaces the form's full address list (legacy parity)

**Address tile** (edit mode):

| Action | Effect |
|--------|--------|
| Pick Location | Map picker → updates lat/lng on the address |
| Set as Company Address | Copies unit/building/street/postcode/area into Company section via lookup resolution |
| Delete | Removes address from form |

**View mode:** tap tile → read-only map.

Postcode comes from the listing API response (no manual floor/block fields).

---

## License & QR Scan

### License sheet (`premise_license_sheet.dart`)

- **License File No.** — fixed prefix `DBKL.JPPP/` + masked input (`premise_license_file_no.dart`); **License No.** removed
- Status, valid-from/to, business activities (add to list, optional save-to-business)
- **Scan QR** — opens `AppBarcodeScannerPage`, posts link to API, prefills sheet fields

### QR API

| Endpoint | Class |
|----------|-------|
| `POST /api/premiseCensus/licenseQrLink` | `ApiPremiseLicenseQrRemoteDataSource` |

Response fields mapped today:

| API field | Form target |
|-----------|-------------|
| `license_file_no` | License file no. |
| `license_status` | License status lookup |
| `license_date_from` / `license_date_to` | Valid from / to |
| `license_holder_name` | **Company Name** (Section 6) |
| `company_registration_no` | **Register Number** (Section 6) |

Not yet wired from QR: `license_category`, `premise_address`, `license_grade`.

Dev logging: `[PremiseLicenseQr]` in `api_premise_license_qr_remote_data_source.dart` (full response + unmapped keys).

### Barcode scanner permissions

- **Camera** — requested by `MobileScanner`; denied state shows retry + Open Settings
- **Gallery** — system photo picker via `image_picker` (optional via `allowGallery: false`)

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

Form → Address tab → Add → listing search/filter → Save
Form → Address tile → Set as Company Address → Company tab prefilled
Form → License tab → Add License → Scan QR → license + company fields filled
Form → Company tab → Scan sticker → sticker no. filled
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
| Premise address listing | `ApiPremiseAddressListingRemoteDataSource` | `premiseAddressListingRemoteDataSourceProvider` |
| License QR lookup | `ApiPremiseLicenseQrRemoteDataSource` | `premiseLicenseQrRemoteDataSourceProvider` |
| Lookups | `ApiGeneralLookupDataSource` | `generalLookupDataSourceProvider` |

Mock implementations (`MockPremiseDataSource`, `MockPremiseDuplicateRemoteDataSource`, `MockGeneralLookupDataSource`) are **not** wired in production — tests only.

---

## Related Code (this repo)

| File | Role |
|------|------|
| `lib/features/premise/presentation/widgets/premise_home_section.dart` | Premise home buttons + last draft card |
| `lib/features/premise/presentation/providers/premise_form_providers.dart` | Form controller — `applyCompanyFromLicenseQr`, `applyCompanyAddressFromPremise`, `setAddresses` |
| `lib/features/premise/presentation/controllers/premise_address_search_controller.dart` | Paginated address listing search state |
| `lib/features/premise/presentation/utils/premise_license_file_no.dart` | Legacy file-no prefix, mask, validation, submit format |
| `lib/shared/ui/media/scanner/app_barcode_scanner_page.dart` | Shared QR/barcode scanner (camera + gallery) |
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
8. **Premise address** — listing API, search sheet, advance filter, multi-select, map pick, Set as Company Address
9. **License section** — file-no mask, QR scan + API lookup, business activities in sheet
10. **License QR → company prefill** — holder name + registration no.
11. **Barcode scanner** — gallery decode option (`allowGallery`, default `true`)
12. Business activity, remarks, census images, company/contact sections wired

### Next

13. Main premise search page (`PremisSearchView`)
14. View / edit modes with full detail load
15. Edit session + pending submission retry pipeline
16. Wire remaining QR fields (`license_category`, `premise_address`, `license_grade`) if needed
17. Address listing unit tests + offline Drift cache for addresses (Phase 3)

---

## Tests

- `test/features/premise/data/premise_draft_repository_impl_test.dart`
- `test/features/premise/data/premise_draft_mapper_test.dart`
- `test/features/premise/data/premise_detail_mapper_test.dart`
- `test/features/premise/data/premise_form_mapper_test.dart`
- `test/features/premise/data/premise_repository_impl_test.dart`
- `test/features/premise/data/mock_premise_duplicate_remote_data_source_test.dart`
- `test/features/premise/presentation/premise_duplicate_controller_test.dart`
- `test/features/premise/presentation/utils/premise_license_file_no_test.dart`
- `test/features/premise/presentation/utils/premise_address_location_test.dart`

Legacy has extensive premise tests under `ilms_flutter/test/premis/` — port critical cases when wiring edit sessions and full submit payloads.
