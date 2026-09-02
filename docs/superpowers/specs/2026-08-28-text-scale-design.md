# Text Scale & Typography Design

**Goal:** Add a default typography baseline and user-adjustable text size that multiplies with the OS accessibility text scale.

## Scope

This design covers:

- A centralized `TextTheme` baseline (default text sizes) applied through `AppTheme`
- User-selectable text size presets persisted in `AppPreferences`
- App-wide scaling via `MaterialApp.builder` + `TextScaler.linear(appFactor × osFactor)`
- A Profile settings entry (and optional login-page shortcut) to change text size
- Unit tests for controller, typography, and app wiring

This design does not cover:

- Per-screen text size overrides
- Migrating every hardcoded `fontSize` in the codebase (only the shared theme + a few high-traffic widgets in the first pass)
- Font family changes (Poppins stays the app default)
- Web-specific typography tweaks

## Constraints

- Follow the existing `lib/app/theme/` + Riverpod `StateNotifier` + `AppPreferences` pattern used by `ThemeModeController`.
- Keep typography definitions in one place; widgets should prefer `Theme.of(context).textTheme` over inline `fontSize`.
- Combined scale (`app × OS`) must be clamped to a safe maximum to reduce layout breakage on dense screens (maps, charts, module grids).
- Use `google_fonts` (already in `pubspec.yaml`) for the base font family.
- Malay/English UI copy is fine; labels follow existing Profile settings style (English, like Theme).

## Feature Structure

New and modified files live under `lib/app/theme/` (app shell concern, same layer as theme mode):

| File | Responsibility |
|------|----------------|
| `app_typography.dart` | Base `TextTheme` factory (Poppins, Material 3 type scale) |
| `text_scale.dart` | `AppTextScale` enum, factors, labels, options list |
| `text_scale_controller.dart` | Load/save preference, expose Riverpod provider |
| `app_theme.dart` | Wire `textTheme` into both light/dark themes |
| `app.dart` | `MaterialApp.builder` applies combined `TextScaler` |

Presentation touchpoints:

| File | Responsibility |
|------|----------------|
| `lib/features/profile/presentation/widgets/profile_tab_view.dart` | Settings tile + bottom sheet (mirror Theme UX) |
| `lib/features/auth/presentation/pages/login_page.dart` | Optional: no change in v1 (Profile only) |

Tests mirror production layout under `test/app/theme/`.

## Domain Model

### `AppTextScale`

Discrete presets the user can pick:

| Preset | Storage key | App factor | Label |
|--------|-------------|------------|-------|
| `small` | `small` | `0.85` | Small |
| `medium` | *(absent)* | `1.0` | Default |
| `large` | `large` | `1.15` | Large |
| `extraLarge` | `extra_large` | `1.30` | Extra Large |

`medium` is the default; when selected, the preference key is removed (same pattern as `ThemeMode.system`).

### Combined scale

```
effectiveScale = clamp(appFactor × osTextScaleFactor, min: 0.8, max: 1.6)
```

- `osTextScaleFactor` comes from `MediaQuery.textScalerOf(context).scale(1.0)` before the app override is applied (read the platform scaler from the incoming `MediaQuery` in `builder`).
- Clamping protects module grids, charts, and map overlays from blowing past usable layout bounds while still respecting accessibility up to a reasonable ceiling.

## Typography Baseline

### `AppTypography`

Factory: `static TextTheme textTheme({required Brightness brightness})`

Uses `GoogleFonts.poppinsTextTheme()` as the base, then applies Material 3 sizes tuned for ILMS:

| Role | Size | Weight | Typical use |
|------|------|--------|-------------|
| `displaySmall` | 32 | w700 | Rare hero text |
| `headlineSmall` | 24 | w700 | Section titles |
| `titleLarge` | 20 | w700 | Card headers, sheet titles |
| `titleMedium` | 16 | w600 | List tile titles |
| `bodyLarge` | 16 | w400 | Primary body |
| `bodyMedium` | 14 | w400 | Secondary body, subtitles |
| `bodySmall` | 12 | w400 | Captions, hints |
| `labelLarge` | 14 | w600 | Buttons |
| `labelMedium` | 12 | w600 | Chips, badges |
| `labelSmall` | 11 | w500 | Fine print |

Colors come from the active `ColorScheme.onSurface` (and variants) inside `AppTheme._build`, not inside `AppTypography`, so light/dark stay consistent with existing theme tokens.

`primaryTextTheme` mirrors `textTheme` for AppBar/title contexts.

## State Management

### `TextScaleController`

Mirrors `ThemeModeController`:

```dart
class TextScaleController extends StateNotifier<AppTextScale> {
  TextScaleController(this._preferences) : super(_load(_preferences));

  static const _prefsKey = 'text_scale';
  // _load, setScale(AppTextScale scale) with persistence
}

final textScaleControllerProvider =
    StateNotifierProvider<TextScaleController, AppTextScale>((ref) {
  return TextScaleController(AppPreferences.instance);
});
```

Helpers (same file or `text_scale.dart`):

- `List<AppTextScale> textScaleOptions()`
- `String textScaleLabel(AppTextScale scale)`
- `double textScaleFactor(AppTextScale scale)`

## App Wiring

Both `MaterialApp` instances in `app.dart` (splash + router) share a private builder:

```dart
Widget _wrapWithTextScale(BuildContext context, Widget? child) {
  final appScale = ref.watch(textScaleControllerProvider).factor;
  final mq = MediaQuery.of(context);
  final osScale = mq.textScaler.scale(1.0);
  final combined = (appScale * osScale).clamp(0.8, 1.6);
  return MediaQuery(
    data: mq.copyWith(textScaler: TextScaler.linear(combined)),
    child: child!,
  );
}
```

`ref` is available because `App` is a `ConsumerStatefulWidget`.

## UI

### Profile settings

Add a `ProfileSettingTile` below Theme:

- Icon: `Icons.format_size`
- Title: `Text size`
- Subtitle: `Adjust reading comfort`
- Trailing: current label from `textScaleLabel(ref.watch(textScaleControllerProvider))`
- Tap: bottom sheet with `RadioGroup<AppTextScale>` (same pattern as theme sheet)

Changes apply immediately on selection (no restart).

## Hardcoded `fontSize` audit (v1)

These files use inline `fontSize` today and will inherit scaling via `TextScaler` without migration, but should be migrated to `textTheme` when touched:

- `lib/shared/ui/home/home_module_button.dart`
- `lib/shared/ui/controls/environment_switcher.dart`
- `lib/features/home/presentation/pages/home_page.dart` (also uses raw `GoogleFonts.poppins` — move to theme)
- `lib/features/profile/presentation/widgets/profile_tab_view.dart`
- `lib/features/profile/presentation/widgets/profile_widgets.dart`
- `lib/shared/ui/app_bars/app_search_app_bar.dart`
- `lib/shared/ui/media/camera/camera_scaffold.dart`
- `lib/shared/ui/media/camera/camera_status_view.dart`
- `lib/shared/ui/media/app_image_grid_sheet.dart`
- `lib/features/change_password/presentation/widgets/password_strength_indicator.dart`

v1 explicitly migrates `home_page.dart` and `home_module_button.dart` to `textTheme` so the home grid reflects the new baseline.

## Testing

| Test file | Covers |
|-----------|--------|
| `text_scale_controller_test.dart` | Default, persist, restore, remove key on default |
| `app_typography_test.dart` | Key roles exist, sizes/weights match spec |
| `app_theme_test.dart` | `textTheme` present on light/dark |
| `app_text_scale_builder_test.dart` | Combined + clamp math via a minimal `MaterialApp` harness |

Widget test for Profile sheet is optional in v1; controller + builder tests are required.

## Success Criteria

- Fresh install renders at Default (1.0×) with Poppins `TextTheme` on all `Theme.of(context).textTheme` consumers.
- Selecting Large persists across restart and visibly enlarges text app-wide.
- OS accessibility increase still applies on top of the in-app preset (multiply), capped at 1.6×.
- Profile settings shows current preset and allows switching without app restart.
