import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/workshop.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.profile, required this.workshops,
    required this.onChanged, required this.themeMode, required this.onThemeChanged});

  final Profile profile;
  final List<Workshop> workshops;
  final ValueChanged<Profile> onChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _group = TextEditingController();
  final _groupFocus = FocusNode();
  static final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{4}$');

  @override
  void initState() {
    super.initState();
    _name.text = widget.profile.name;
    _group.text = widget.profile.group;
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.name != oldWidget.profile.name) _name.text = widget.profile.name;
    if (widget.profile.group != oldWidget.profile.group) _group.text = widget.profile.group;
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onChanged(widget.profile.copyWith(
      name: _name.text.trim(), group: _group.text.trim()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = widget.profile.name.isEmpty ? 0 : widget.workshops
      .where((workshop) => workshop.contains(widget.profile.name)).length;
    return SingleChildScrollView(padding: const EdgeInsets.all(20),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const CircleAvatar(radius: 36, child: Icon(Icons.person_outline, size: 36)),
          const SizedBox(height: 16),
          Text('Your maker profile', textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('You are on $count lists', textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          Form(key: _formKey, autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(children: [
              TextFormField(controller: _name,
                decoration: const InputDecoration(labelText: 'Name',
                  helperText: 'Used when you join a workshop'),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) => (value ?? '').trim().length < 2
                  ? 'Enter at least 2 characters' : null,
                onFieldSubmitted: (_) { _save(); _groupFocus.requestFocus(); },
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus()),
              const SizedBox(height: 16),
              TextFormField(controller: _group, focusNode: _groupFocus,
                decoration: const InputDecoration(labelText: 'Group', hintText: 'IT-2301',
                  helperText: '2–4 capital letters, a dash, then 4 digits'),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                validator: (value) => _groupPattern.hasMatch((value ?? '').trim())
                  ? null : 'Use a group such as IT-2301',
                onFieldSubmitted: (_) => _save(),
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus()),
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: _save, icon: const Icon(Icons.check),
                label: const Text('Save profile')),
            ])),
          const SizedBox(height: 28),
          Text('Appearance', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(label: Text(switch (mode) {
                ThemeMode.system => 'System', ThemeMode.light => 'Light', ThemeMode.dark => 'Dark',
              }), selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeChanged(mode)),
          ]),
          const SizedBox(height: 20),
          const Text('This practice keeps everything in memory. Closing the app restores the seed data.'),
        ])))),
    );
  }
}
