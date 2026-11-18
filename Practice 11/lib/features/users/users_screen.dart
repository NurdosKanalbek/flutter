import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'error_views.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UserList extends StatelessWidget {
  const UserList(this.items, {super.key});

  final List<User> items;

  @override
  Widget build(BuildContext context) {
    final m = context.read<UsersModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: m.load,
        child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No users found.')),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = items[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name.isNotEmpty ? user.name[0] : '?'),
                    ),
                    title: Text(user.name),
                    subtitle: Text('${user.email} • ${user.address.city}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => UserDetailScreen(user: user),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    if (m.loading) return const LoadingView();

    return switch (m.error) {
      null => UserList(m.items),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => ClientError(
        message: m.error is NotFoundException
            ? 'Users not found (404)'
            : 'Unauthorized request (401)',
        onRetry: m.load,
      ),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException() => const GenericError(),
    };
  }
}
