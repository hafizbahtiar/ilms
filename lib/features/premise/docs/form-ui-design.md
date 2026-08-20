# Form UI Design — Tab Bar + Scroll Sections

**Priority:** Form is built **first** (before search, drafts, history).

UX reference: standard **ecommerce / food delivery menu** — category tabs on top, menu sections scroll vertically below. Same mental model as Grab Food / Foodpanda category picker.

---

## Behaviour

| # | Requirement | Detail |
|---|-------------|--------|
| 1 | **Tab bar** | Horizontal tabs — one tab per form section (7 tabs, same grouping as legacy) |
| 2 | **Scroll sync → tab** | User scrolls the form → active tab updates to match the section currently in view |
| 3 | **Tab tap → scroll** | User taps a tab → form auto-scrolls to that section (smooth animate) |
| 4 | **Single scroll surface** | All sections on **one continuous page** — replaces legacy `PageController` + Next/Back wizard |

Legacy used 7 separate pages with Next/Back. New design keeps the **same 7 sections and data model** but presents them as anchored blocks inside one scroll view.

---

## Layout Wireframe

```
┌──────────────────────────────────────────┐
│  AppBar  Premise Census          [Save]  │
├──────────────────────────────────────────┤
│ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ...  │  ← sticky TabBar (horizontal scroll)
│ │ Co.│ │Det.│ │Addr│ │Lic.│ │Biz.│      │
│ └────┘ └────┘ └────┘ └────┘ └────┘      │
├──────────────────────────────────────────┤
│                                          │
│  ▼ Company & Contact  (section header)   │
│  [ fields … ]                            │
│                                          │
│  ▼ Premise Details                       │
│  [ fields … ]                            │
│                                          │
│  ▼ Premise Address                       │
│  [ fields … ]                            │
│                                          │
│  … (License, Business, Remarks, Images)  │
│                                          │
├──────────────────────────────────────────┤
│              [ Submit ]                  │  ← fixed bottom bar or FAB
└──────────────────────────────────────────┘
```

Tab bar stays **pinned** under the app bar while the form body scrolls (`NestedScrollView` or `CustomScrollView` + `SliverPersistentHeader`).

---

## Section Registry

Central config drives tabs, scroll targets, and file mapping — do not hardcode tab labels inside the page widget.

```dart
// presentation/sections/premise_form_sections.dart
class PremiseFormSectionDef {
  const PremiseFormSectionDef({
    required this.id,
    required this.tabLabel,
    required this.headerTitle,
    required this.builder,
    this.isRequired = false,
  });

  final String id;           // 'company', 'details', 'address', …
  final String tabLabel;     // short label for tab bar
  final String headerTitle;  // full title inside scroll body
  final WidgetBuilder builder;
  final bool isRequired;     // legacy pages 1–3
}
```

| id | Tab label | Header | Required | Legacy controller |
|----|-----------|--------|----------|-----------------|
| `company` | Company | Company & Contact Details | Yes | `PrCompDetailController` |
| `details` | Details | Premise Details | Yes | `PrVisitController` |
| `address` | Address | Premise Address | Yes | `PrAddressController` |
| `license` | License | License Information | No | `PrLicenseController` |
| `business` | Business | Business Activities | No | `PrBusinessController` |
| `remarks` | Remarks | Remarks | No | `PrRemarkController` |
| `images` | Images | Census Images | No | `PrCencusImageController` |

---

## File Structure (one section per file)

```
presentation/
├── pages/
│   └── premise_form_page.dart              # shell only: scaffold, tab bar, scroll, submit
├── sections/
│   ├── premise_form_sections.dart          # registry + section defs
│   ├── company_contact_section.dart        # fields for page 1
│   ├── premise_details_section.dart        # fields for page 2
│   ├── premise_address_section.dart        # fields for page 3
│   ├── license_section.dart
│   ├── business_activity_section.dart
│   ├── remarks_section.dart
│   └── census_images_section.dart
├── widgets/
│   ├── premise_form_tab_bar.dart           # horizontal tabs, selected state
│   ├── premise_section_header.dart         # in-scroll section title divider
│   └── premise_form_scroll_scope.dart      # scroll sync logic (optional extract)
└── controllers/
    └── premise_form_controller.dart        # orchestrator — no field widgets here
```

Rules:

- **`premise_form_page.dart`** — layout + wiring only. No field definitions.
- **Each `*_section.dart`** — owns its fields, validators, and section-local widgets.
- **Controller** — aggregates section state, validation, save/submit. Sections read/write via provider/notifier.

---

## Scroll ↔ Tab Sync (implementation notes)

### Scroll → update active tab

1. Assign each section a `GlobalKey` (or use `Scrollable.ensureVisible`).
2. Listen to scroll (`ScrollController` listener or `NotificationListener<ScrollNotification>`).
3. On scroll end / throttle (~100ms), find which section's top edge is nearest below the tab bar.
4. Update `activeSectionId` in controller → tab bar rebuilds highlight.
5. Optionally auto-scroll tab bar horizontally so the active tab stays visible.

### Tab tap → scroll to section

1. User taps tab → set `activeSectionId` + `_isProgrammaticScroll = true`.
2. `Scrollable.ensureVisible(sectionKey.currentContext!, duration: …, alignment: 0)` or scroll to computed offset (account for pinned header height).
3. Clear `_isProgrammaticScroll` after animation — prevents scroll listener fighting the tap.

Guard against feedback loops: while `_isProgrammaticScroll`, ignore scroll-driven tab updates.

### Suggested Flutter building blocks

| Approach | Pros |
|----------|------|
| `NestedScrollView` + `TabBar` + sliver sections | Native sticky header, familiar pattern |
| `CustomScrollView` + `SliverPersistentHeader` (pinned) + section `SliverToBoxAdapter`s | Full control over section heights |
| `scroll_to_index` / manual offset map | Works if section heights are dynamic — measure after layout |

Pick one during implementation; document the choice in a code comment on `premise_form_page.dart`.

---

## Validation & Submit

Legacy validated sections 1–3 before Next. New UX options (pick one at implement time):

| Strategy | When |
|----------|------|
| **Submit-time** | Validate all required sections on Submit; scroll to first error section + flash tab |
| **Section blur** | Validate when user leaves a section (scroll past) — softer feedback |

Recommended: **submit-time** + on failure **auto-scroll + select tab** of first invalid section (reuses tab→scroll machinery).

Optional sections (4–7) unchanged from legacy — not blocking submit.

Submit opens bottom sheet for visit status (same as legacy `PremisSubmitView`).

---

## Persistence Triggers (adapted from legacy)

Legacy saved on **Next** per page. Single-scroll form has no Next — remap triggers:

| Trigger | Save scope |
|---------|------------|
| Field debounce (e.g. 500ms idle) | Current section |
| Section exit (scroll leaves section) | Section being left |
| **Save & Exit** app bar action | All sections |
| App background / lifecycle | All sections (`autosaveOnBackground`) |
| After duplicate pre-fill | All sections (post-frame) |

Local DB contract unchanged — see [local-persistence.md](local-persistence.md). Only the **UI trigger** changes.

---

## View / Edit / Create Modes

Same `PremisFormState` as legacy. Tab bar + scroll layout used for all modes:

| Mode | Tab bar | Scroll | Fields |
|------|---------|--------|--------|
| `create` / `draft` / `duplicate` | Enabled | Enabled | Editable |
| `edit` | Enabled | Enabled | Editable |
| `view` | Enabled | Enabled | Read-only (or hide submit) |

---

## Phase 1 Scope (form first)

Build in this order:

1. `premise_form_sections.dart` registry + empty section stubs
2. `premise_form_page.dart` — tab bar + scroll sync (no real fields yet)
3. `company_contact_section.dart` — first real section
4. Remaining sections one by one
5. `premise_form_controller.dart` — wire validation + mock submit
6. Route: `/premise/form?mode=create` from home **New Entry**

Defer until later phases: search, Drift tables, draft sheet, API, photo retry.

---

## Testing Checklist

- [ ] Tap each tab → scroll lands at correct section header
- [ ] Slow scroll through form → active tab tracks current section
- [ ] Fast fling → tab settles correctly after scroll ends
- [ ] Programmatic scroll (validation error) → correct tab selected
- [ ] Tab bar scrolls horizontally when active tab is off-screen
- [ ] View mode — tabs still navigable, fields disabled
- [ ] No tab/scroll feedback loop during animated scroll
