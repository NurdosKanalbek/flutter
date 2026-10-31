import 'package:flutter/material.dart';

import '../models/book.dart';

class BookTile extends StatelessWidget {
  const BookTile({
    super.key,
    required this.book,
    required this.onToggle,
    required this.onTap,
  });

  final Book book;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      color: colors.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                    child: Text(
                      book.title.isEmpty
                          ? '?'
                          : book.title.characters.first.toUpperCase(),
                      style: text.titleLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  if (book.read == false)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Tooltip(
                        message: 'Unread',
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.tertiary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.surface, width: 2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.title,
                      style: text.titleMedium?.copyWith(
                        color: colors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.author} · ${book.pages} pp.',
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'Mark ${book.title} as ${book.read ? 'unread' : 'read'}',
                child: Checkbox(
                  value: book.read,
                  onChanged: (_) => onToggle(),
                  activeColor: colors.primary,
                  checkColor: colors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
