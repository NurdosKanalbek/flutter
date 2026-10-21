import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_form/main.dart';
import 'package:signup_form/summary_card.dart';

Finder field(int index) => find.byType(TextFormField).at(index);
EditableText editable(WidgetTester tester, int index) =>
    tester.widget<EditableText>(
      find.descendant(of: field(index), matching: find.byType(EditableText)),
    );

Finder get signUp => find.widgetWithText(FilledButton, 'Sign up');

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> fillForm(WidgetTester tester) async {
  await tester.enterText(field(0), '  Nurdos Kanalbek  ');
  await tester.enterText(field(1), 'nurdos@kbtu.kz');
  await tester.enterText(field(2), 'student123');
  await tester.enterText(field(3), 'student123');
  await tapVisible(tester, find.byType(DropdownButtonFormField<String>));
  await tester.tap(find.text('IT-2302').last);
  await tester.pumpAndSettle();
  await tapVisible(tester, field(4));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('starts without errors and consent gates the button', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Name is too short'), findsNothing);
    expect(tester.widget<FilledButton>(signUp).onPressed, isNull);
    await tapVisible(tester, find.byType(CheckboxListTile));
    expect(tester.widget<FilledButton>(signUp).onPressed, isNotNull);
    await tapVisible(tester, find.byType(CheckboxListTile));
    expect(tester.widget<FilledButton>(signUp).onPressed, isNull);
  });

  testWidgets('one submit shows all six field errors', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tapVisible(tester, find.byType(CheckboxListTile));
    await tapVisible(tester, signUp);
    for (final message in [
      'Name is too short',
      'Email looks wrong',
      'Password is too short',
      'Confirm your password',
      'Choose a group',
      'Choose your date of birth',
    ]) {
      expect(find.text(message), findsOneWidget);
    }
    await tester.enterText(field(0), '  A  ');
    await tester.pump();
    expect(find.text('Name is too short'), findsOneWidget);
    await tester.enterText(field(0), '  Ada  ');
    await tester.pump();
    expect(find.text('Name is too short'), findsNothing);
    expect(find.text('Email looks wrong'), findsOneWidget);
    await tester.enterText(field(1), 'ada.kbtu@kz');
    await tester.pump();
    expect(find.text('Email looks wrong'), findsOneWidget);
    await tester.enterText(field(1), 'ada@kbtu.kz');
    await tester.pump();
    expect(find.text('Email looks wrong'), findsNothing);
  });

  testWidgets('password rebuild preserves name and revalidates confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.enterText(field(0), 'Ada');
    await tester.enterText(field(2), 'student123');
    await tester.enterText(field(3), 'student123');
    await tester.pump();
    expect(find.text('Passwords do not match'), findsNothing);
    await tester.enterText(field(2), 'student124');
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(find.text('10 of 8'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets('keyboard actions advance and done validates when consented', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tapVisible(tester, find.byType(CheckboxListTile));
    await tester.showKeyboard(field(0));
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(editable(tester, 1).focusNode.hasFocus, isTrue);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(editable(tester, 2).focusNode.hasFocus, isTrue);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(editable(tester, 3).focusNode.hasFocus, isTrue);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Name is too short'), findsOneWidget);
    expect(find.text('Confirm your password'), findsOneWidget);
  });

  testWidgets('done cannot submit without consent', (tester) async {
    await tester.pumpWidget(const MyApp());
    await fillForm(tester);
    await tester.showKeyboard(field(3));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(SummaryCard), findsNothing);
    expect(tester.widget<FilledButton>(signUp).onPressed, isNull);
  });

  testWidgets('date picker cancel preserves selected date', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tapVisible(tester, field(4));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final selected = tester.widget<TextFormField>(field(4)).controller?.text;
    expect(selected, matches(RegExp(r'^\d{2}\.\d{2}\.\d{4}$')));
    await tapVisible(tester, field(4));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(field(4)).controller?.text, selected);
  });

  testWidgets('valid submission and start over clear every value', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await fillForm(tester);
    await tapVisible(tester, find.byType(CheckboxListTile));
    await tapVisible(tester, signUp);
    expect(find.byType(SummaryCard), findsOneWidget);
    expect(find.byType(Form), findsNothing);
    expect(find.text('Nurdos Kanalbek'), findsOneWidget);
    expect(find.text('nurdos@kbtu.kz'), findsOneWidget);
    expect(find.text('IT-2302'), findsOneWidget);
    expect(find.text('Account created'), findsOneWidget);
    await tapVisible(tester, find.text('Start over'));
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(SummaryCard), findsNothing);
    for (var index = 0; index < 5; index++) {
      expect(
        tester.widget<TextFormField>(field(index)).controller?.text,
        isEmpty,
      );
    }
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isFalse,
    );
    expect(tester.widget<FilledButton>(signUp).onPressed, isNull);
    expect(find.text('Name is too short'), findsNothing);
    expect(find.text('0 of 8'), findsOneWidget);
    await tapVisible(tester, find.byType(CheckboxListTile));
    await tapVisible(tester, signUp);
    expect(find.text('Name is too short'), findsOneWidget);
    expect(find.text('Choose a group'), findsOneWidget);
    expect(find.text('Choose your date of birth'), findsOneWidget);
  });

  testWidgets('keyboard inset allows scrolling to confirm and submit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MyApp());
    await tapVisible(tester, field(3));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(signUp);
    await tester.pumpAndSettle();
    expect(tester.getRect(signUp).bottom, lessThanOrEqualTo(480));
    expect(tester.takeException(), isNull);
    await tester.tapAt(const Offset(4, 100));
    await tester.pump();
    expect(editable(tester, 3).focusNode.hasFocus, isFalse);
  });

  testWidgets('summary changes columns at its own 600 px boundary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget summary(double width) => MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: const SummaryCard(
              name: 'Ada Lovelace',
              email: 'ada@kbtu.kz',
              group: 'IT-2301',
              birthDate: '10.12.2004',
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(summary(599));
    expect(find.byType(GridView), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(4));
    await tester.pumpWidget(summary(600));
    expect(find.byType(GridView), findsOneWidget);
    expect(
      tester.widget<GridView>(find.byType(GridView)).gridDelegate,
      isA<SliverGridDelegateWithFixedCrossAxisCount>()
          .having((delegate) => delegate.crossAxisCount, 'columns', 2)
          .having((delegate) => delegate.childAspectRatio, 'aspect ratio', 4),
    );
    expect(tester.takeException(), isNull);
  });
}
