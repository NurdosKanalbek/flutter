import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

enum CountdownVersion { streamBuilder, subscription }

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late final Stream<int> _stream = countdown(10);
  int _left = 10;
  late final StreamSubscription<int> _sub;
  CountdownVersion _version = CountdownVersion.subscription;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((value) => setState(() => _left = value));
  }

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Countdown')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SegmentedButton<CountdownVersion>(
            segments: const [
              ButtonSegment(
                value: CountdownVersion.streamBuilder,
                icon: Icon(Icons.widgets_outlined),
                label: Text('A · Builder'),
              ),
              ButtonSegment(
                value: CountdownVersion.subscription,
                icon: Icon(Icons.subscriptions_outlined),
                label: Text('B · Listen'),
              ),
            ],
            selected: {_version},
            onSelectionChanged: (selected) {
              setState(() => _version = selected.first);
            },
          ),
          const SizedBox(height: 32),
          Expanded(
            child: IndexedStack(
              index: _version.index,
              children: [
                _CountdownPanel(
                  label: 'Version A · StreamBuilder cancels for you',
                  child: StreamBuilder<int>(
                    stream: _stream,
                    builder: (context, snapshot) =>
                        _Count(value: snapshot.data ?? 10),
                  ),
                ),
                _CountdownPanel(
                  label: 'Version B · subscription cancelled in dispose',
                  child: _Count(value: _left),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CountdownPanel extends StatelessWidget {
  const _CountdownPanel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(height: 16),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

class _Count extends StatelessWidget {
  const _Count({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) =>
      Text('$value', style: Theme.of(context).textTheme.displayLarge);
}
