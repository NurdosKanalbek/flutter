import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/api/api_exception.dart';
import 'features/users/user.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

Future<void> _runPreflightChecks(UserRepository repo) async {
  // Level 2 verification: fromJson on real user 1 wire JSON
  const rawUser1 = r'''{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}''';
  final user1 = User.fromJson(jsonDecode(rawUser1) as Map<String, dynamic>);
  debugPrint('Level 2 parsed user: $user1');

  // Level 3 verification:
  // 1. getAll() prints 10 names
  final users = await repo.getAll();
  debugPrint(
    'Level 3 getAll (${users.length} users): ${users.map((u) => u.name).join(', ')}',
  );

  // 2. getById(999) throws NotFoundException -> catch with on NotFoundException and print "not found"
  try {
    await repo.getById(999);
  } on NotFoundException {
    debugPrint('not found');
  }

  // 3. create(...) prints the id the server assigned (11)
  final created = await repo.create(
    User(
      id: 0,
      name: 'Created Draft',
      username: 'draft',
      email: 'draft@example.com',
      phone: '123-456-7890',
      website: 'example.com',
      address: user1.address,
      company: user1.company,
    ),
  );
  debugPrint('Level 3 create assigned id: ${created.id}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = UserRepository(ApiClient(http.Client()));

  if (kDebugMode) {
    try {
      await _runPreflightChecks(repository);
    } catch (e) {
      debugPrint('Preflight check error: $e');
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => UsersModel(repository)..load(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const UsersScreen(),
    );
  }
}
