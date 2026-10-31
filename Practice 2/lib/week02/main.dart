import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  library.open();

  for (final rawBook in rawBooks) {
    library.add(Book.fromJson(rawBook));
  }

  final books = library.books;
  final stats = statsOf(books);

  print(library.buildReport());
  print('Opened: ${library.openedAt.toIso8601String()}');
  print('Every title: ${library.titles}');
  print('After 2010: ${library.booksAfter2010.map((book) => book.title)}');
  print('Average pages: ${library.averagePageCount.toStringAsFixed(2)}');
  print('Books per author: ${library.bookCountByAuthor}');
  print('Authors: ${library.authorNames}');
  print('Genres: ${library.genres.map((genre) => genre.label).toSet()}');
  print('Refactoring country: ${library.countryOf('Refactoring')}');
  print('Design Patterns country: ${library.countryOf('Design Patterns')}');
  print('Missing country: ${library.countryOf('Missing')}');
  print(
    'Stats: count=${stats.count}, avgPages=${stats.avgPages.toStringAsFixed(2)}',
  );

  for (final state in <ShelfState>[
    const Empty(),
    Ready(books),
    const Broken('shelf sensor is offline'),
  ]) {
    print(describe(state));
  }
}
