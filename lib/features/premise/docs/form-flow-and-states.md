# Form Flow & States

Form behaviour inherited from legacy — **presentation differs** in `ilms`.

| | Legacy (`ilms_flutter`) | New (`ilms`) |
|---|-------------------------|--------------|
| Navigation | 7 pages, `PageController`, Next/Back | Single scroll + sticky tab bar |
| Section files | `sections/*.dart` per page | Same split — [form-ui-design.md](form-ui-design.md) |
| Save on Next | Yes (per page) | Remapped — debounce / section exit / Save & Exit |

UI spec: **[form-ui-design.md](form-ui-design.md)**

---

## Form States (`PremisFormState`)

```dart
enum PremisFormState {
  create,     // New visit — auto-creates local draft row on open
  draft,      // Resume unsynced local draft
  view,       // Read-only synced record
  duplicate,  // Clone existing record into new draft
  edit,       // Edit submitted record via scratch local row
}
```

Extension getters (legacy):

| Getter | Meaning |
|--------|---------|
| `canMapData` | `draft` or `edit` — load mapped local/server data |
| `isTransient` | Not `view` or `edit` — create/draft/duplicate lifecycle |
| `shouldPersist` | `view` or `edit` |
| `isCreateNDuplicate` | `create` or `duplicate` |

---

## Seven Form Pages

| # | Title | Section widget | Controller | Validated? |
|---|-------|----------------|------------|------------|
| 1 | Company & Contact Details | `PremisCompDetailsSection` | `PrCompDetailController` | Yes |
| 2 | Premise Details | `PremisDetailSection` | `PrVisitController` | Yes |
| 3 | Premise Address | `PremisAddressSection` | `PrAddressController` | Yes |
| 4 | License Information | `PremisLicenseSection` | `PrLicenseController` | No |
| 5 | Business Activities | `PremisBusinessActivitySection` | `PrBusinessController` | No |
| 6 | Remarks | `PremisRemarkSection` | `PrRemarkController` | No |
| 7 | Census Images | `PremisCensusImageSection` | `PrCencusImageController` | No |

Navigation: legacy used `PageController` + Next/Back. **New app** uses one scroll view — see [form-ui-design.md](form-ui-design.md). Last step still opens submit sheet for visit status selection.

---

## When Data Is Saved Locally

Legacy triggers (still valid for **what** to save; **when** adapts for tab-scroll UI):

| Legacy trigger | New UI equivalent |
|----------------|-------------------|
| **Next** (transient states) | Section exit on scroll, or debounced field save |
| **Save & Exit** | App bar action — all sections |
| **Background / lifecycle** | Unchanged — `autosaveOnBackground()` all sections |
| **Init post-frame** | Unchanged — after duplicate pre-fill |
| **Image capture** | Unchanged — immediate per photo |

| Trigger | What gets saved |
|---------|-----------------|
| Section idle / leave (transient) | Current section via `section.saveOffline(premisID:)` |
| **Save & Exit** | All sections |
| **Background / lifecycle** | All sections except images (images save per capture) |
| **Init post-frame** | `_persistAllSections()` after duplicate pre-fill |
| **Image capture** | Immediate per-photo write |

Create flow: first local row created via `saveLocalPremise()` → `PremisDataLocalDatasource.insert()`.

---

## Submit Flow (high level)

1. Build domain `PremiseForm` from section state via `PremiseFormMapper`.
2. Call `ApiPremiseDataSource.create` or `update` (FormData via `FormDataBuilder`).
3. On success → `visit_no` returned; upload pending local photos via `/create-photo` (`process: create|update`).
4. Mark local draft synced when applicable.

Pending submission retry queue — **not implemented yet** (legacy `pending_submissions`).

---

## Special Flows

### Duplicate

1. User picks existing record from `PremiseDuplicatePage` ([duplicate-search.md](duplicate-search.md)).
2. App calls `PremiseDuplicateRepository.createDraftFromRecord`:
   - `checkCanDuplicate(visitNo)` — blocked if source is current phase.
   - `loadDetail(visitNo)` — API detail mapped via `PremiseDetailMapper.fromApiDetailForDuplicate`.
   - Saves Drift draft; **no census images or remarks** in payload.
3. Form opens on `/premise/form?mode=draft&localId=…` with text fields pre-filled.
4. User edits and submits as a new visit (`ApiPremiseDataSource.create`).

Legacy reference: `PremisDuplicateSearchView` + `duplicateFromSearch()` in `PremisFormController`.

**Legacy difference:** Legacy duplicates remarks (with server ids stripped). `ilms` intentionally starts with an empty remarks tab. Legacy also skips census images in duplicate mode — `ilms` matches that for images.

### Edit (submitted record)

1. `editForm()` creates scratch row: `isEditSession: true`, `visitNo`, `updatedAt`.
2. Row is **excluded** from normal Draft list but shown in Draft sheet under "Unsaved Edit".
3. Search tiles show unsaved-edit tag via `watchEditSessionVisitNos()`.
4. Discard → `discardEditSession()` deletes scratch row + cascaded children.
5. Submit → update API; cleanup edit session row.

### View

Read-only. Data fetched with `_fetchPremisData(visitNo)` → `PremisRepo.viewPremises`.

### QR create

Flag `_isQrCreate` — license data can be prefilled from QR scan (`LicenseQrResponseModel`).

---

## Exit / Unsaved UX

| Scenario | UI |
|----------|-----|
| Back with transient draft | `premise_form_exit_sheet.dart` — Save & Exit / Delete draft / Exit without saving |
| Search screen back with active draft | Exit Anyway / Clear Draft |
| Edit session abandon | `discardEditSession()` |

`PremisFormView` registers `AppLifecycleListener` / lifecycle observer → `autosaveOnBackground()`.

---

## Target Mapping (`ilms`)

| Legacy | Target |
|--------|--------|
| `PremisFormController` | `PremiseFormController` (Riverpod `Notifier`) |
| Section `ChangeNotifier` | Section notifiers or form sub-states |
| `Provider` tree in search | Riverpod providers scoped under `premiseFormProvider` |
| `PageController` | **`ScrollController` + section keys + tab sync** — [form-ui-design.md](form-ui-design.md) |
| `PremisCompDetailsSection`, etc. | `company_contact_section.dart`, … (one file per section) |

Keep the same state machine and save semantics — they prevent data loss bugs already fixed in legacy. Only navigation/presentation changes.
