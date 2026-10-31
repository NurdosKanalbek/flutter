# Mobile Development Practice 9: Put It High, Subscribe Low

## Level 1: Lift It Up

### Constructor Count
To pass `total` from the owner (`Shell`) all the way down to `CartBadge`:
- **Files touched**: 3 files (`lib/main.dart`, `lib/books_screen.dart`, `lib/cart_badge.dart`)
- **Constructors touched**: 2 constructors
  1. `BooksScreen({super.key, required this.cart, required this.onAdd, required this.total})` in `lib/books_screen.dart`
  2. `CartBadge({super.key, required this.count, required this.total})` in `lib/cart_badge.dart`
  Plus call sites in `lib/main.dart` (`Shell` passes `total` to `BooksScreen`) and `lib/books_screen.dart` (`BooksScreen` forwards `total` to `CartBadge`).

### Rebuild Count (Level 1)
When tapping "Add" once on a book in `BooksScreen`:
- Console log output:
  - `BooksScreen build` (1 line)
  - `row Widgets All the Way Down` (1 line)
  - `row Null Safety for Humans` (1 line)
  - `row Constraints Go Down, Sizes Go Up` (1 line)
  - `row The Navigator Is a Stack` (1 line)
  - `row Forms That Validate Themselves` (1 line)
  - `row Put It High, Subscribe Low` (1 line)
- **Total lines printed**: 7 lines
One tap calls `setState` in `_ShellState` above `MaterialApp`, which marks the entire route dirty and rebuilds the screen and all 6 rows.

---

## Level 2: A Model with No Widgets

- `Cart` extends `ChangeNotifier` and imports only `package:flutter/foundation.dart`.
- The rule "no duplicates" lives in `Cart.add` and nowhere else: returns `false` and does nothing if the book is already present; returns `true` and calls `notifyListeners()` on successful insertion.
- `items` returns an unmodifiable list via `List.unmodifiable(_qty.keys.toList())`. Calling `cart.items.add(book)` throws `Unsupported operation: Cannot add to an unmodifiable list`.
- The model has no references to `BuildContext`, `Widget`, `SnackBar`, or `Navigator`.

---

## Level 3: The Same App with Provider

### The Loud Error (watch in callback)
Changing the Add button's handler to `context.watch<Cart>().add(b)` causes a runtime crash when tapped:
```
Tried to listen to a value exposed with provider, from outside of the widget tree

This is likely caused by an event handler (like a button's onPressed) that called
Provider.of(context) without `listen: false`.

To fix, write:
Provider.of<Cart>(context, listen: false)
or:
context.read<Cart>()
```
**Reason:** `context.watch()` registers the calling context to be rebuilt when the provider updates. Callbacks like `onPressed` execute outside of the build phase and cannot schedule builds this way.

### The Silent Error (read in build)
Changing `CartBadge.build` to use `context.read<Cart>().count`:
- **Error message:** No error or exception is thrown. The code compiles and runs cleanly.
- **Behavior:** The badge is frozen at `0` forever. Because `context.read()` fetches the object once without registering an `InheritedWidget` subscription, the widget is never marked dirty when `notifyListeners()` is called.

---

## Level 4: Scope — select and Consumer

### Rebuild Counts for CartBadge
When pressing `+` on a cart row 3 times (incrementing quantity of an existing book):

1. **With `context.watch<Cart>().count`:**
   - **Rebuilds:** 3 times (`badge build` printed 3 times in console).
   - **Reason:** `watch` subscribes to any `notifyListeners()` call on `Cart`. Even though distinct count remained unchanged, the entire badge was rebuilt each time.

2. **With `context.select<Cart, int>((c) => c.count)`:**
   - **Rebuilds:** 0 times (`badge build` printed 0 times during the 3 increment taps).
   - **Reason:** `select` compares the projected value (`c.count`). Since `c.count` remained identical across increments, `provider` skipped rebuilding the badge entirely.
   - When a book is removed, `c.count` changes and `CartBadge` rebuilds exactly 1 time.

---

## Level 5: Where Does It Live?

Four values and their state management tier:

1. **The cart**: **provided** — Shared across distant, independent routes (`BooksScreen`, `CartScreen`, and `CartBadge`) and needs to persist across navigation without manual parameter passing.
2. **The search text in a search field that filters the books list**: **ephemeral** — Local UI state confined strictly to `BooksScreen`; no other route, badge, or business model needs access to the temporary query.
3. **Whether the Cart screen's total is expanded or collapsed**: **ephemeral** — Local presentation toggle inside `CartScreen`; governs only the visual expansion of order details without impacting domain data.
4. **The theme mode if there were a dark-mode switch**: **provided** (or **lifted**) — Sits above `MaterialApp` because changing the theme affects widget styling across all routes and screens globally.
