import 'models.dart';

sealed class ShelfState {
  const ShelfState();
}

final class Empty extends ShelfState {
  const Empty();
}

final class Ready extends ShelfState {
  const Ready(this.books);

  final List<Book> books;
}

final class Broken extends ShelfState {
  const Broken(this.message);

  final String message;
}

String describe(ShelfState state) => switch (state) {
  Empty() => 'The shelf is empty',
  Ready(books: final books) => 'The shelf is ready with ${books.length} books',
  Broken(message: final message) => 'The shelf is broken: $message',
};

({int count, double avgPages}) statsOf(List<Book> books) {
  final totalPages = books.fold<int>(0, (total, book) => total + book.pages);
  return (
    count: books.length,
    avgPages: books.isEmpty ? 0 : totalPages / books.length,
  );
}
