import 'package:flutter/material.dart';

class TapCard extends StatefulWidget {
  const TapCard({super.key});

  @override
  State<TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<TapCard> {
  int _taps = 0;

  Future<void> _askToReset() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset the count?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (!mounted || shouldReset != true) {
      return;
    }
    setState(() => _taps = 0);
  }

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: () => setState(() => _taps++),
      onLongPress: _askToReset,
      child: ListTile(
        title: const Text('Tap this card'),
        trailing: Text('$_taps', key: const Key('tap-count')),
      ),
    ),
  );
}
