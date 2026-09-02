# Text Scale & Typography Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a default Poppins `TextTheme` and user-adjustable text size presets that multiply with OS accessibility scale.

**Architecture:** Typography lives in `lib/app/theme/` alongside existing theme mode code. `AppTypography` defines the baseline `TextTheme`; `TextScaleController` persists the user's preset via `AppPreferences`; `App.builder` applies `TextScaler.linear(appFactor × osFactor)` with clamping. Profile settings mirrors the Theme bottom-sheet UX.

**Tech Stack:** Flutter, flutter_riverpod, google_fonts, shared_preferences, flutter_test

**Spec:** `docs/superpowers/specs/2026-08-28-text-scale-design.md`

## Global Constraints

- Follow the existing `ThemeModeController` + `AppPreferences` + Riverpod pattern.
- Combined text scale = `clamp(appFactor × osFactor, 0.8, 1.6)`.
- Default preset (`medium`, factor `1.0`) removes the stored preference key.
- Widgets should use `Theme.of(context).textTheme`; avoid new inline `fontSize` values.
- Use `google_fonts` / Poppins for the baseline theme.
- Profile settings copy in English (consistent with Theme setting).

---

## File Structure

### New production files

- `lib/app/theme/app_typography.dart` — baseline `TextTheme` factory
- `lib/app/theme/text_scale.dart` — `AppTextScale` enum, factors, labels
- `lib/app/theme/text_scale_controller.dart` — persistence + Riverpod provider

### Modified production files

- `lib/app/theme/app_theme.dart` — attach `textTheme` / `primaryTextTheme`
- `lib/app/app.dart` — `builder` for combined `TextScaler`
- `lib/features/profile/presentation/widgets/profile_tab_view.dart` — settings tile + sheet
- `lib/features/home/presentation/pages/home_page.dart` — drop inline `GoogleFonts.poppins`
- `lib/shared/ui/home/home_module_button.dart` — use `textTheme` instead of inline `fontSize`

### New test files

- `test/app/theme/text_scale_controller_test.dart`
- `test/app/theme/app_typography_test.dart`
- `test/app/theme/app_text_scale_builder_test.dart`

### Modified test files

- `test/app/theme/app_theme_test.dart` — assert `textTheme` wired

---

### Task 1: AppTextScale model & helpers

**Files:**
- Create: `lib/app/theme/text_scale.dart`
- Test: `test/app/theme/text_scale_test.dart`

**Interfaces:**
- Produces: `enum AppTextScale { small, medium, large, extraLarge }`
- Produces: `double appTextScaleFactor(AppTextScale scale)`
- Produces: `String textScaleLabel(AppTextScale scale)`
- Produces: `List<AppTextScale> textScaleOptions()`
- Produces: `String? textScaleStorageKey(AppTextScale scale)` — `null` for `medium`

- [ ] **Step 1: Write the failing test**

```dart
// test/app/theme/text_scale_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/text_scale.dart';

void main() {
  test('medium is the default factor', () {
    expect(appTextScaleFactor(AppTextScale.medium), 1.0);
  });

  test('all presets expose labels and ordered options', () {
    expect(textScaleOptions(), [
      AppTextScale.small,
      AppTextScale.medium,
      AppTextScale.large,
      AppTextScale.extraLarge,
    ]);
    expect(textScaleLabel(AppTextScale.large), 'Large');
  });

  test('medium has no storage key', () {
    expect(textScaleStorageKey(AppTextScale.medium), isNull);
    expect(textScaleStorageKey(AppTextScale.small), 'small');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app/theme/text_scale_test.dart`
Expected: FAIL — `text_scale.dart` not found

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/app/theme/text_scale.dart
enum AppTextScale { small, medium, large, extraLarge }

const _textScaleOptions = [
  AppTextScale.small,
  AppTextScale.medium,
  AppTextScale.large,
  AppTextScale.extraLarge,
];

List<AppTextScale> textScaleOptions() => _textScaleOptions;

double appTextScaleFactor(AppTextScale scale) {
  switch (scale) {
    case AppTextScale.small:
      return 0.85;
    case AppTextScale.medium:
      return 1.0;
    case AppTextScale.large:
      return 1.15;
    case AppTextScale.extraLarge:
      return 1.30;
  }
}

String textScaleLabel(AppTextScale scale) {
  switch (scale) {
    case AppTextScale.small:
      return 'Small';
    case AppTextScale.medium:
      return 'Default';
    case AppTextScale.large:
      return 'Large';
    case AppTextScale.extraLarge:
      return 'Extra Large';
  }
}

String? textScaleStorageKey(AppTextScale scale) {
  switch (scale) {
    case AppTextScale.medium:
      return null;
    case AppTextScale.small:
      return 'small';
    case AppTextScale.large:
      return 'large';
    case AppTextScale.extraLarge:
      return 'extra_large';
  }
}

AppTextScale appTextScaleFromStorage(String? value) {
  switch (value) {
    case 'small':
      return AppTextScale.small;
    case 'large':
      return AppTextScale.large;
    case 'extra_large':
      return AppTextScale.extraLarge;
    default:
      return AppTextScale.medium;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/app/theme/text_scale_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/theme/text_scale.dart test/app/theme/text_scale_test.dart
git commit -m "feat: add AppTextScale presets and helpers"
```

---

### Task 2: TextScaleController persistence

**Files:**
- Create: `lib/app/theme/text_scale_controller.dart`
- Test: `test/app/theme/text_scale_controller_test.dart`

**Interfaces:**
- Consumes: `AppTextScale`, `appTextScaleFromStorage`, `textScaleStorageKey`, `appTextScaleFactor` from `text_scale.dart`
- Consumes: `AppPreferences`
- Produces: `textScaleControllerProvider` — `StateNotifierProvider<TextScaleController, AppTextScale>`

- [ ] **Step 1: Write the failing test**

```dart
// test/app/theme/text_scale_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/text_scale.dart';
import 'package:ilms/app/theme/text_scale_controller.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPreferences.reset();
    await AppPreferences.init();
  });

  tearDown(AppPreferences.reset);

  test('defaults to medium when nothing is stored', () {
    final controller = TextScaleController(AppPreferences.instance);
    expect(controller.state, AppTextScale.medium);
  });

  test('setScale updates state and persists the selection', () async {
    final controller = TextScaleController(AppPreferences.instance);
    await controller.setScale(AppTextScale.large);
    expect(controller.state, AppTextScale.large);
    expect(AppPreferences.instance.getString('text_scale'), 'large');
  });

  test('persisted selection is restored on a new controller', () async {
    final controller = TextScaleController(AppPreferences.instance);
    await controller.setScale(AppTextScale.small);
    final restored = TextScaleController(AppPreferences.instance);
    expect(restored.state, AppTextScale.small);
  });

  test('setScale to medium removes the stored key', () async {
    final controller = TextScaleController(AppPreferences.instance);
    await controller.setScale(AppTextScale.large);
    await controller.setScale(AppTextScale.medium);
    expect(controller.state, AppTextScale.medium);
    expect(AppPreferences.instance.getString('text_scale'), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app/theme/text_scale_controller_test.dart`
Expected: FAIL — controller not found

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/app/theme/text_scale_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/app/theme/text_scale.dart';
import 'package:ilms/core/local/preferences/app_preferences.dart';

class TextScaleController extends StateNotifier<AppTextScale> {
  TextScaleController(this._preferences) : super(_load(_preferences));

  static const _prefsKey = 'text_scale';
  final AppPreferences _preferences;

  static AppTextScale _load(AppPreferences preferences) {
    return appTextScaleFromStorage(preferences.getString(_prefsKey));
  }

  Future<void> setScale(AppTextScale scale) async {
    state = scale;
    final key = textScaleStorageKey(scale);
    if (key == null) {
      await _preferences.remove(_prefsKey);
    } else {
      await _preferences.setString(_prefsKey, key);
    }
  }
}

final textScaleControllerProvider =
    StateNotifierProvider<TextScaleController, AppTextScale>((ref) {
  return TextScaleController(AppPreferences.instance);
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/app/theme/text_scale_controller_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/theme/text_scale_controller.dart test/app/theme/text_scale_controller_test.dart
git commit -m "feat: persist user text scale preference"
```

---

### Task 3: AppTypography baseline

**Files:**
- Create: `lib/app/theme/app_typography.dart`
- Test: `test/app/theme/app_typography_test.dart`

**Interfaces:**
- Produces: `AppTypography.textTheme({required Brightness brightness, required Color onSurface})` → `TextTheme`

- [ ] **Step 1: Write the failing test**

```dart
// test/app/theme/app_typography_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/app_typography.dart';

void main() {
  test('textTheme defines core Material roles with expected sizes', () {
    final theme = AppTypography.textTheme(
      brightness: Brightness.light,
      onSurface: const Color(0xFF111827),
    );

    expect(theme.titleLarge?.fontSize, 20);
    expect(theme.titleLarge?.fontWeight, FontWeight.w700);
    expect(theme.bodyMedium?.fontSize, 14);
    expect(theme.labelSmall?.fontSize, 11);
    expect(theme.bodyLarge?.fontFamily, isNotNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app/theme/app_typography_test.dart`
Expected: FAIL

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/app/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme textTheme({
    required Brightness brightness,
    required Color onSurface,
  }) {
    final base = GoogleFonts.poppinsTextTheme();
    final muted = onSurface.withValues(alpha: 0.7);

    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/app/theme/app_typography_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/theme/app_typography.dart test/app/theme/app_typography_test.dart
git commit -m "feat: add Poppins typography baseline"
```

---

### Task 4: Wire TextTheme into AppTheme

**Files:**
- Modify: `lib/app/theme/app_theme.dart`
- Modify: `test/app/theme/app_theme_test.dart`

**Interfaces:**
- Consumes: `AppTypography.textTheme`

- [ ] **Step 1: Extend app_theme_test with failing assertions**

Add to `test/app/theme/app_theme_test.dart`:

```dart
test('light theme exposes poppins textTheme roles', () {
  final theme = AppTheme.light;
  expect(theme.textTheme.titleLarge?.fontSize, 20);
  expect(theme.textTheme.bodyMedium?.fontSize, 14);
  expect(theme.primaryTextTheme.titleLarge?.fontSize, 20);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app/theme/app_theme_test.dart --name "poppins textTheme"`
Expected: FAIL — `fontSize` is null or default Material value

- [ ] **Step 3: Wire typography in `_build`**

Inside `AppTheme._build`, before `return ThemeData(`:

```dart
final textTheme = AppTypography.textTheme(
  brightness: brightness,
  onSurface: onSurface,
);
```

Add to `ThemeData(...)`:

```dart
textTheme: textTheme,
primaryTextTheme: textTheme,
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/app/theme/app_theme_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/theme/app_theme.dart test/app/theme/app_theme_test.dart
git commit -m "feat: attach typography baseline to AppTheme"
```

---

### Task 5: App-wide TextScaler builder

**Files:**
- Create: `lib/app/theme/app_text_scale.dart` — pure function for combined scale (testable)
- Modify: `lib/app/app.dart`
- Test: `test/app/theme/app_text_scale_builder_test.dart`

**Interfaces:**
- Produces: `double combinedTextScale({required double appFactor, required double osFactor})`
- Produces: `Widget wrapWithTextScale({required Widget child, required AppTextScale appScale, required MediaQueryData mediaQuery})`

- [ ] **Step 1: Write failing tests**

```dart
// test/app/theme/app_text_scale_builder_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/app_text_scale.dart';
import 'package:ilms/app/theme/text_scale.dart';

void main() {
  test('combinedTextScale multiplies and clamps', () {
    expect(
      combinedTextScale(appFactor: 1.15, osFactor: 1.5),
      1.6,
    );
    expect(
      combinedTextScale(appFactor: 0.85, osFactor: 0.5),
      0.8,
    );
    expect(
      combinedTextScale(appFactor: 1.0, osFactor: 1.2),
      1.2,
    );
  });

  testWidgets('wrapWithTextScale applies TextScaler to descendants', (tester) async {
    late TextScaler captured;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
        child: wrapWithTextScale(
          appScale: AppTextScale.large,
          child: Builder(
            builder: (context) {
              captured = MediaQuery.textScalerOf(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(captured.scale(14), closeTo(14 * 1.15 * 1.2, 0.01));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/app/theme/app_text_scale_builder_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement helper + wire app.dart**

```dart
// lib/app/theme/app_text_scale.dart
import 'package:flutter/material.dart';
import 'package:ilms/app/theme/text_scale.dart';

double combinedTextScale({
  required double appFactor,
  required double osFactor,
}) {
  return (appFactor * osFactor).clamp(0.8, 1.6);
}

Widget wrapWithTextScale({
  required AppTextScale appScale,
  required Widget child,
  MediaQueryData? mediaQuery,
}) {
  final mq = mediaQuery ?? MediaQueryData.fromView(
    WidgetsBinding.instance.platformDispatcher.views.first,
  );
  final osScale = mq.textScaler.scale(1.0);
  final factor = combinedTextScale(
    appFactor: appTextScaleFactor(appScale),
    osFactor: osScale,
  );
  return MediaQuery(
    data: mq.copyWith(textScaler: TextScaler.linear(factor)),
    child: child,
  );
}
```

In `lib/app/app.dart`:

```dart
import 'theme/text_scale_controller.dart';
import 'theme/app_text_scale.dart';

// inside build():
final textScale = ref.watch(textScaleControllerProvider);

// both MaterialApp and MaterialApp.router:
builder: (context, child) => wrapWithTextScale(
  appScale: textScale,
  mediaQuery: MediaQuery.of(context),
  child: child ?? const SizedBox.shrink(),
),
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/app/theme/app_text_scale_builder_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/theme/app_text_scale.dart lib/app/app.dart test/app/theme/app_text_scale_builder_test.dart
git commit -m "feat: apply combined text scaler in MaterialApp builder"
```

---

### Task 6: Profile settings UI

**Files:**
- Modify: `lib/features/profile/presentation/widgets/profile_tab_view.dart`

**Interfaces:**
- Consumes: `textScaleControllerProvider`, `textScaleLabel`, `textScaleOptions`, `AppTextScale`

- [ ] **Step 1: Add ProfileSettingTile for text size**

Below the Theme tile, add:

```dart
ProfileSettingTile(
  icon: Icons.format_size,
  title: 'Text size',
  subtitle: 'Adjust reading comfort',
  trailing: textScaleLabel(ref.watch(textScaleControllerProvider)),
  onTap: () => _showTextScaleBottomSheet(context, ref),
),
```

- [ ] **Step 2: Add bottom sheet method**

Mirror `_showThemeBottomSheet` using `RadioGroup<AppTextScale>`, `textScaleOptions()`, and `TextScaleController.setScale`.

- [ ] **Step 3: Manual smoke test**

Run app → Profile → Text size → pick Large → confirm labels enlarge.

- [ ] **Step 4: Commit**

```bash
git add lib/features/profile/presentation/widgets/profile_tab_view.dart
git commit -m "feat: add text size setting to profile"
```

---

### Task 7: Migrate home widgets to textTheme

**Files:**
- Modify: `lib/features/home/presentation/pages/home_page.dart`
- Modify: `lib/shared/ui/home/home_module_button.dart`

- [ ] **Step 1: Replace inline GoogleFonts / fontSize on home page**

Use `Theme.of(context).textTheme.titleMedium` (or `titleLarge`) instead of `GoogleFonts.poppins(..., fontSize: 18)`.

- [ ] **Step 2: Replace inline fontSize in HomeModuleButton**

Use `textTheme.labelMedium` for the module label.

- [ ] **Step 3: Run affected tests**

Run: `flutter test test/shared/ui/home/home_module_button_test.dart`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/features/home/presentation/pages/home_page.dart lib/shared/ui/home/home_module_button.dart
git commit -m "refactor: use theme text styles on home module grid"
```

---

### Task 8: Final verification

- [ ] **Step 1: Run full theme test suite**

Run: `flutter test test/app/theme/`
Expected: all PASS

- [ ] **Step 2: Run analyzer**

Run: `dart analyze lib/app/theme lib/app/app.dart lib/features/profile/presentation/widgets/profile_tab_view.dart`
Expected: no issues

- [ ] **Step 3: Manual checklist**

- Fresh install → Default text size
- Pick Extra Large → persists after kill/relaunch
- Increase OS text size → app text grows further (multiply), stops at clamp
- Light and dark themes both use Poppins roles

---

## Spec Coverage Self-Review

| Spec requirement | Task |
|------------------|------|
| Baseline TextTheme in AppTheme | 3, 4 |
| AppTextScale presets + persistence | 1, 2 |
| Multiply app × OS with clamp | 5 |
| Profile settings UI | 6 |
| Home widget migration (v1) | 7 |
| Tests | 1–5, 8 |

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-28-text-scale.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks
2. **Inline Execution** — execute tasks in this session with checkpoints

Which approach?
