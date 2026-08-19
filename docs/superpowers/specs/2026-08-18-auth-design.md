# Auth Module Design

**Goal:** Add a simple, loosely coupled `auth` feature with email/password login, fixed demo credentials, and a placeholder post-login home screen.

## Scope

This design covers only the first login flow:

- email + password form
- local validation
- mock authentication using fixed demo credentials
- success navigation to a simple authenticated placeholder screen
- clear separation between UI, state management, domain contracts, and data source

This design does not include:

- registration
- forgot password
- token refresh
- real backend integration
- persistent session restore

## Constraints

- Keep the code simple and readable.
- Follow the existing feature-first structure.
- Keep the module loosely coupled so the mock data source can be replaced by a real API later.
- Use Riverpod for state management.
- Use the current CelcomDigi-aligned app theme.

## Feature Structure

The `auth` feature will be split by responsibility:

- `features/auth/domain/entities/auth_user.dart`
- `features/auth/domain/repositories/auth_repository.dart`
- `features/auth/data/datasources/mock_auth_data_source.dart`
- `features/auth/data/repositories/auth_repository_impl.dart`
- `features/auth/presentation/controllers/auth_controller.dart`
- `features/auth/presentation/pages/login_page.dart`
- `features/auth/presentation/pages/auth_home_page.dart`

This keeps responsibilities clear:

- `domain` defines the business contract and result shape
- `data` knows how login data is checked
- `presentation` owns screen behavior and rendering

## Domain Design

### `AuthUser`

`AuthUser` is a simple entity returned after a successful login. It only contains the minimum data needed by the placeholder authenticated flow:

- `id`
- `name`
- `email`

The entity should remain framework-agnostic and free from UI concerns.

### `AuthRepository`

`AuthRepository` defines the login contract:

- accepts `email` and `password`
- returns an `AuthUser` on success
- throws a clear auth-specific exception on failure

The UI and Riverpod controller will depend on this interface, not on any data source implementation.

## Data Design

### `MockAuthDataSource`

`MockAuthDataSource` is the temporary backend substitute. It will:

- contain a fixed demo account
- simulate a short delay so loading states can be seen
- return mock user data when credentials match
- throw an auth failure when credentials do not match

Planned demo credentials:

- email: `demo@ilms.com`
- password: `password123`

### `AuthRepositoryImpl`

`AuthRepositoryImpl` bridges the domain interface and mock data source:

- depends on `MockAuthDataSource`
- transforms raw mock response into `AuthUser`
- exposes the `AuthRepository` contract to the presentation layer

When the backend is ready, the mock data source can be replaced without changing the login screen or controller contract.

## Presentation Design

### `AuthController`

`AuthController` will use Riverpod and keep login state simple:

- idle
- loading
- success
- error

Responsibilities:

- receive login input from UI
- call `AuthRepository.login`
- update state for loading, success, and failure
- expose the authenticated user after successful login

This keeps the widget tree thin and avoids embedding auth logic directly in the screen.

### `LoginPage`

`LoginPage` will be the first auth screen. It includes:

- email text field
- password text field
- login button
- inline validation
- error message area
- optional hint text showing the demo credentials

Validation rules:

- email cannot be empty
- email must look like a valid email
- password cannot be empty

The page listens to controller state and:

- disables repeated submission while loading
- shows progress while login is in flight
- navigates to the authenticated placeholder screen on success
- shows a readable error when credentials are wrong

### `AuthHomePage`

`AuthHomePage` is a simple placeholder destination after successful login. It confirms that login completed and can show:

- a welcome message
- logged-in email
- environment name if helpful

This screen exists only to complete the first login flow cleanly.

## Dependency Wiring

Riverpod providers will wire the feature together:

- provider for `MockAuthDataSource`
- provider for `AuthRepository`
- provider/notifier for `AuthController`

The presentation layer will read only provider-backed abstractions, not construct dependencies directly in widgets.

## Navigation

For this first version, navigation stays simple:

- app opens on `LoginPage`
- successful login pushes or replaces with `AuthHomePage`

There is no guarded routing layer yet. That can be added later when session persistence and logout are introduced.

## Error Handling

The feature will separate validation errors from auth failures:

- form validation handles empty or malformed input before submit
- repository/data source handles invalid credentials

The user-facing error for invalid credentials should be explicit and simple, such as:

`Invalid email or password.`

## Testing Plan

Implementation must include focused tests for:

### Domain/Data

- repository returns `AuthUser` for valid demo credentials
- repository throws auth failure for invalid credentials

### Presentation State

- controller moves from idle to loading to success on valid login
- controller moves from idle to loading to error on invalid login

### UI

- login screen validates empty email
- login screen validates invalid email format
- login screen validates empty password
- login screen shows loading state during submit
- login screen shows error message on invalid credentials
- login screen navigates to placeholder home on success

## Implementation Notes

- Keep auth types small and readable.
- Avoid premature abstractions such as generic result wrappers or complex sealed hierarchies unless tests prove they are necessary.
- Prefer a straightforward Riverpod notifier setup over a more advanced architecture style.
- The mock data source should be the only place that knows the fixed credentials.

## Future Replacement Path

When the backend is ready:

1. Replace `MockAuthDataSource` with an API-backed data source.
2. Keep `AuthRepository` unchanged if possible.
3. Reuse the same controller and screen contracts.
4. Add token storage using `flutter_secure_storage` when real auth is introduced.

This preserves loose coupling and minimizes UI churn.
