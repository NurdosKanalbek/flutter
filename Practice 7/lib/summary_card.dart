import 'package:flutter/material.dart';

/// Level 5: Summary widget in its own file.
/// StatelessWidget with a const constructor and final named fields.
/// Adapts layout via LayoutBuilder — asks about its own box, not the screen.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  final String name;
  final String email;
  final String group;
  final String birthDate;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Name'),
        subtitle: Text(name),
      ),
      ListTile(
        leading: const Icon(Icons.email),
        title: const Text('Email'),
        subtitle: Text(email),
      ),
      ListTile(
        leading: const Icon(Icons.group),
        title: const Text('Group'),
        subtitle: Text(group),
      ),
      ListTile(
        leading: const Icon(Icons.cake),
        title: const Text('Date of birth'),
        subtitle: Text(birthDate),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Level 5: LayoutBuilder checks card's own width, not screen width
            if (constraints.maxWidth >= 600) {
              // Tablet / wide: two-column grid
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: 4,
                physics: const NeverScrollableScrollPhysics(),
                children: tiles,
              );
            }
            // Phone / narrow: single column
            return Column(children: tiles);
          },
        ),
      ),
    );
  }
}
