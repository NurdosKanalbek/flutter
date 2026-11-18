import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Text(
                user.name.isNotEmpty ? user.name[0] : '?',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              '@${user.username} (ID: ${user.id})',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Contact Info',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(user.email),
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone'),
                  subtitle: Text('${user.phone} (${user.phoneDigits})'),
                  trailing: const Icon(Icons.touch_app_outlined, size: 18),
                  onTap: () {
                    // Practice 12 gives them url_launcher
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Website'),
                  subtitle: Text(user.website ?? 'None'),
                  trailing: const Icon(Icons.touch_app_outlined, size: 18),
                  onTap: () {
                    // Practice 12 gives them url_launcher
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Address',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text('${user.address.suite}, ${user.address.street}'),
                  subtitle: Text(
                    '${user.address.city}, ${user.address.zipcode}\n'
                    'Geo: (${user.address.geo.lat}, ${user.address.geo.lng})',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Company',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.business_outlined),
                  title: Text(user.company.name),
                  subtitle: Text('"${user.company.catchPhrase}"'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
