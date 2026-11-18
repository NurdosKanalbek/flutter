# Practice 11 Notes: A Real Server

## Level 1 · Postman First & Wire Inspection

### Wire Inspection Summary
- **Endpoint**: `https://jsonplaceholder.typicode.com/users`
- **Total Users**: 10 users returned in a top-level JSON array `[...]`.
- **Top-level User Object Keys**: `id`, `name`, `username`, `email`, `address`, `phone`, `website`, `company`.
- **Nested Objects**:
  - `address`: nested object containing `street`, `suite`, `city`, `zipcode`, and `geo`.
  - `company`: nested object containing `name`, `catchPhrase`, and `bs`.
- **Nested Twice**:
  - `address.geo`: nested object containing `lat` and `lng`.
- **Nullable / Optional Fields**:
  - `website` is treated as optional (`String?`) via `json['website'] as String?`.
  - All other fields are treated as non-nullable with defended casts. Note that `lat` and `lng` inside `geo` are sent as JSON strings (`"-37.3159"`, `"81.1496"`) and must be converted to `double` using `double.parse`.

### Special Responses & Query Filters
- **`GET /users/999`**:
  - Status: `404 Not Found`
  - Content-Type: `application/json; charset=utf-8`
  - Body: `{}` (an empty JSON object). If status is not checked before parsing, decoding succeeds but `User.fromJson` crashes on missing `id`. Therefore, status checking in `_check` must always precede body decoding.
- **`POST /users`** with JSON body and `Content-Type: application/json`:
  - Status: `201 Created`
  - Body: echoes the sent fields and assigns a new server-generated `"id": 11`.
- **`GET /users?id=3`**:
  - Query parameters filter the collection, but the response shape remains a JSON list containing one element (`[ { "id": 3, ... } ]`), rather than a single top-level user object.

---

### Type Tables

#### 1. Top-Level `User` Fields
| Field | JSON Type | Dart Type | Nullable? | Notes |
|---|---|---|---|---|
| `id` | number (integer) | `int` | No | Cast with `as int` |
| `name` | string | `String` | No | Cast with `as String` |
| `username` | string | `String` | No | Cast with `as String` |
| `email` | string | `String` | No | Cast with `as String` |
| `address` | object | `Address` | No | Parsed via `Address.fromJson` |
| `phone` | string | `String` | No | Raw string kept, normalized via `phoneDigits` getter |
| `website` | string | `String?` | Yes | Cast with `as String?` (only optional field) |
| `company` | object | `({String name, String catchPhrase})` | No | Dart Record built in `User.fromJson` |

#### 2. Nested `Address` Fields (`address`)
| Field | JSON Type | Dart Type | Nullable? | Notes |
|---|---|---|---|---|
| `street` | string | `String` | No | Cast with `as String` |
| `suite` | string | `String` | No | Cast with `as String` |
| `city` | string | `String` | No | Cast with `as String` |
| `zipcode` | string | `String` | No | Cast with `as String` |
| `geo` | object | `Geo` | No | Parsed via `Geo.fromJson` |

#### 3. Nested Twice `Geo` Fields (`address.geo`)
| Field | JSON Type | Dart Type | Nullable? | Notes |
|---|---|---|---|---|
| `lat` | string | `double` | No | Parsed via `double.parse(json['lat'] as String)` |
| `lng` | string | `double` | No | Parsed via `double.parse(json['lng'] as String)` |

#### 4. Nested `Company` Fields (`company`)
| Field | JSON Type | Dart Type | Nullable? | Notes |
|---|---|---|---|---|
| `name` | string | `String` | No | Cast with `as String` |
| `catchPhrase` | string | `String` | No | Cast with `as String` |
| `bs` | string | `String` | No | Present in wire JSON, omitted from Dart record |

---

## Level 2 · Model Defense & Deliberate Failures

1. **Cast Defense**:
   - `json['id'] as int` asserts that `id` is an integer.
   - `json['lat'] as String` followed by `double.parse(...)` converts the server string to double.
   - Intentionally breaking the cast (`json['lat'] as double`) immediately throws:
     `type 'String' is not a subtype of type 'double' in type cast`
   - Intentionally breaking `id` in JSON to a string (`"1"`) throws:
     `type 'String' is not a subtype of type 'int' in type cast`
   - Both are defense failures that identify the exact offending field. The repository catches `TypeError` and wraps it into `BadResponseException`.

2. **Round-trip Equivalence**:
   - `User.fromJson(user.toJson()) == user` holds true because `toJson()` emits the exact wire format and `==` / `hashCode` are implemented on `id`.

---

## Level 3 · Repository Architecture & HTTP Isolation

- The repository `UserRepository` and `ApiClient` are the only classes that import `package:http`.
- `grep -rn "package:http" lib/` outputs exactly two files:
  1. `lib/core/api/api_client.dart`
  2. `lib/features/users/user_repository.dart`
- No screens, models, or widgets have access to HTTP classes or status codes.
- `_check(Response)` runs before decoding:
  - 401 -> `UnauthorizedException`
  - 404 -> `NotFoundException`
  - >= 500 -> `ServerException(status)`
- When 404 check was temporarily removed for `getById(999)`, `_decode` returned `{}` and `User.fromJson` threw on `id`, producing a confusing `BadResponseException` instead of `NotFoundException`. Checking status before parsing guarantees accurate domain exceptions.

---

## Level 4 · Sealed ApiException & UI State

- `ApiException` is a sealed class with exhaustive pattern matching in `UsersScreen`.
- Removing any branch (such as `BadResponseException`) causes compile-time error:
  `The type 'ApiException?' is not exhaustively matched by the switch cases.`
- Changing the host to invalid `jsonplaceholder.typicode.co` produces `SocketException` -> `NoConnectionException` -> `OfflineView` within < 1 second. Tapping "Retry" restores the list without app restart.

---

## Level 5 · Two Kinds of "No Network"

| Scenario | Cause | Observed Timing | Resulting State |
|---|---|---|---|
| **Airplane Mode** | OS detects no route immediately (`SocketException`) | **~0.3 seconds** (< 1 s) | `NoConnectionException` -> `OfflineView` |
| **Dead Wi-Fi / Black Hole** | Packets leave and never return until timeout (`TimeoutException`) | **10.0 seconds** (~10 000 ms) | `NoConnectionException` -> `OfflineView` |

### Proof & Network Observations:
- In DevTools Network tab during the dead Wi-Fi test:
  - Request: `GET https://jsonplaceholder.typicode.com/users`
  - Duration: `~10 000 ms`
  - Status: empty / failed
  - Committed screenshot: `screenshot_timeout.png`
- Under normal connection:
  - Request: `GET https://jsonplaceholder.typicode.com/users`
  - Status: `200 OK`
  - Response body contains the 10 user items
  - Committed screenshot: `screenshot_200.png`
- New User Form:
  - Validates name, username, and email.
  - While request is in flight, the Save button is disabled (`_saving = true`), preventing duplicate submits.
