# Manual verification

No test files or test dependencies are included in this lab.

## Tool checks

- `dart format .`: all Dart sources formatted.
- `flutter analyze`: **No issues found!**
- `flutter build apk --debug --target-platform android-x64`: debug Android APK built successfully.

## Android emulator checks

Checked on the installed API 30 x86_64 emulator. Phone captures use 720 × 1520 pixels at density 280; the tablet capture uses 1440 × 1920 pixels at density 240 (960 logical pixels wide). Size and density overrides are restored after capture.

- Initial catalogue: 12 workshops, 88 upcoming places, 10 visible upcoming workshops. The 60-character title uses two lines, with no overflow stripes.
- Fully booked soldering workshop: three makers, zero free places, disabled Workshop full button. The pushed page covers the bottom navigation bar.
- Profile entered using the keyboard action keys: name `Nurdos`, group `IT-2301`, submit shows Profile saved.
- Dark selected from profile: theme and selected chip update immediately; navigating back to Explore preserves the selection. Light restored before tablet capture.
- Tablet configuration: catalogue switches live to three grid columns; cells remain below the 360-logical-pixel cap. All five category chips fit; no overflow stripes.
- Joining the repair workshop asks for confirmation, updates Makers (7) to Makers (8), highlights Nurdos as You and changes the action to Leave workshop. Profile membership count changes to one.
- Empty new form Save: title/place/date/time errors appear beside their fields. Back returns immediately because validation alone does not change values.
- New form keyboard sequence: title → place → limit → description. With the description keyboard open, scrolling reveals Save; no overflow stripes.
- Android Back on a dirty form asks Discard changes?; Keep editing preserves the typed title, place and description.
- New workshop created using both pickers: catalogue increases to 13 items and 99 upcoming places. Two rapid taps do not add a duplicate item.
- Editing an eight-maker workshop with limit 7 displays At least 8 makers are already on the list. Restoring 12 clears that error.
- Cancelling both date and time pickers preserves 22 Oct, 17:30. Saving a changed title returns to detail and preserves all eight makers.
- Delete cancelled leaves the workshop in place; confirmed Delete removes it and returns to the catalogue.
- Confirmed Reset data restores the seed and clears both profile controllers. Joining with the empty profile shows the SnackBar; its Profile action closes detail and selects the Profile tab through the shell callback.
- Final APK: removing a favourite immediately reduces the Favourites list from three to two cards. The short-window catalogue was inspected at 1520 × 720 pixels; no overflow stripes or Flutter layout exceptions were present, and the phone size was restored afterwards.
- Emulator logs checked after navigation, dialogs and form use: no Flutter layout exceptions, unhandled exceptions or setState-after-dispose errors.

## Screenshots

The three committed PNGs in `docs/screenshots/` were captured directly from Android using `adb`, then visually inspected. Keyboard inspection images are local verification artifacts only.

This computer's headless software renderer was launched with `--no-enable-impeller --enable-software-rendering`; ordinary interactive devices can use `flutter run`. These are local launch flags, not platform-specific source or manifest settings.

## Practice before the defence

Trace shell callbacks, the form's returned value, the private const constructor and immutable list factory, the record snapshot, and every mounted check. Try the pool tasks offline in your own checkout. Be ready to explain why a cancelled form cannot update the shell and why sorting the filtered copy cannot reorder state.
