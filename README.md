# ilms

Flutter mobile app for ILMS field operations — premise census, billboard census,
and investigation (siasatan) workflows. The codebase follows clean architecture
(domain / data / presentation) with Riverpod for state and GoRouter for navigation.

## Project layout

```
lib/
├── app/                  # App shell, environment, routing
├── core/                 # Network, local storage, shared services
├── features/             # Feature modules (see below)
└── shared/               # Cross-feature UI, lookups, formatters
```

### Feature modules

| Module | Description | Docs |
|--------|-------------|------|
| `premise` | Premise census — search, create/edit, drafts, duplicate search | [`lib/features/premise/README.md`](lib/features/premise/README.md) |
| `billboard` | Billboard census — search, create/edit, drafts | — |
| `investigation` | Investigation cases — search, view/edit existing records | [`lib/features/investigation/README.md`](lib/features/investigation/README.md) |
| `auth` | Login, session | — |

Each feature follows the same layer split:

```
lib/features/<feature>/
├── domain/               # Entities, repository interfaces, exceptions
├── data/                 # API/local datasources, mappers, repository impl
└── presentation/
    ├── pages/
    ├── sections/
    ├── widgets/
    ├── controllers/      # Presentation logic (see below)
    └── providers/        # Riverpod wiring (see below)
```

## Controllers vs providers

Within `presentation/`, **controllers** and **providers** have distinct roles.

### `controllers/` — presentation logic

Stateful screen orchestration: UI state, user actions, pagination, filter
cascade, calling repositories, mapping errors for display.

Typical contents:

- `*State` / filter selection classes (when co-located with the controller)
- `*Controller extends Notifier` / `FamilyNotifier` with action methods
- For list/search screens, the `NotifierProvider` declaration may live at the
  bottom of the same file (e.g. `premise_list_controller.dart`)

Examples:

- `premise_form_controller.dart` — form load, draft save, submit
- `premise_duplicate_controller.dart` — duplicate search filter + pagination
- `billboard_form_controller.dart`
- `investigation_form_controller.dart`

### `providers/` — dependency wiring

Riverpod declarations only: construct datasources and repositories, expose
`FutureProvider` / `StreamProvider` for simple read-only data, and register
controller providers.

Typical contents:

```dart
final premiseRepositoryProvider = Provider<PremiseRepository>((ref) { ... });

final premiseFormControllerProvider =
    NotifierProvider.family<PremiseFormController, PremiseFormState, PremiseFormSession>(
      PremiseFormController.new,
    );
```

Form provider files also export their controller so existing imports keep working:

```dart
export 'package:ilms/features/premise/presentation/controllers/premise_form_controller.dart';
```

Widgets generally import `*_form_providers.dart` (or list controller files) and
use `ref.watch(xxxControllerProvider)` / `.notifier.action()`.

### Where business rules live

| Layer | Responsibility |
|-------|----------------|
| `domain/` + `data/` | Core business rules, API mapping, validation, persistence |
| `controllers/` | Presentation orchestration tied to a screen or flow |
| `providers/` | DI graph and provider registration — no business logic |

## Getting started

Prerequisites: Flutter SDK (see `pubspec.yaml` for Dart SDK constraint).

```bash
flutter pub get
flutter run
```

Run tests:

```bash
flutter test
```

Environment switching (dev/stg/prod) is available in-app via the environment
switcher — see `lib/app/environment/`.
