import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((book) => book.read).toList(),
  };

  void _toggle(Book book) => setState(() => book.read = book.read == false);

  Future<void> _openDetail(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute<BookAction>(builder: (_) => DetailScreen(book: book)),
    );
    if (mounted == false) return;

    switch (action) {
      case null:
        return;
      case BookAction.toggleRead:
        _toggle(book);
        return;
      case BookAction.delete:
        setState(() => _books.remove(book));
        return;
    }
  }

  Future<void> _addBook() async {
    final book = await Navigator.of(context).push<Book>(
      MaterialPageRoute<Book>(builder: (_) => const AddBookScreen()),
    );
    if (mounted == false) return;
    if (book == null) return;
    setState(() => _books.add(book));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${visible.length})')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        tooltip: 'Add book',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Card(
                margin: EdgeInsets.zero,
                color: colors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      for (final statistic in [
                        (label: 'Books', value: _books.length),
                        (label: 'Pages', value: totalPages(_books)),
                        (label: 'Unread', value: unread(_books).length),
                      ])
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${statistic.value}',
                                style: text.headlineSmall?.copyWith(
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                statistic.label,
                                style: text.bodySmall?.copyWith(
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filter in Filter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(switch (filter) {
                            Filter.all => 'All',
                            Filter.unread => 'Unread',
                            Filter.read => 'Read',
                          }),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          switch (_filter) {
                            Filter.all =>
                              'Your reading list is empty. Add a book.',
                            Filter.unread => 'No unread books. All caught up.',
                            Filter.read => 'No books marked as read yet.',
                          },
                          textAlign: TextAlign.center,
                          style: text.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final book = visible[index];
                        return BookTile(
                          book: book,
                          onToggle: () => _toggle(book),
                          onTap: () => _openDetail(book),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
