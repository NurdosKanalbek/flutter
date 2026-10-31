class Author {
  const Author({required this.name, this.country});

  final String name;
  final String? country;

  @override
  String toString() => country == null ? name : '$name ($country)';
}

enum Genre {
  craft('Craft'),
  theory('Theory'),
  unknown('Unknown');

  const Genre(this.label);

  final String label;

  static Genre fromString(String? raw) => switch (raw) {
    'craft' => Genre.craft,
    'theory' => Genre.theory,
    _ => Genre.unknown,
  };
}

abstract class LibraryItem {
  const LibraryItem({required this.title, required this.year});

  final String title;
  final int year;

  bool get isOld => DateTime.now().year - year > 20;

  String describe();
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow "$title"';
}

class Book extends LibraryItem with Borrowable {
  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    title: json['title'] as String? ?? 'Untitled',
    year: json['year'] as int? ?? 0,
    pages: json['pages'] as int? ?? 0,
    author: Author(
      name: json['author'] as String? ?? 'Unknown',
      country: json['country'] as String?,
    ),
    genre: Genre.fromString(json['genre'] as String?),
    description: json['description'] as String?,
  );

  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) => Book(
    title: title ?? this.title,
    year: year ?? this.year,
    pages: pages ?? this.pages,
    author: author ?? this.author,
    genre: genre ?? this.genre,
    description: description ?? this.description,
  );

  @override
  String describe() => '$title ($year), ${author.name}, ${genre.label}';

  @override
  String toString() =>
      'Book(title: $title, year: $year, pages: $pages, author: $author, '
      'genre: ${genre.label}, description: ${description ?? 'none'})';
}

class Magazine extends LibraryItem {
  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  final int issue;

  @override
  String describe() => '$title ($year), issue $issue';
}

class Ghost implements LibraryItem {
  const Ghost({required this.title, required this.year});

  @override
  final String title;

  @override
  final int year;

  @override
  bool get isOld => DateTime.now().year - year > 20;

  @override
  String describe() => '$title ($year), unavailable item';
}
