import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = books.where((b) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search books...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text('Books'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() => _isSearching = true);
              },
            ),
          const CartBadge(),
        ],
      ),
      body: filteredBooks.isEmpty
          ? const Center(child: Text('No books match your search'))
          : ListView.builder(
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final b = filteredBooks[index];
                return BookRow(book: b);
              },
            ),
    );
  }
}

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final inCart = context.watch<Cart>().items.contains(book);

    return ListTile(
      title: Text(book.title),
      subtitle: Text('${book.author} • ${book.price} ₸'),
      trailing: inCart
          ? const Text(
              'Added',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            )
          : OutlinedButton(
              onPressed: () {
                final ok = context.read<Cart>().add(book);
                if (ok) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added "${book.title}" to cart'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
    );
  }
}
