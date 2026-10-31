import 'package:flutter/material.dart';

class TwoWayCounter extends StatefulWidget {
  const TwoWayCounter({super.key});

  @override
  State<TwoWayCounter> createState() => _TwoWayCounterState();
}

class _TwoWayCounterState extends State<TwoWayCounter> {
  int _count = 0;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _count == 0 ? null : () => setState(() => _count--),
                child: const Text('−'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$_count',
                  key: const Key('two-way-count'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton(
                onPressed: () => setState(() => _count++),
                child: const Text('+'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('save-button'),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
