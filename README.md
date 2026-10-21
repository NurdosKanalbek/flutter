# Practice 8 — A Little of Everything

A Flutter reading list recapping Dart collections, state, constraints, typed
navigation results, and form validation.

## Run

```sh
flutter pub get
flutter run
```

Created with Flutter 3.47.6 and Dart 3.13.5. Android, web and Windows targets are
included. On this machine, the existing emulator is `Practice7_API30`:

```sh
flutter emulators --launch Practice7_API30
flutter run
```

## Six application files

- `lib/main.dart`: the theme, app entry point and required startup output.
- `lib/models/book.dart`: Flutter-independent Book, fromMap, formatting, seed and
  collection helpers.
- `lib/library_screen.dart`: owned list, enum filter, statistics and typed routes.
- `lib/widgets/book_tile.dart`: themed card, constrained title, avatar, unread dot
  and checkbox.
- `lib/detail_screen.dart`: all book fields and toggle/delete results; deletion
  uses a separate confirmation dialog.
- `lib/add_book_screen.dart`: four validated fields, disposed controllers,
  numeric keyboards, scrolling and a nullable publication year.

The seed is a getter returning fresh Book objects. This lets the required
`[...seed]` initializer isolate the mutable read flags as well as list membership.

Changes are held in memory, as required by the exercise. A fresh app starts with
the original five books.

## Startup output

```text
1220 pages, 4 unread
X — Y, 10 pp.
```

## Verification

```sh
dart format .
flutter analyze
flutter test
```

Tests cover the plain Dart helpers, seed isolation, filtering and totals,
portrait/landscape layout, typed navigation, deletion confirmation and
cancellation, validation boundaries, an unknown year, keyboard focus and insets.

## Submission screenshots

- `screenshot_list.png`: Unread selected and the long title on two lines.
- `screenshot_form.png`: empty form after Save, showing three inline errors and
  no year error.

Both screenshots were captured from the native Android app and are committed:
[Unread list](screenshot_list.png) and [form errors](screenshot_form.png).

## Completed checks

- `dart format .` completed for all eight Dart source/test files.
- `flutter analyze` reported `No issues found!`.
- All 18 model and widget tests passed.
- `flutter build apk --debug --target-platform android-x64` succeeded.
- `flutter run` launched the APK on the Android 11 AOSP emulator.
- The native startup log printed both required lines exactly.
- Unread selected four books; the long title displayed two lines and an ellipsis.
- Portrait and landscape preserved the filter and header statistics, with no
  Flutter overflow or unhandled exception in the native log.
- Saving an empty form showed three errors and accepted the empty year.
- Back from the form returned to the unchanged filtered list.

The filter chips stay in a horizontal row and can scroll on narrow layouts.
The headless emulator check used `--no-enable-impeller
--enable-software-rendering` for software graphics; the standard `flutter run`
command is the usual interactive launch.
