import 'package:flutter/material.dart';

import '../models/workshop.dart';
import '../widgets/empty_state.dart';
import '../widgets/workshop_card.dart';

class WorkshopListTab extends StatefulWidget {
  const WorkshopListTab({
    super.key,
    required this.workshops,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
    this.favouritesOnly = false,
  });

  final List<Workshop> workshops;
  final ValueChanged<Workshop> onOpen;
  final ValueChanged<Workshop> onFavourite;
  final VoidCallback onBrowse;
  final bool favouritesOnly;

  @override
  State<WorkshopListTab> createState() => _WorkshopListTabState();
}

class _WorkshopListTabState extends State<WorkshopListTab> {
  final _search = TextEditingController();
  WorkshopCategory? _category;
  bool _includePast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Workshop> get _visible {
    final query = _search.text.trim().toLowerCase();
    final result = widget.workshops
        .where(
          (workshop) =>
              (widget.favouritesOnly == false || workshop.favourite) &&
              (_category == null || workshop.category == _category) &&
              (_includePast || workshop.isPast == false) &&
              workshop.title.toLowerCase().contains(query),
        )
        .toList();
    // Sort the new filtered list, never the list owned by the shell.
    result.sort((a, b) {
      if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
      return a.when.compareTo(b.when);
    });
    return result;
  }

  void _clearSearch() => setState(() => _search.clear());

  @override
  Widget build(BuildContext context) {
    final items = _visible;
    final hasFavourites = widget.workshops.any(
      (workshop) => workshop.favourite,
    );
    final theme = Theme.of(context);
    final free = widget.workshops
        .where((workshop) => workshop.isPast == false)
        .fold<int>(0, (sum, workshop) => sum + workshop.freePlaces);
    Widget card(int index) => WorkshopCard(
      workshop: items[index],
      onOpen: () => widget.onOpen(items[index]),
      onFavourite: () => widget.onFavourite(items[index]),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.favouritesOnly
                    ? 'Your next good idea'
                    : 'Make something. Meet someone.',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                widget.favouritesOnly
                    ? 'A place for workshops you want to keep.'
                    : '${widget.workshops.length} workshops · $free upcoming places',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _search,
                validator: (_) => null,
                onChanged: (_) => setState(() {}),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: InputDecoration(
                  labelText: 'Search workshops',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final category in WorkshopCategory.values)
                ChoiceChip(
                  label: Text(category.label),
                  avatar: Icon(category.icon, size: 18),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Include past'),
                selected: _includePast,
                onSelected: (value) => setState(() => _includePast = value),
              ),
              const SizedBox(width: 12),
              Text('${items.length} shown', style: theme.textTheme.labelMedium),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? EmptyState(
                  icon: widget.favouritesOnly && hasFavourites == false
                      ? Icons.favorite_border
                      : Icons.search_off,
                  message: widget.favouritesOnly && hasFavourites == false
                      ? 'No favourites yet. Keep a workshop with the heart button.'
                      : 'No workshops match these filters.',
                  buttonLabel: widget.favouritesOnly && hasFavourites == false
                      ? 'Browse workshops'
                      : 'Clear search',
                  onPressed: widget.favouritesOnly && hasFavourites == false
                      ? widget.onBrowse
                      : _clearSearch,
                )
              : LayoutBuilder(
                  builder: (context, constraints) => constraints.maxWidth >= 600
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 360,
                                mainAxisExtent: 184,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: items.length,
                          itemBuilder: (_, index) => card(index),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                          itemCount: items.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(height: 4),
                          itemBuilder: (_, index) => card(index),
                        ),
                ),
        ),
      ],
    );
  }
}
