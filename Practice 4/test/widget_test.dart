import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_screen/main.dart';
import 'package:reactive_screen/stopwatch_card.dart';
import 'package:reactive_screen/tap_card.dart';
import 'package:reactive_screen/two_way_counter.dart';

void main() {
  testWidgets('tap count can be cancelled or reset', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TapCard()));
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.text('Tap this card'));
    }
    await tester.pump();
    expect(find.text('10'), findsOneWidget);

    await tester.longPress(find.text('Tap this card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('10'), findsOneWidget);

    await tester.longPress(find.text('Tap this card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('counter disables minus and prevents a duplicate save', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TwoWayCounter())),
    );
    final minus = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, '−'),
    );
    expect(minus.onPressed, isNull);

    await tester.tap(find.text('+'));
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byKey(const Key('save-button')));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('stopwatch increments and cancels its timer on dispose', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: StopwatchCard()));
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:03'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('captures a running, non-zero finished screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const screenshotKey = Key('reactive-screenshot');

    await tester.pumpWidget(
      const RepaintBoundary(
        key: screenshotKey,
        child: SizedBox(width: 390, height: 844, child: MyApp()),
      ),
    );
    await tester.tap(find.text('Tap this card'));
    await tester.tap(find.text('Tap this card'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(seconds: 3));

    await expectLater(
      find.byKey(screenshotKey),
      matchesGoldenFile('../screenshot.png'),
    );
    await tester.pumpWidget(const SizedBox());
  });
}
