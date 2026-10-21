import 'package:flutter/material.dart';

enum WorkshopCategory {
  code('Code', Icons.code),
  electronics('Electronics', Icons.memory),
  repair('Repair', Icons.handyman_outlined),
  design('Design', Icons.draw_outlined),
  craft('Craft', Icons.auto_fix_high_outlined);

  const WorkshopCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    code => scheme.primary,
    electronics => scheme.secondary,
    repair => scheme.tertiary,
    design => scheme.onPrimaryContainer,
    craft => scheme.onSecondaryContainer,
  };
}

class Workshop {
  // The private const constructor only receives immutable, owned collections.
  const Workshop._({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.limit,
    required this.place,
    required List<String> names,
    required this.online,
    required this.description,
    required this.favourite,
  }) : _names = names;

  // Copy at the boundary: changing the caller's list cannot change this model.
  factory Workshop({
    required String id,
    required String title,
    required WorkshopCategory category,
    required DateTime when,
    required int limit,
    required String place,
    List<String> names = const [],
    bool online = false,
    String? description,
    bool favourite = false,
  }) => Workshop._(
    id: id,
    title: title,
    category: category,
    when: when,
    limit: limit,
    place: place,
    names: List<String>.unmodifiable(names),
    online: online,
    description: description,
    favourite: favourite,
  );

  factory Workshop.empty() => Workshop(
    id: '',
    title: '',
    category: WorkshopCategory.code,
    when: DateTime.now().add(const Duration(days: 1)),
    limit: 12,
    place: '',
  );

  final String id;
  final String title;
  final WorkshopCategory category;
  final DateTime when;
  final int limit;
  final String place;
  final List<String> _names;
  final bool online;
  final String? description;
  final bool favourite;

  List<String> get names => _names;
  int get count => _names.length;
  int get freePlaces => (limit - count).clamp(0, limit);
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  bool contains(String name) => _names.any((entry) => entry == name);
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Workshop copyWith({
    String? id,
    String? title,
    WorkshopCategory? category,
    DateTime? when,
    int? limit,
    String? place,
    List<String>? names,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) => Workshop(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    when: when ?? this.when,
    limit: limit ?? this.limit,
    place: place ?? this.place,
    names: names ?? _names,
    online: online ?? this.online,
    description: clearDescription ? null : description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}
