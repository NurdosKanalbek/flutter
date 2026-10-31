import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_title, _author, _pages, _year]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate() == false) return;

    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text.trim()),
      year: int.tryParse(_year.text.trim()),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add book')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add to your reading list',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Title, author and pages are required. Year is optional.',
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (value) => (value ?? '').trim().length < 2
                        ? 'Title must have at least 2 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _author,
                    decoration: const InputDecoration(labelText: 'Author'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (value) =>
                        (value ?? '').trim().isEmpty ? 'Enter an author' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pages,
                    decoration: const InputDecoration(labelText: 'Pages'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (value) {
                      final number = int.tryParse((value ?? '').trim());
                      if (number == null || number <= 0) {
                        return 'A whole number above 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _year,
                    decoration: const InputDecoration(
                      labelText: 'Year (optional)',
                      helperText: 'Leave blank if the year is unknown',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (value) {
                      final yearText = (value ?? '').trim();
                      if (yearText.isEmpty) return null;
                      final year = int.tryParse(yearText);
                      final currentYear = DateTime.now().year;
                      return year == null || year < 1450 || year > currentYear
                          ? 'A year between 1450 and $currentYear'
                          : null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.add),
                    label: const Text('Save'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
