import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:never_overflows/contact_card.dart';
import 'package:never_overflows/contact_list.dart';
import 'package:never_overflows/contacts.dart';
import 'package:never_overflows/main.dart';

void main() {
  testWidgets('long names wrap and all twenty contacts are reachable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MyApp());

    expect(find.text('20 contacts'), findsOneWidget);
    expect(contacts, hasLength(20));
    expect(find.text(contacts[4].name), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text(contacts.last.name),
      500,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text(contacts.last.name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('badge is absent at zero and present otherwise', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ContactCard(contact: contacts.first)),
      ),
    );
    expect(find.text('0'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ContactCard(contact: contacts[3])),
      ),
    );
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('captures light, dark, and swapped-stack screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue();
    });

    await _capture(tester, const MyApp(), 'screenshot_light.png');

    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    await _capture(tester, const MyApp(), 'screenshot_dark.png');

    await _capture(
      tester,
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),
        home: Scaffold(
          appBar: AppBar(title: const Text('Contacts — swapped Stack')),
          body: const ContactList(badgeBehindAvatar: true),
        ),
      ),
      'stack_swapped.png',
    );
  });
}

Future<void> _capture(WidgetTester tester, Widget app, String fileName) async {
  const screenshotKey = Key('contacts-screenshot');
  await tester.pumpWidget(
    RepaintBoundary(
      key: screenshotKey,
      child: SizedBox(width: 390, height: 844, child: app),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byKey(screenshotKey),
    matchesGoldenFile('../$fileName'),
  );
}
