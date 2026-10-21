import 'dart:async';
import 'package:flutter/material.dart';
import '../models/countdown.dart';
import '../models/workshop.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.arguments});
  final DetailArguments arguments;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Workshop _workshop;
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _workshop = widget.arguments.workshop;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _replace(Workshop workshop) {
    widget.arguments.onChanged(workshop);
    setState(() => _workshop = workshop);
  }

  void _goToProfile() {
    Navigator.pop(context);
    widget.arguments.onSelectTab(AppTab.profile);
  }

  Future<void> _membership() async {
    final name = widget.arguments.profile.name;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Add your name in Profile before joining.'),
        action: SnackBarAction(label: 'Profile', onPressed: _goToProfile)));
      return;
    }
    final joined = _workshop.contains(name);
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) =>
      AlertDialog(title: Text(joined ? 'Leave this workshop?' : 'Join this workshop?'),
        content: Text(joined ? 'Remove $name from ${_workshop.title}?'
          : 'Reserve one place for $name at ${_workshop.title}?'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(joined ? 'Leave' : 'Join'))]));
    if (mounted == false) return;
    if (confirmed != true) return;
    final names = joined
      ? _workshop.names.where((entry) => entry != name).toList()
      : [..._workshop.names, name];
    _replace(_workshop.copyWith(names: names));
  }

  Future<void> _edit() async {
    final workshop = await Navigator.of(context).pushNamed<Workshop>(Routes.form,
      arguments: FormArguments(workshop: _workshop));
    if (mounted == false) return;
    if (workshop == null) return;
    _replace(workshop);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) =>
      AlertDialog(title: const Text('Delete workshop?'), content: Text(_workshop.title),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'))]));
    if (mounted == false) return;
    if (confirmed != true) return;
    widget.arguments.onDelete(_workshop.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (:taken, :free) = _workshop.places;
    final joined = _workshop.contains(widget.arguments.profile.name);
    final countdown = Countdown.at(_workshop.when, _now);
    final actionDisabled = joined == false && (_workshop.isFull || _workshop.isPast);
    final names = _workshop.names;
    return DefaultTabController(length: 2, child: Scaffold(
      appBar: AppBar(title: const Text('Workshop'), actions: [
        PopupMenuButton<_MenuAction>(tooltip: 'Workshop menu',
          onSelected: (action) { switch (action) {
            case _MenuAction.edit: _edit();
            case _MenuAction.delete: _delete();
          } },
          itemBuilder: (_) => const [
            PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
            PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
          ]),
      ]),
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: 156, child: Stack(fit: StackFit.expand, children: [
          Image.asset('assets/maker_banner.png', fit: BoxFit.cover),
          ColoredBox(color: scheme.surface.withValues(alpha: 0.6)),
          Center(child: Icon(_workshop.category.icon, size: 64,
            color: _workshop.category.color(scheme))),
          Positioned(left: 12, top: 8, child: Chip(label: Text(_workshop.category.label))),
          Positioned(right: 12, bottom: 8, child: Chip(label: Text(countdown.label))),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(_workshop.title, maxLines: 3, overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge)),
        TabBar(tabs: [const Tab(text: 'About'), Tab(text: 'Makers ($taken)')]),
        Expanded(child: TabBarView(children: [
          SingleChildScrollView(padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              ListTile(contentPadding: EdgeInsets.zero, title: const Text('Date & time'),
                subtitle: Text(formatWhen(_workshop.when)), trailing: const Icon(Icons.schedule)),
              ListTile(contentPadding: EdgeInsets.zero,
                title: Text(_workshop.online ? 'Meeting link' : 'Place'),
                subtitle: Text(_workshop.place), trailing: Icon(_workshop.online ? Icons.link : Icons.place_outlined)),
              ListTile(contentPadding: EdgeInsets.zero, title: Text('$taken of ${_workshop.limit} places taken'),
                subtitle: Text('$free free places'), trailing: const Icon(Icons.groups_outlined)),
              if (_workshop.description case final description?) ...[
                const SizedBox(height: 12), Text(description, style: theme.textTheme.bodyLarge),
              ],
            ])),
          names.isEmpty ? const EmptyState(icon: Icons.groups_outlined,
            message: 'Nobody on the list yet. Be the first maker.')
            : ListView.builder(padding: const EdgeInsets.all(12), itemCount: names.length,
                itemBuilder: (_, index) {
                  final isYou = names[index] == widget.arguments.profile.name;
                  return Card(color: isYou ? scheme.primaryContainer : null,
                    child: ListTile(title: Text(names[index]),
                      subtitle: isYou ? const Text('You') : null,
                      trailing: isYou ? const Icon(Icons.person) : null));
                }),
        ])),
        Padding(padding: const EdgeInsets.all(16),
          child: FilledButton.icon(onPressed: actionDisabled ? null : _membership,
            icon: Icon(joined ? Icons.person_remove_outlined : Icons.person_add_outlined),
            label: Text(joined ? 'Leave workshop' : _workshop.isPast
              ? 'Workshop ended' : _workshop.isFull ? 'Workshop full' : 'Join workshop'))),
      ])),
    ));
  }
}
