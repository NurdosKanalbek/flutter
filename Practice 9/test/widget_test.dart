import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/cart_screen.dart';
import 'package:shop/main.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  Widget createTestApp({Cart? cart}) {
    return ChangeNotifierProvider<Cart>(
      create: (_) => cart ?? Cart(),
      child: const Shell(),
    );
  }

  testWidgets(
    'Full flow: Add books, SnackBar, search, cart, increment, clear',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      // Initially badge says 0
      expect(find.text('0'), findsOneWidget);

      // 1. Add first book: OutlinedButton 'Add'
      final firstAddBtn = find.widgetWithText(OutlinedButton, 'Add').first;
      await tester.tap(firstAddBtn);
      await tester.pump(); // Start snackbar animation

      // Verify SnackBar shown
      expect(
        find.textContaining('Added "Widgets All the Way Down"'),
        findsOneWidget,
      );
      // Badge updated to 1
      expect(find.text('1'), findsOneWidget);
      // Button changed to 'Added' text
      expect(find.text('Added'), findsOneWidget);

      // 2. Add second book
      final secondAddBtn = find.widgetWithText(OutlinedButton, 'Add').first;
      await tester.tap(secondAddBtn);
      await tester.pump();

      // Badge updated to 2
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Added'), findsNWidgets(2));

      // 3. Test Search (ephemeral state in BooksScreen)
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Null Safety');
      await tester.pumpAndSettle();

      expect(find.text('Null Safety for Humans'), findsOneWidget);
      expect(find.text('Widgets All the Way Down'), findsNothing);

      // Close search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Widgets All the Way Down'), findsOneWidget);

      // 4. Open Cart screen via CartBadge
      await tester.tap(find.byTooltip('Cart (2 items)'));
      await tester.pumpAndSettle();

      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('×1'), findsNWidgets(2));
      // Initial total: 4200 + 3100 = 7300 ₸
      expect(find.text('7300 ₸'), findsOneWidget);

      // 5. Test increment (Level 4 quantity)
      // Tap '+' on the first item
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();

      // Now quantity should show ×2 and total increases by 4200 (7300 + 4200 = 11500 ₸)
      expect(find.text('×2'), findsOneWidget);
      expect(find.text('11500 ₸'), findsOneWidget);

      // 6. Test expand/collapse total details
      await tester.tap(find.text('Total:'));
      await tester.pumpAndSettle();
      expect(find.text('Distinct Titles:'), findsOneWidget);
      expect(find.text('Ready for checkout'), findsOneWidget);

      // 7. Test Clear Cart with dialog confirmation (Level 5)
      await tester.tap(find.byTooltip('Clear cart'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Cart'), findsOneWidget);
      expect(
        find.text('Are you sure you want to remove all books from your cart?'),
        findsOneWidget,
      );

      // Tap Cancel first
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('11500 ₸'), findsOneWidget); // still there

      // Tap Clear again and confirm
      await tester.tap(find.byTooltip('Clear cart'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);

      // 8. Go back to BooksScreen
      await tester.pageBack();
      await tester.pumpAndSettle();

      // All books are now unadded, badge says 0
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Added'), findsNothing);
      expect(
        find.widgetWithText(OutlinedButton, 'Add'),
        findsNWidgets(books.length),
      );
    },
  );

  testWidgets('Level 4: CartBadge does not rebuild when quantity increments', (
    WidgetTester tester,
  ) async {
    final cart = Cart();
    int badgeBuilds = 0;

    await tester.pumpWidget(
      ChangeNotifierProvider<Cart>.value(
        value: cart,
        child: MaterialApp(
          routes: {
            '/': (_) => Scaffold(
              appBar: AppBar(
                actions: [
                  Builder(
                    builder: (context) {
                      // select on count
                      final n = context.select<Cart, int>((c) => c.count);
                      badgeBuilds++;
                      return Text('Badge: $n');
                    },
                  ),
                ],
              ),
              body: const CartScreen(),
            ),
          },
        ),
      ),
    );

    // Initially badge built once
    expect(badgeBuilds, 1);
    expect(find.text('Badge: 0'), findsOneWidget);

    // Add a book: distinct count changes 0 -> 1, so badge MUST rebuild
    cart.add(books[0]);
    await tester.pumpAndSettle();
    expect(badgeBuilds, 2);
    expect(find.text('Badge: 1'), findsOneWidget);

    // Now increment quantity 3 times: count remains 1
    cart.increment(books[0]);
    await tester.pumpAndSettle();
    cart.increment(books[0]);
    await tester.pumpAndSettle();
    cart.increment(books[0]);
    await tester.pumpAndSettle();

    // With select<Cart, int>((c) => c.count), badgeBuilds MUST STILL BE 2!
    expect(badgeBuilds, 2);

    // Remove book: count changes 1 -> 0, badge rebuilds
    cart.remove(books[0]);
    await tester.pumpAndSettle();
    expect(badgeBuilds, 3);
    expect(find.text('Badge: 0'), findsOneWidget);
  });
}
