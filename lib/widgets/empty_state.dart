import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message,
    this.buttonLabel, this.onPressed});

  final IconData icon;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 48, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium),
        if (buttonLabel case final label?)
          TextButton(onPressed: onPressed, child: Text(label)),
      ]),
    ),
  );
}
