# shared/ui improvement TODO

Survey of `lib/shared/ui` for responsiveness gaps, reuse duplication, and
overflow-risk patterns — same spirit as the `AppListView` landscape/grid fix
(see `lists/app_list_view.dart` and the premise/billboard/investigation tile
fixed-extent changes). Skipped `camera/`, `map/`, `web/` (native/full-screen,
unlikely to need this treatment).

## High

- [x] **`sheets/app_bottom_sheet.dart`** — `_AppBottomSheetShell.build` now
  wraps the compact/scrollable content in `Align(bottomCenter)` +
  `ConstrainedBox(maxWidth: 560)`, so the sheet centers and caps instead of
  stretching edge-to-edge on tablet/landscape. Verified against the existing
  `app_bottom_sheet_test.dart` suite (all pass) and `flutter analyze`.
- [x] **`sheets/app_option_picker_sheet.dart`** — no separate change needed:
  `showAppOptionPicker` / `showAppMultiOptionPicker` route entirely through
  `showAppBottomSheet`, so they inherit the width cap above automatically.

## Medium

- **`sheets/app_option_picker_sheet.dart`** — `_OptionPickerList` and
  `_MultiOptionPickerList` (~150 lines each) are near-duplicates: identical
  search field, filtering, `AnimatedSwitcher` cross-fade, and list-building
  logic, differing only in single- vs multi-select semantics. Extract one
  shared body parameterized by selection mode.
- **`layout/responsive_two_column.dart`** — solid width-breakpoint widget
  (same pattern used to fix the list grid) but only consumed by
  `company_contact_section.dart`. Audit other multi-field form sections that
  likely still stack fields full-width on tablet landscape.
- **`home/home_module_grid.dart`** — `maxColumns` is a caller-supplied
  constant clamped to 1–4, not derived from available width; home module
  buttons don't gain columns on wide/tablet screens the way the list grid
  now does.
- **`app_bars/app_search_app_bar.dart`** — `_SearchChipBar` (~line 190):
  search `TextField` uses hardcoded `fillColor: Colors.white` instead of a
  `colorScheme` token; breaks dark-mode contrast (only looks fine now
  because the app bar background is also light-ish by default).

## Low

- **`media/app_image_grid_sheet.dart`** — `crossAxisCount` fixed at 3; not
  broken (cells widen via `SliverGridDelegateWithFixedCrossAxisCount`) but
  could scale count up on very wide sheets for better density.
- Not deeply audited yet: `forms/app_text_field.dart`,
  `forms/app_image_field.dart`, `forms/app_map_field.dart` — worth a
  follow-up pass.
