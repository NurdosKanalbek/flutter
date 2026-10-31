import 'models.dart';

class Library {
  Library([List<LibraryItem>? items]) : items = items ?? <LibraryItem>[];

  final List<LibraryItem> items;
  late final DateTime openedAt;
  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
    _cachedReport = null;
  }

  void open() => openedAt = DateTime.now();

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item case final Book book when book.title == title) {
        return book;
      }
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  List<Book> get books => items.whereType<Book>().toList(growable: false);

  List<String> get titles =>
      items.map((item) => item.title).toList(growable: false);

  List<Book> get booksAfter2010 =>
      books.where((book) => book.year > 2010).toList(growable: false);

  // fold has a safe seed for an empty catalogue; reduce would throw.
  double get averagePageCount => books.isEmpty
      ? 0
      : books.fold<int>(0, (total, book) => total + book.pages) / books.length;

  Map<String, int> get bookCountByAuthor => books.fold(
    <String, int>{},
    (counts, book) =>
        counts
          ..update(book.author.name, (count) => count + 1, ifAbsent: () => 1),
  );

  Set<String> get authorNames => books.map((book) => book.author.name).toSet();

  Set<Genre> get genres => books.map((book) => book.genre).toSet();

  List<String> get displayLines => [
    'CATALOGUE',
    for (final book in books) '${book.title} (${book.year})',
    ...authorNames,
    if (books.any((book) => book.pages == 0)) '(incomplete data)',
  ];

  String buildReport() {
    final cached = _cachedReport;
    if (cached case final String value) {
      return value;
    }
    final report = displayLines.join('\n');
    _cachedReport ??= report;
    return report;
  }
}
