import 'package:flutter_test/flutter_test.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  group('Cart Model (Level 2 & 4)', () {
    test(
      'works with no widgets in sight and enforces no duplicates in add',
      () {
        final cart = Cart();
        expect(cart.count, 0);
        expect(cart.total, 0);

        // Add two books
        final added1 = cart.add(books[0]); // 4200
        final added2 = cart.add(books[1]); // 3100
        expect(added1, isTrue);
        expect(added2, isTrue);
        expect(cart.count, 2);
        expect(cart.total, 7300);

        // Add the first one again - rule in one place: returns false, does nothing
        final addedAgain = cart.add(books[0]);
        expect(addedAgain, isFalse);
        expect(cart.count, 2);
        expect(cart.total, 7300);

        // Remove first book
        cart.remove(books[0]);
        expect(cart.count, 1);
        expect(cart.total, 3100);
        expect(cart.items, [books[1]]);
      },
    );

    test('cart.items is unmodifiable and throws on modification', () {
      final cart = Cart();
      cart.add(books[0]);

      expect(() => cart.items.add(books[1]), throwsA(isA<UnsupportedError>()));
    });

    test('increment increases quantity and updates total', () {
      final cart = Cart();
      cart.add(books[1]); // 3100
      expect(cart.qtyOf(books[1]), 1);
      expect(cart.total, 3100);

      cart.increment(books[1]);
      expect(cart.qtyOf(books[1]), 2);
      expect(cart.total, 6200);
      // count is distinct books
      expect(cart.count, 1);
    });

    test('clear removes all items', () {
      final cart = Cart();
      cart.add(books[0]);
      cart.add(books[1]);
      expect(cart.count, 2);

      cart.clear();
      expect(cart.count, 0);
      expect(cart.total, 0);
      expect(cart.items, isEmpty);
    });
  });
}
