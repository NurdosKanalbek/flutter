# Practice 11 · A Real Server

Mobile Development Practice 11: Real server integration with `jsonplaceholder.typicode.com`, strict HTTP layer isolation, defended model deserialization, sealed domain exceptions, and network resilience.

> **One sentence carries the whole lab**: The repository is the only class that knows `http` exists. Screens ask it for models and get models — or one of your domain exceptions. Never a `Response`, never a status code, never a `Map`.

---

## Architecture Overview

Feature-first structure:
```
Practice 11/
├── lib/
│   ├── core/
│   │   └── api/
│   │       ├── api_client.dart       # HTTP client wrapper, 10s timeout, error mapping, logger
│   │       └── api_exception.dart    # Sealed ApiException hierarchy (NoConnection, Server, NotFound, Unauthorized, BadResponse)
│   ├── features/
│   │   └── users/
│   │       ├── error_views.dart      # Offline, ServerError, ClientError, GenericError widgets
│   │       ├── new_user_screen.dart  # Validated user creation form with disabled-in-flight submit
│   │       ├── user.dart             # Geo, Address, User models with defended casts & round-trip serialization
│   │       ├── user_detail_screen.dart # Full user profile with contact, address, and company records
│   │       ├── user_repository.dart  # Concrete repository querying JSONPlaceholder endpoints
│   │       ├── users_model.dart      # ChangeNotifier managing items, loading, and error states
│   │       └── users_screen.dart     # Exhaustive pattern matching on sealed ApiException, pull-to-refresh
│   └── main.dart                     # Composition root with ChangeNotifierProvider & preflight verifications
├── test/
│   ├── users_test.dart               # Unit tests covering deserialization defense, round-trip, and exceptions
│   └── widget_test.dart              # Widget test verifying app assembly under Provider
├── NOTES.md                          # Wire inspection tables, status checks, and two no-network timings
├── screenshot_timeout.png            # DevTools Network capture showing dead Wi-Fi request timing out at ~10 s
└── screenshot_200.png                # DevTools Network capture showing 200 OK with response payload
```

---

## Requirements Checklist

- [x] **Level 1 (Postman first)**: Inspected wire JSON for `/users`, `/users/1`, `/users/999`, `POST /users`, and `/users?id=3`. Detailed 4-line tables documented in [NOTES.md](NOTES.md).
- [x] **Level 2 (A model that survives bad JSON)**:
  - `Geo`, `Address`, and `User` with `const` constructors, `final` fields, no `late`, no `!`.
  - `double.parse(json['lat'] as String)` defensively parses coordinate strings.
  - `company` built as a Dart Record: `({String name, String catchPhrase})`.
  - `website` is optional (`String?`) via `as String?`.
  - `phoneDigits` getter strips non-digit characters except `+`.
  - `User.fromJson(user.toJson()) == user` round-trip equality holds.
- [x] **Level 3 (The repository — isolated HTTP)**:
  - `ApiClient` wraps `http.Client`, enforces a 10-second `.timeout(...)`, maps `SocketException` & `TimeoutException` to `NoConnectionException`.
  - `_check(...)` handles 401 (`UnauthorizedException`), 404 (`NotFoundException`), and 5xx (`ServerException`) before decoding.
  - `_decode(...)` turns `FormatException` into `BadResponseException`.
  - `UserRepository` uses `Uri.https(...)` for all URLs; catches deserialization `TypeError`s as `BadResponseException`.
  - HTTP grep check: `grep -rn "package:http" lib/` outputs **only** `api_client.dart` and `user_repository.dart`.
- [x] **Level 4 (The chain)**:
  - `UsersModel` (`ChangeNotifier`) holds `items`, `loading`, and `error`, catching only `ApiException`.
  - `UsersScreen` uses exhaustive pattern matching switch on sealed `ApiException` with zero `default` cases.
  - Pull-to-refresh (`RefreshIndicator`) reloads data via `m.load`.
- [x] **Level 5 (Two kinds of no network & POST)**:
  - Airplane mode timing (< 1 s) vs. dead Wi-Fi black hole timing (~10 s) documented in [NOTES.md](NOTES.md).
  - DevTools Network screenshots: [screenshot_timeout.png](screenshot_timeout.png) and [screenshot_200.png](screenshot_200.png).
  - "New user" form with inputs, validation, and in-flight submit button disabling (`_saving`).
  - Analysis is completely clean (`flutter analyze` -> `No issues found!`), `unawaited_futures: true` enabled, `dart format .` applied.

---

## Running the App & Tests

```powershell
# Get dependencies
flutter pub get

# Run tests
flutter test

# Static analysis
flutter analyze

# Format code
dart format .

# Launch application
flutter run
```
