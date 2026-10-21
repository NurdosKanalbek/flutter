import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final tiles = [
        ListTile(
          dense: true,
          leading: const Icon(Icons.person_outline),
          title: const Text('Name'),
          subtitle: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        ListTile(
          dense: true,
          leading: const Icon(Icons.mail_outline),
          title: const Text('Email'),
          subtitle: Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        ListTile(
          dense: true,
          leading: const Icon(Icons.groups_outlined),
          title: const Text('Group'),
          subtitle: Text(group, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        ListTile(
          dense: true,
          leading: const Icon(Icons.calendar_month_outlined),
          title: const Text('Date of birth'),
          subtitle: Text(
            birthDate,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ];

      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: constraints.maxWidth >= 600
              ? GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  childAspectRatio: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: tiles,
                )
              : Column(mainAxisSize: MainAxisSize.min, children: tiles),
        ),
      );
    },
  );
}
