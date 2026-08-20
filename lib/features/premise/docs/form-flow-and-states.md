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

1. Build `PremiseInputModel` from all section controllers.
2. Call `PremisRepo.createPremises` or `updatePremises`.
3. On network failure → enqueue full JSON payload to `pending_submissions`.
4. On success → mark local row `isSync: true`; kick off photo upload for new bytes.
5. Show success dialog; navigate back (duplicate flow has special pop target).

Edit submit requires `updatedAt` from server (optimistic concurrency) — stored on edit-session scratch row.

---

## Special Flows

### Duplicate

1. User picks existing record from `PremisDuplicateSearchView`.
2. Form opens in `duplicate` state with all sections pre-filled from server.
3. `_persistAllSections()` runs post-frame so kill-safe.
4. `linkLicenseToBusiness()` syncs license ↔ business activity links after local IDs assigned.

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
| Back with transient draft | `premis_unsave_draft_dialog.dart` — Save & Exit / Discard |
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
