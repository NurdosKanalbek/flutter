# Practice 7 — A Form That Validates Itself

A Flutter student sign-up form implementing the final state of Levels 1–5.

## Run

```sh
flutter pub get
flutter run
```

Use an Android device/emulator to check the real mobile keyboard, or use
`flutter run -d chrome` for a resizable desktop preview.

## Features

- A State-owned Form key, five controllers and an email FocusNode, all disposed.
- Inline null-safe validators and validation after user interaction.
- Name → Email → Password → Confirm keyboard navigation; Done uses the same
  submission method as the button when consent is checked.
- Password length counter, matching confirmation, outside-tap dismissal, and
  a scrollable form with 16 px padding.
- Validated group dropdown and date picker; Cancel preserves the previous date.
- Consent controls the button's enabled state and also gates keyboard submission.
- A separate const SummaryCard with four final named values, adapting to a
  two-column grid when its own available width reaches 600 px.
- Start over clears all values in one setState without accessing the absent Form.

There are six validators: four typed fields, group, and date of birth. This follows
the individual field tasks, including the date validator (the rubric's “five”
does not count that additional required field).

Level 1's temporary if-chain and deliberately broken examples are superseded by
the final form and are not left in the submitted application.

## Checks

```sh
dart format .
flutter analyze
flutter test
```

Widget tests cover validation, cross-field updates, focus navigation, consent,
date cancellation, reset, simulated keyboard insets, and the exact layout boundary.
A simulated inset test does not replace the required real-keyboard device check.

## Required submission screenshots

- `keyboard_open.png`: on a mobile device, focus Confirm password with the real
  keyboard open and show that the form scrolls without overflow.
- `tablet.png`: complete the form on a tablet or a wide desktop viewport and
  capture the summary showing two columns.

Capture these from the running app before final submission. Do not substitute
mock images for device evidence.
