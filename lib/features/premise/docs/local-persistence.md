# Local Persistence

How premise data is stored offline in legacy — blueprint for extending `ilms` `AppDatabase`.

---

## Database Stack

| Legacy | `ilms` (current / target) |
|--------|---------------------------|
| Drift + `AppDatabase` singleton | Drift + `AppDatabase.init()` in `local_storage_bootstrap.dart` |
| Many premise-specific tables | **Not yet added** — only `KeyValueEntries` today |
| File bytes for photos | `InternalStorageManager` (`ilms_storage/`) — use for large blobs |

---

## Table Overview

Root table **`premis_data`** — one row per local premise session.

| Column | Purpose |
|--------|---------|
| `id` | Local auto-increment PK |
| `companyName`, `traderName` | Display in draft list |
| `isSync` | `false` until successfully submitted |
| `isActive` | Soft-delete flag |
| `visitNo` | Server visit number (set after sync or on edit session) |
| `isEditSession` | Scratch row for in-progress **edit** of synced record |
| `updatedAt` | Server timestamp captured at edit start (concurrency check) |
| `createdDate`, `updateDate`, `syncDate` | Audit |

Child tables (FK → `premis_data.id`, cascade delete):

| Table | Content |
|-------|---------|
| `p_company_details` | Company identity, visit status, census date |
| `p_contact_person` | Contact fields |
| `p_premise_details` | Trader name, types, dimensions |
| `p_premise_addresses` | Address lines, parliament, postcode |
| `p_license_information` | Licenses + attachment refs |
| `p_business_activities` | Business type rows |
| `p_remarks` | Remark codes |
| `p_census_images` | Photo metadata + local file path / upload state |
| `p_pending_submissions` | Failed submit retry queue |

Legacy table exports: `ilms_flutter/lib/data/local/local-sqflite/tables/premis-table/premis_tables.dart`

---

## Orchestrator: `PremisDataLocalDatasource`

Central API used by form controller:

| Method | Use |
|--------|-----|
| `insert()` | Create/update root row; handles `isEditSession`, `visitNo`, `isSync` |
| `findEditSessionRow(visitNo)` | Resume unsaved edit (only `isSync == false`) |
| `getRow(premisId)` | Read root metadata when resuming |
| `watchUnSyncData()` | **Draft list** — excludes `isEditSession` rows |
| `watchEditSessionRows()` | **Unsaved edit** section in draft sheet |
| `watchEditSessionVisitNos()` | Tags on search result tiles |
| `watchCountUnSyncData()` | Draft counter badge |
| `deletePremise(premisId)` | Cascade delete draft / discard edit session |
| `getFullPremisData(premisId)` | Hydrate all child tables into DTO |

Each child table has its own datasource (e.g. `PCompanyDetailsLocalDatasource`) implementing `saveOffline` / `loadOffline` for its section.

---

## Draft vs Edit Session

Two different offline concepts — do not merge them in UI or queries.

```
┌─────────────────────────────────────────────────────────────┐
│  NEW PREMISE DRAFT                                          │
│  isEditSession = false, isSync = false                      │
│  Shown in: Draft counter, Draft sheet ("Draft Premis")      │
│  Created by: create / duplicate flow                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  EDIT SESSION (scratch row)                                 │
│  isEditSession = true, isSync = false, visitNo = server id  │
│  Shown in: Draft sheet ("Unsaved Edit"), search tile tag    │
│  NOT counted in generic draft counter                       │
│  Created by: editForm() on submitted record                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Pending Submissions Queue

**Table:** `p_pending_submissions`

| Column | Purpose |
|--------|---------|
| `premisId` | Link to local row |
| `payload` | Full JSON (`toJson()` or `toJsonUpdate()`) |
| `action` | `'create'` or `'update'` |
| `status` | `'pending'` / `'failed'` |
| `retryCount`, `errorMessage` | Retry diagnostics |

**Controller:** `PremisRetryController`

- On submit network error → `insert` payload.
- `retryOne` / `retryAll` on search screen banner.
- Must use `PremiseInputModel.fromJson` vs `fromJsonUpdate` based on `action`.

---

## Census Images & Photo Retry

**Table:** `p_census_images` — stores metadata, upload seq, visitNo after submit.

**Two-phase upload:**

1. Main form submit sends premise JSON (images may be bytes or omitted).
2. `PremisPhotoUploadController.uploadAll()` posts each file to `/create-photo`.

If app dies mid-upload:

- Rows remain with pending flag + `visitNo`.
- `PremisPhotoRetryController` loads via `PCensusImagesLocalDatasource.getPendingUploads()`.
- Search screen shows `PremisPendingPhotosBanner`.

Seq numbering: counts across all images of same `type` so new photos don't collide with server seq on edit.

---

## Stream Subscription Notes (legacy lessons)

`PremisDraftSheet` subscribes once to `watchUnSyncData()` and `watchEditSessionRows()` in `initState` — avoids nested `StreamBuilder` re-subscribe flicker.

`PremisSearchView` hoists `watchEditSessionVisitNos()` stream instance to state field for same reason.

Port these patterns when building Riverpod `StreamProvider`s (use stable provider, not recreating stream each build).

---

## `ilms` Implementation Checklist

- [ ] Add premise tables to `app_database.dart` (schema version bump + migration).
- [ ] Create `PremiseLocalDataSource` interface + Drift impl (mirror orchestrator API).
- [ ] One local datasource per child table under `data/datasources/local/`.
- [ ] Domain repository `PremiseLocalRepository` — UI never touches Drift directly.
- [ ] Store photo files via `InternalStorageManager`; DB holds path + upload state only.
- [ ] Port critical tests from `ilms_flutter/test/premis/` especially edit-session and retry parsing.
