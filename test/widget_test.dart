import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/add_book_screen.dart';
import 'package:reading_list/detail_screen.dart';
import 'package:reading_list/main.dart';
import 'package:reading_list/models/book.dart';
import 'package:reading_list/widgets/book_tile.dart';

Finder chip(String label) => find.widgetWithText(ChoiceChip, label);
Finder tile(String title) => find.widgetWithText(BookTile, title);
Finder field(int index) => find.byType(TextFormField).at(index);
Finder get save => find.widgetWithText(FilledButton, 'Save');

EditableText editable(WidgetTester tester, int index) =>
    tester.widget<EditableText>(
      find.descendant(of: field(index), matching: find.byType(EditableText)),
    );

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> openForm(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

void phoneSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('filter and checkbox update counts and preserve read flags', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text('1220'), findsOneWidget);
    await tester.tap(chip('Unread'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (4)'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(chip('Unread')).selected, isTrue);
    final firstUnread = tile('Null Safety for Humans');
    await tapVisible(
      tester,
      find.descendant(of: firstUnread, matching: find.byType(Checkbox)),
    );
    expect(find.text('Reading list (3)'), findsOneWidget);
    expect(tile('Null Safety for Humans'), findsNothing);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1220'), findsOneWidget);
    await tester.tap(chip('Read'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (2)'), findsOneWidget);
    expect(tile('Null Safety for Humans'), findsOneWidget);
    await tester.tap(chip('All'));
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(unread(seed), hasLength(4));
  });

  testWidgets('book tiles wrap and ellipsize with aligned checkboxes', (
    tester,
  ) async {
    phoneSize(tester, const Size(320, 800));
    final books = seed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              BookTile(book: books.first, onToggle: () {}, onTap: () {}),
              BookTile(book: books.last, onToggle: () {}, onTap: () {}),
            ],
          ),
        ),
      ),
    );
    final title = tester.widget<Text>(find.text(books.last.title));
    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(
      tester
          .renderObject<RenderParagraph>(find.text(books.last.title))
          .didExceedMaxLines,
      isTrue,
    );
    expect(
      tester.getCenter(find.byType(Checkbox).first).dx,
      tester.getCenter(find.byType(Checkbox).last).dx,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'library survives portrait and landscape with a scrollable list',
    (tester) async {
      phoneSize(tester, const Size(360, 800));
      await tester.pumpWidget(const MyApp());
      expect(tester.takeException(), isNull);
      tester.view.physicalSize = const Size(800, 360);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(seed.last.title),
        250,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Reading list (5)'), findsOneWidget);
    },
  );

  testWidgets('detail back returns no action and a missing year is honest', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tapVisible(tester, tile('Constraints Go Down, Sizes Go Up'));
    expect(find.byType(DetailScreen), findsOneWidget);
    expect(find.text('Year unknown'), findsOneWidget);
    expect(find.text('320'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text('1220'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('detail returns toggle action and unread filter reacts', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(chip('Unread'));
    await tester.pumpAndSettle();
    await tapVisible(tester, tile('Null Safety for Humans'));
    await tapVisible(tester, find.text('Mark as read'));
    expect(find.text('Reading list (3)'), findsOneWidget);
    expect(tile('Null Safety for Humans'), findsNothing);
    await tester.tap(chip('Read'));
    await tester.pumpAndSettle();
    await tapVisible(tester, tile('Null Safety for Humans'));
    await tapVisible(tester, find.text('Mark as unread'));
    expect(find.text('Reading list (1)'), findsOneWidget);
    expect(unread(seed), hasLength(4));
  });

  testWidgets(
    'delete cancel stays in detail and confirm removes exactly a book',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tapVisible(tester, tile('Widgets All the Way Down'));
      await tapVisible(tester, find.widgetWithText(OutlinedButton, 'Delete'));
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tapVisible(tester, find.widgetWithText(OutlinedButton, 'Delete'));
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Reading list (4)'), findsOneWidget);
      expect(tile('Widgets All the Way Down'), findsNothing);
      expect(find.text('932'), findsOneWidget);
      expect(find.text('4'), findsNWidgets(2));
    },
  );

  testWidgets('empty form shows three errors and accepts an empty year', (
    tester,
  ) async {
    await openForm(tester);
    expect(find.text('A whole number above 0'), findsNothing);
    await tapVisible(tester, save);
    expect(find.text('Title must have at least 2 characters'), findsOneWidget);
    expect(find.text('Enter an author'), findsOneWidget);
    expect(find.text('A whole number above 0'), findsOneWidget);
    expect(
      find.text('A year between 1450 and ${DateTime.now().year}'),
      findsNothing,
    );
    await tester.enterText(field(0), '  A  ');
    await tester.pump();
    expect(find.text('Title must have at least 2 characters'), findsOneWidget);
    await tester.enterText(field(0), '  Ab  ');
    await tester.pump();
    expect(find.text('Title must have at least 2 characters'), findsNothing);
    for (final invalid in ['abc', '0', '-1', '1.5']) {
      await tester.enterText(field(2), invalid);
      await tester.pump();
      expect(find.text('A whole number above 0'), findsOneWidget);
    }
    await tester.enterText(field(2), '1');
    await tester.pump();
    expect(find.text('A whole number above 0'), findsNothing);
    expect(find.byType(AddBookScreen), findsOneWidget);
  });

  testWidgets('year validates both limits without making the year required', (
    tester,
  ) async {
    await openForm(tester);
    final error = 'A year between 1450 and ${DateTime.now().year}';
    for (final invalid in ['abc', '1449', '${DateTime.now().year + 1}']) {
      await tester.enterText(field(3), invalid);
      await tester.pump();
      expect(find.text(error), findsOneWidget);
    }
    for (final valid in ['1450', '${DateTime.now().year}', '  ']) {
      await tester.enterText(field(3), valid);
      await tester.pump();
      expect(find.text(error), findsNothing);
    }
  });

  testWidgets('saving returns a trimmed unread book with a null year', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(chip('Unread'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(field(0), '  A New Book  ');
    await tester.enterText(field(1), '  A New Author  ');
    await tester.enterText(field(2), '100');
    await tapVisible(tester, save);
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('1320'), findsOneWidget);
    expect(tester.widget<ChoiceChip>(chip('Unread')).selected, isTrue);
    await tester.scrollUntilVisible(
      find.text('A New Book'),
      250,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    await tapVisible(tester, tile('A New Book'));
    expect(find.text('A New Author'), findsOneWidget);
    expect(find.text('Year unknown'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Unread'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('back from add form adds nothing', (tester) async {
    await openForm(tester);
    await tester.enterText(field(0), 'An unfinished book');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Reading list (5)'), findsOneWidget);
    expect(find.text('1220'), findsOneWidget);
    expect(tile('An unfinished book'), findsNothing);
  });

  testWidgets(
    'keyboard next actions reach year and done uses Save validation',
    (tester) async {
      await openForm(tester);
      await tester.showKeyboard(field(0));
      for (var next = 1; next < 4; next++) {
        await tester.testTextInput.receiveAction(TextInputAction.next);
        await tester.pump();
        expect(editable(tester, next).focusNode.hasFocus, isTrue);
      }
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(
        find.text('Title must have at least 2 characters'),
        findsOneWidget,
      );
      expect(find.text('Enter an author'), findsOneWidget);
      expect(find.text('A whole number above 0'), findsOneWidget);
      expect(find.byType(AddBookScreen), findsOneWidget);
    },
  );

  testWidgets('keyboard inset permits scrolling and outside tap unfocuses', (
    tester,
  ) async {
    phoneSize(tester, const Size(400, 800));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await openForm(tester);
    await tapVisible(tester, field(3));
    expect(editable(tester, 3).focusNode.hasFocus, isTrue);
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    expect(tester.getRect(save).bottom, lessThanOrEqualTo(500));
    expect(tester.takeException(), isNull);
    await tester.tapAt(const Offset(4, 100));
    await tester.pump();
    expect(editable(tester, 3).focusNode.hasFocus, isFalse);
  });
}
