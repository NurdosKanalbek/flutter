import 'package:flutter/material.dart';

import '../models/workshop.dart';
import '../utils/format.dart';

class WorkshopCard extends StatelessWidget {
  const WorkshopCard({
    super.key,
    required this.workshop,
    required this.onOpen,
    required this.onFavourite,
  });

  final Workshop workshop;
  final VoidCallback onOpen;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (:taken, :free) = workshop.places;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 72,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: scheme.secondaryContainer,
                      child: Icon(
                        workshop.category.icon,
                        color: workshop.category.color(scheme),
                      ),
                    ),
                    if (free <= 5)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: workshop.isFull
                                ? scheme.errorContainer
                                : scheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(
                              workshop.isFull ? 'FULL' : '$free left',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: workshop.isFull
                                    ? scheme.onErrorContainer
                                    : scheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workshop.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatWhen(workshop.when),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      workshop.online
                          ? 'Online · ${workshop.category.label}'
                          : workshop.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '$taken / ${workshop.limit} makers',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavourite,
                tooltip: workshop.favourite
                    ? 'Remove favourite'
                    : 'Add favourite',
                icon: Icon(
                  workshop.favourite ? Icons.favorite : Icons.favorite_border,
                ),
                color: scheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
