# Auth Module Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a simple, loosely coupled `auth` feature with email/password login, fixed demo credentials, Riverpod-managed state, and a placeholder authenticated screen.

**Architecture:** The feature follows the existing feature-first structure with `domain`, `data`, and `presentation` layers. The UI depends on Riverpod state and the `AuthRepository` interface, while the mock login behavior lives behind a data source so it can be replaced later without changing the screen or controller contract.

**Tech Stack:** Flutter, flutter_riverpod, dio (existing), flutter_test

**Spec:** `docs/superpowers/specs/2026-08-18-auth-design.md`

## Global Constraints

- Keep the code simple and readable.
- Follow the existing feature-first structure.
- Keep the module loosely coupled so the mock data source can be replaced by a real API later.
- Use Riverpod for state management.
- Use the current CelcomDigi-aligned app theme.
- email: `demo@ilms.com`
- password: `password123`
- The mock data source should be the only place that knows the fixed credentials.
- Avoid premature abstractions such as generic result wrappers or complex sealed hierarchies unless tests prove they are necessary.
- Prefer a straightforward Riverpod notifier setup over a more advanced architecture style.

---

## File Structure

### New production files

- `lib/features/auth/domain/entities/auth_user.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/domain/exceptions/auth_exception.dart`
- `lib/features/auth/data/datasources/mock_auth_data_source.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/presentation/controllers/auth_state.dart`
- `lib/features/auth/presentation/controllers/auth_controller.dart`
- `lib/features/auth/presentation/providers/auth_providers.dart`
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/pages/auth_home_page.dart`

### Modified production files

- `lib/app/app.dart`
- `lib/features/home/presentation/home_page.dart`

### New test files

- `test/features/auth/data/repositories/auth_repository_impl_test.dart`
- `test/features/auth/presentation/controllers/auth_controller_test.dart`
- `test/features/auth/presentation/pages/login_page_test.dart`

### Modified test files

- `test/widget_test.dart`

## Task 1: Domain and Mock Repository Path

**Files:**
- Create: `lib/features/auth/domain/entities/auth_user.dart`
- Create: `lib/features/auth/domain/repositories/auth_repository.dart`
- Create: `lib/features/auth/domain/exceptions/auth_exception.dart`
- Create: `lib/features/auth/data/datasources/mock_auth_data_source.dart`
- Create: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Test: `test/features/auth/data/repositories/auth_repository_impl_test.dart`

**Interfaces:**
- Consumes: no new app-internal interfaces
- Produces:
  - `class AuthUser { final String id; final String name; final String email; }`
  - `abstract class AuthRepository { Future<AuthUser> login({required String email, required String password}); }`
  - `class AuthException implements Exception { final String message; }`
  - `class MockAuthDataSource { Future<Map<String, String>> login({required String email, required String password}); }`
  - `class AuthRepositoryImpl implements AuthRepository { AuthRepositoryImpl(this._dataSource); }`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/data/datasources/mock_auth_data_source.dart';
import 'package:ilms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';

void main() {
  test('login returns AuthUser for valid demo credentials', () async {
    final repository = AuthRepositoryImpl(MockAuthDataSource());

    final user = await repository.login(
      email: 'demo@ilms.com',
      password: 'password123',
    );

    expect(user.email, 'demo@ilms.com');
    expect(user.name, isNotEmpty);
  });

  test('login throws AuthException for invalid credentials', () async {
    final repository = AuthRepositoryImpl(MockAuthDataSource());

    expect(
      () => repository.login(
        email: 'wrong@ilms.com',
        password: 'wrong-password',
      ),
      throwsA(isA<AuthException>()),
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/data/repositories/auth_repository_impl_test.dart`

Expected: FAIL because the auth entity, exception, data source, and repository files do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;
}

abstract class AuthRepository {
  Future<AuthUser> login({
    required String email,
    required String password,
  });
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

class MockAuthDataSource {
  Future<Map<String, String>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (email == 'demo@ilms.com' && password == 'password123') {
      return {
        'id': '1',
        'name': 'Demo User',
        'email': 'demo@ilms.com',
      };
    }

    throw const AuthException('Invalid email or password.');
  }
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final MockAuthDataSource _dataSource;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final rawUser = await _dataSource.login(
      email: email,
      password: password,
    );

    return AuthUser(
      id: rawUser['id'] ?? '',
      name: rawUser['name'] ?? '',
      email: rawUser['email'] ?? '',
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/data/repositories/auth_repository_impl_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add \
  lib/features/auth/domain/entities/auth_user.dart \
  lib/features/auth/domain/repositories/auth_repository.dart \
  lib/features/auth/domain/exceptions/auth_exception.dart \
  lib/features/auth/data/datasources/mock_auth_data_source.dart \
  lib/features/auth/data/repositories/auth_repository_impl.dart \
  test/features/auth/data/repositories/auth_repository_impl_test.dart
git commit -m "feat: add mock auth domain and repository"
```

## Task 2: Riverpod Auth Controller and Providers

**Files:**
- Create: `lib/features/auth/presentation/controllers/auth_state.dart`
- Create: `lib/features/auth/presentation/controllers/auth_controller.dart`
- Create: `lib/features/auth/presentation/providers/auth_providers.dart`
- Test: `test/features/auth/presentation/controllers/auth_controller_test.dart`

**Interfaces:**
- Consumes:
  - `AuthRepository.login({required String email, required String password})`
  - `AuthUser`
  - `AuthException`
- Produces:
  - `class AuthState { bool isLoading; String? errorMessage; AuthUser? user; }`
  - `class AuthController extends StateNotifier<AuthState> { Future<void> login({required String email, required String password}); }`
  - `final authRepositoryProvider`
  - `final authControllerProvider`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/domain/exceptions/auth_exception.dart';
import 'package:ilms/features/auth/domain/repositories/auth_repository.dart';
import 'package:ilms/features/auth/presentation/controllers/auth_controller.dart';

class FakeSuccessRepository implements AuthRepository {
  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    return const AuthUser(
      id: '1',
      name: 'Demo User',
      email: 'demo@ilms.com',
    );
  }
}

class FakeFailureRepository implements AuthRepository {
  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    throw const AuthException('Invalid email or password.');
  }
}

void main() {
  test('login moves state to success when credentials are valid', () async {
    final controller = AuthController(FakeSuccessRepository());

    await controller.login(
      email: 'demo@ilms.com',
      password: 'password123',
    );

    expect(controller.state.user?.email, 'demo@ilms.com');
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, isNull);
  });

  test('login moves state to error when credentials are invalid', () async {
    final controller = AuthController(FakeFailureRepository());

    await controller.login(
      email: 'wrong@ilms.com',
      password: 'wrong-password',
    );

    expect(controller.state.user, isNull);
    expect(controller.state.isLoading, false);
    expect(controller.state.errorMessage, 'Invalid email or password.');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/controllers/auth_controller_test.dart`

Expected: FAIL because the auth state, controller, and provider files do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  final bool isLoading;
  final String? errorMessage;
  final AuthUser? user;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    AuthUser? user,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, user: null);

    try {
      final user = await _repository.login(
        email: email,
        password: password,
      );
      state = AuthState(user: user);
    } on AuthException catch (error) {
      state = AuthState(errorMessage: error.message);
    }
  }
}

final mockAuthDataSourceProvider = Provider((ref) => MockAuthDataSource());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(mockAuthDataSourceProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
      return AuthController(ref.read(authRepositoryProvider));
    });
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/presentation/controllers/auth_controller_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add \
  lib/features/auth/presentation/controllers/auth_state.dart \
  lib/features/auth/presentation/controllers/auth_controller.dart \
  lib/features/auth/presentation/providers/auth_providers.dart \
  test/features/auth/presentation/controllers/auth_controller_test.dart
git commit -m "feat: add auth controller and providers"
```

## Task 3: Login Page and Authenticated Placeholder Screen

**Files:**
- Create: `lib/features/auth/presentation/pages/login_page.dart`
- Create: `lib/features/auth/presentation/pages/auth_home_page.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/features/home/presentation/home_page.dart`
- Test: `test/features/auth/presentation/pages/login_page_test.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes:
  - `authControllerProvider`
  - `AuthState`
  - `AuthUser`
- Produces:
  - `class LoginPage extends ConsumerStatefulWidget`
  - `class AuthHomePage extends StatelessWidget`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/presentation/pages/login_page.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('shows validation errors when fields are empty', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginPage()),
      ),
    );

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('shows auth error for invalid credentials', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'wrong@ilms.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Invalid email or password.'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/pages/login_page_test.dart`

Expected: FAIL because the login and placeholder page files do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AuthHomePage(user: next.user!),
          ),
        );
      }
    });

    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required.';
                  }
                  final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailPattern.hasMatch(value.trim())) {
                    return 'Enter a valid email.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (state.errorMessage != null) ...[
                Text(state.errorMessage!),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          await ref
                              .read(authControllerProvider.notifier)
                              .login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                        },
                  child: state.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Demo: demo@ilms.com / password123'),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthHomePage extends StatelessWidget {
  const AuthHomePage({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.name}'),
            const SizedBox(height: 8),
            Text(user.email),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/presentation/pages/login_page_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add \
  lib/features/auth/presentation/pages/login_page.dart \
  lib/features/auth/presentation/pages/auth_home_page.dart \
  test/features/auth/presentation/pages/login_page_test.dart
git commit -m "feat: add login screen and auth placeholder home"
```

## Task 4: App Entry and Auth-First Flow

**Files:**
- Modify: `lib/app/app.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes:
  - `LoginPage`
  - `ProviderScope` already present in `App`
- Produces:
  - `MaterialApp(home: LoginPage())`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/app.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';

void main() {
  tearDown(AppConfig.reset);

  testWidgets('app opens on the login screen', (tester) async {
    await AppConfig.init(
      flavor: AppFlavor.dev,
      loader: (_) async => {'APP_ENV': 'dev'},
    );

    await tester.pumpWidget(const App());

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Demo: demo@ilms.com / password123'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget_test.dart`

Expected: FAIL because the app still opens on the current home screen.

- [ ] **Step 3: Write minimal implementation**

```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'ILMS',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const LoginPage(),
      ),
    );
  }
}
```

Also update `lib/features/home/presentation/home_page.dart` only if it is still referenced elsewhere or needed as a shared placeholder. If the login flow now uses `AuthHomePage`, avoid leaving dead imports or unreachable code in `App`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/app/app.dart test/widget_test.dart
git commit -m "feat: make login the app entry flow"
```

## Task 5: Full Verification

**Files:**
- Modify: none
- Test:
  - `test/features/auth/data/repositories/auth_repository_impl_test.dart`
  - `test/features/auth/presentation/controllers/auth_controller_test.dart`
  - `test/features/auth/presentation/pages/login_page_test.dart`
  - `test/widget_test.dart`
  - existing `test/core/config/app_config_test.dart`
  - existing `test/core/config/app_flavor_test.dart`
  - existing `test/core/network/dio_factory_test.dart`
  - existing `test/app/theme/app_theme_test.dart`

**Interfaces:**
- Consumes: all auth feature interfaces created in Tasks 1-4
- Produces: verified auth-first app flow with mock login

- [ ] **Step 1: Run the auth-focused test suite**

Run:

```bash
flutter test \
  test/features/auth/data/repositories/auth_repository_impl_test.dart \
  test/features/auth/presentation/controllers/auth_controller_test.dart \
  test/features/auth/presentation/pages/login_page_test.dart \
  test/widget_test.dart
```

Expected: PASS

- [ ] **Step 2: Run the broader regression suite**

Run:

```bash
flutter test
```

Expected: PASS

- [ ] **Step 3: Run static analysis**

Run:

```bash
flutter analyze lib test
```

Expected: PASS with no issues found

- [ ] **Step 4: Commit**

```bash
git add lib test
git commit -m "feat: add mock auth login flow"
```

## Self-Review

### 1. Spec coverage

- email + password form: covered in Task 3
- local validation: covered in Task 3
- fixed demo credentials: covered in Task 1
- success navigation to placeholder screen: covered in Tasks 3 and 4
- clear separation between UI, state, domain, and data source: covered in Tasks 1-3
- Riverpod state management: covered in Task 2
- simple code and loose coupling: reinforced in Tasks 1-3

No spec gaps found.

### 2. Placeholder scan

- No `TODO`, `TBD`, or deferred implementation markers
- Each task includes exact files, test commands, and minimal code targets
- Each validation and error case is described concretely

### 3. Type consistency

- `AuthRepository.login({required String email, required String password})` is used consistently in the controller and tests
- `AuthUser` fields are consistently `id`, `name`, and `email`
- `AuthException.message` is the error surface consumed by the controller and UI
- `AuthController` consistently exposes `AuthState`

No naming or type mismatches found.
