import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile_screen/info_row.dart';
import 'package:profile_screen/main.dart';
import 'package:profile_screen/profile_header.dart';

void main() {
  testWidgets('renders the profile from reusable stateless widgets', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(ProfileHeader), findsOneWidget);
    expect(find.byType(InfoRow), findsNWidgets(4));
    expect(find.text('Alimzhan Sagynayev'), findsOneWidget);
    expect(find.byType(StatefulWidget), findsNothing);
    expect(find.byType(ButtonStyleButton), findsNothing);
  });

  testWidgets('captures the finished profile screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const screenshotKey = Key('profile-screenshot');
    await tester.pumpWidget(
      const RepaintBoundary(
        key: screenshotKey,
        child: SizedBox(width: 390, height: 844, child: MyApp()),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(screenshotKey),
      matchesGoldenFile('../screenshot.png'),
    );
  });
}
