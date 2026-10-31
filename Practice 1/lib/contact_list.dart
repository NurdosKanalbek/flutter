import 'package:flutter/material.dart';

import 'contact_card.dart';
import 'contacts.dart';

class ContactList extends StatelessWidget {
  const ContactList({this.badgeBehindAvatar = false, super.key});

  // Used by the golden test for the required swapped-Stack screenshot.
  final bool badgeBehindAvatar;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(
          '${contacts.length} contacts',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: contacts.length,
          itemBuilder: (context, index) => ContactCard(
            contact: contacts[index],
            badgeBehindAvatar: badgeBehindAvatar,
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
    ],
  );
}
