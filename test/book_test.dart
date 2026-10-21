import 'package:flutter_test/flutter_test.dart';
import 'package:reading_list/models/book.dart';

void main() {
  test('fromMap requires typed keys and defaults missing optional values', () {
    final book = Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10});
    expect(book.title, 'X');
    expect(book.author, 'Y');
    expect(book.pages, 10);
    expect(book.year, isNull);
    expect(book.read, isFalse);
    expect(
      () => Book.fromMap({'title': 'X', 'author': 'Y', 'pages': '10'}),
      throwsA(isA<TypeError>()),
    );
  });

  test('fromMap preserves an explicit year and read flag', () {
    final book = Book.fromMap({
      'title': 'A book',
      'author': 'An author',
      'pages': 42,
      'year': 2001,
      'read': true,
    });
    expect(book.year, 2001);
    expect(book.read, isTrue);
  });

  test('toString includes a known year and omits a missing year entirely', () {
    expect(
      seed[1].toString(),
      'Null Safety for Humans — B. Seitkali, 196 pp. (2022)',
    );
    expect(
      Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10}).toString(),
      'X — Y, 10 pp.',
    );
    expect(
      seed[2].toString(),
      'Constraints Go Down, Sizes Go Up — C. Tashimova, 320 pp.',
    );
  });

  test(
    'collection helpers produce the required seed totals and empty results',
    () {
      expect(totalPages(seed), 1220);
      expect(unread(seed), hasLength(4));
      expect(totalPages([]), 0);
      expect(unread([]), isEmpty);
      expect(authors([]), isEmpty);
    },
  );

  test(
    'authors removes duplicates while preserving first appearance order',
    () {
      final books = [
        Book(title: 'One', author: 'B', pages: 1),
        Book(title: 'Two', author: 'A', pages: 2),
        Book(title: 'Three', author: 'B', pages: 3),
        Book(title: 'Four', author: 'C', pages: 4),
      ];
      expect(authors(books), ['B', 'A', 'C']);
    },
  );

  test('separate seed copies have independent mutable read flags', () {
    final first = [...seed];
    final second = [...seed];
    first[1].read = true;
    first.removeAt(0);
    expect(unread(second), hasLength(4));
    expect(second, hasLength(5));
    expect(unread(seed), hasLength(4));
  });
}
