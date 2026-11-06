import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

void main() => runApp(const StudentsAsyncApp());

class StudentsAsyncApp extends StatelessWidget {
  const StudentsAsyncApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Students Async',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _manualApi = FakeApi();
  final _futureApi = FakeApi();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('The data arrives later')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Students arrive asynchronously',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Compare manual state, FutureBuilder, and two stream subscriptions.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StudentsScreen(api: _manualApi),
                  ),
                ),
                icon: const Icon(Icons.tune),
                label: const Text('By hand'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StudentsFutureScreen(api: _futureApi),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('FutureBuilder'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CountdownScreen(),
                  ),
                ),
                icon: const Icon(Icons.timer_outlined),
                label: const Text('Countdown'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
