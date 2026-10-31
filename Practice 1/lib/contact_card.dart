import 'package:flutter/material.dart';

import 'contacts.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    required this.contact,
    this.badgeBehindAvatar = false,
    super.key,
  });

  final Contact contact;

  // Used only to reproduce and capture the Level 4 depth-order experiment.
  final bool badgeBehindAvatar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatar = CircleAvatar(child: Text(contact.initial));
    final badge = Positioned(
      right: -2,
      bottom: -2,
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.error,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.surface, width: 2),
        ),
        child: Text(
          '${contact.unread}',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: colorScheme.onError),
        ),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        // Without Expanded, the 390 px test viewport overflowed by 606 pixels.
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: badgeBehindAvatar
                  ? [if (contact.unread > 0) badge, avatar]
                  : [avatar, if (contact.unread > 0) badge],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
