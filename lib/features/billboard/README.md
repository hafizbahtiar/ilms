# Billboard Feature (`ilms`)

Billboard Census module for ILMS — billboard field visits: search, create, edit, offline draft,
and submit.

Clean architecture (domain / data / presentation), Riverpod, GoRouter, Drift. Behaviour and data
contracts are inherited from legacy `ilms_flutter/lib/modules/billboard` (network calls in
`ilms_flutter/lib/data/network/repositories/billboard_repo.dart`).

---

## Current State (this repo)

| Area | Status |
|------|--------|
| Home entry | `BillboardHomeSection` — View All, New Entry, Drafts |
| List / search | `BillboardListPage` — paginated search, filter sheet, activity summary |
| Form UI | Tab bar + scroll-sync sections (9 tabs), explicit draft save |
| Local drafts | Drift `billboard_draft_entries`, drafts page, delete |
| API submit | `ApiBillboardDataSource` — create, update (photos travel inline, see below) |
| Status summary | `BillboardStatusSummaryRepository` — activity counts on home |
| Remark options | `/api/billboardCensus/remarkOptions` — single-select + "Others" free text |

**Auth required:** all billboard API calls use `DioClient` with bearer token (login first).

---

## Photo submit shape — read before touching photo upload code

Photos travel **inline** in the same `/api/billboardCensus/create` / `update` request body, as
`images: List<Uint8List>` (`billboard_submit_payload_model.dart`) — this mirrors legacy
`CreateBillBoardInput.toJson()`/`toJsonUpdate()`, which send raw photo bytes as part of the same
create/update call, not a separate endpoint.

This is **different from premise/investigation**, which upload photos to a separate
`/create-photo` endpoint after the record exists. An earlier version of this module copied that
premise/investigation pattern for billboard too — it looked correct in code but the backend never
actually stored the images sent that way (billboard's `/create-photo` is effectively dead —
`CreateBillboardPhotoInput`/`createBillboardPhoto()` exist in legacy but are never called from
anywhere in the legacy app either). The inline-`images` approach is the confirmed-working fix; see
`git log -- lib/features/billboard/data/models/billboard_submit_payload_model.dart` for the change
and `billboard_photo_upload_request.dart`'s doc comment for more detail. Don't revert this to a
separate-endpoint pattern without first confirming the backend actually processes it.

Photos are captured via the shared camera at `lib/shared/ui/media/camera/` (auto-rotate control
icons to match physical device orientation, portrait-correct captures, manual rotate-in-viewer
fallback) — not billboard-specific, shared with premise's/investigation's photo capture too.

---

## GPS coordinate

One coordinate for the whole billboard record — `BillboardGpsSection` (its own top-level form
tab), backed by domain entity `BillboardGps`, using the shared `AppMapField` widget. Submitted as
a top-level `gps_details: {lat_census, long_census}` key (`BillboardGpsRequest`), read back the
same way from `/api/billboardCensus/detail`.

Premise adopted this exact same single-coordinate-per-record convention (moving away from a
per-address coordinate) to match billboard — see `lib/features/premise/README.md`'s GPS section.

---

## Target Structure (`ilms`)

```
lib/features/billboard/
├── README.md
├── domain/
│   ├── entities/         # billboard_form, billboard_gps, billboard_location,
│   │                      # billboard_media_owner, billboard_asset_owner, billboard_license,
│   │                      # billboard_remark, billboard_face, billboard_photo,
│   │                      # billboard_details, billboard_search_*, billboard_status_summary
│   ├── repositories/      # billboard_repository, billboard_draft_repository,
│   │                      # billboard_search_repository, billboard_status_summary_repository,
│   │                      # billboard_detail_repository
│   ├── utils/             # billboard_remark_codec.dart
│   └── exceptions/
├── data/
│   ├── datasources/       # api_billboard_data_source, api_billboard_search_remote_data_source,
│   │                      # api_billboard_detail_remote_data_source,
│   │                      # api_billboard_status_summary_remote_data_source,
│   │                      # local/billboard_draft_local_data_source, mock_* (tests only)
│   ├── mappers/           # billboard_form_mapper, billboard_draft_mapper,
│   │                      # billboard_status_summary_mapper
│   ├── models/            # billboard_submit_payload_model, billboard_photo_upload_request,
│   │                      # billboard_draft_payload_model, billboard_search_models,
│   │                      # billboard_status_summary_model
│   └── repositories/      # *_impl.dart for each domain repository
└── presentation/
    ├── pages/              # billboard_list_page, billboard_form_page, billboard_drafts_page
    ├── widgets/            # billboard_home_section, billboard_tile, billboard_face_dialog,
    │                       # billboard_search_filter_sheet, billboard_form_tab_bar,
    │                       # billboard_form_exit_sheet, billboard_section_header,
    │                       # billboard_activity_summary
    ├── controllers/        # billboard_form_controller, billboard_form_state,
    │                       # billboard_list_controller
    ├── sections/           # billboard_form_sections.dart (registry) + one file per tab
    └── providers/          # billboard_form_providers, billboard_providers,
                            # billboard_search_providers, billboard_draft_providers,
                            # billboard_status_summary_providers
```

Shared network helper used by billboard API (same as premise/investigation):

- `lib/core/network/form_data_builder.dart` — nested `FormData` for create/update (`images[0]`,
  `location_details[unit]`, etc.)
- `lib/core/network/api_response_helper.dart` — status/message parsing

---

## Form Sections (tab order)

| Tab | Section | Key behaviour |
|-----|---------|---------------|
| Details | `billboard_detail_section.dart` | Phase, description, billboard type, LED/light/potential toggles, hoarding dates |
| Location | `billboard_location_section.dart` | Media client name/tel, unit, address, postal, building, parliament/area pickers |
| GPS | `billboard_gps_section.dart` | Single coordinate, `AppMapField` (see GPS section above) |
| Media Owner | `billboard_media_owner_section.dart` | Media owner name/tel |
| Asset Owner | `billboard_asset_owner_section.dart` | Asset owner picker |
| License | `billboard_license_section.dart` | License file no. (uppercase text, no mask) |
| Remarks | `billboard_remarks_section.dart` | Single-select remark codes + "Others" free text |
| Faces | `billboard_faces_section.dart` | Add/edit/delete face dimensions (`billboard_face_dialog.dart`) |
| Photos | `billboard_photo_section.dart` | Camera/gallery capture, tap-to-preview, manual rotate (see photo section above) |

Registry: `billboard_form_sections.dart`

All free-text fields use `AppTextField(uppercase: true)` (auto-capslock, matches premise) except
numeric-only fields (postal, face width/height/count).

---

## Key User Flows

```
Home → Billboard group
  ├── View All → /billboard/list
  ├── New Entry → /billboard/form?mode=create
  └── Drafts → /billboard/drafts

Form → Photos tab → camera capture → auto-rotate correction → review strip → Done
Form → submit → create/update (photos inline) → local draft cleared
```

---

## API Layer (production)

| Concern | Class | Provider |
|---------|-------|----------|
| Create / update | `ApiBillboardDataSource` | `billboardDataSourceProvider` |
| Search | `ApiBillboardSearchRemoteDataSource` | `billboardSearchRemoteDataSourceProvider` |
| Detail | `ApiBillboardDetailRemoteDataSource` | `billboardDetailRemoteDataSourceProvider` |
| Status summary | `ApiBillboardStatusSummaryRemoteDataSource` | `billboardStatusSummaryRemoteDataSourceProvider` |

Mock implementations (`MockBillboardDataSource`, `MockBillboardSearchRemoteDataSource`) are **not**
wired in production — tests only.

---

## Tests

- `test/features/billboard/data/billboard_submit_payload_model_test.dart` — payload shape,
  including inline `images` and `gps_details`
- `test/features/billboard/data/billboard_form_mapper_test.dart`
- `test/features/billboard/data/billboard_photo_upload_request_test.dart` — legacy `/create-photo`
  helper, kept but unused by the main submit flow (see photo section above)

Camera tests (shared, not billboard-specific) live under `test/shared/ui/media/camera/`.

---

## Related Code (this repo)

| File | Role |
|------|------|
| `lib/shared/ui/media/camera/` | Shared camera module used for photo capture |
| `lib/shared/ui/forms/app_map_field.dart` | Shared GPS coordinate field (billboard + premise) |
| `lib/shared/ui/forms/app_text_field.dart` | Shared text field — `uppercase`, multiline `keyboardType` opt-in |
| `lib/shared/ui/layout/app_unfocus_on_tap.dart` | Tap-outside-to-unfocus wrapper on the form page body |
| `lib/app/router/app_router.dart` | Billboard routes |
| `lib/core/local/database/app_database.dart` | Drift DB incl. `billboard_draft_entries` |
