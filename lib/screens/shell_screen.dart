import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/profile.dart';
import '../models/workshop.dart';
import '../routes.dart';
import 'profile_tab.dart';
import 'workshop_list_tab.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  List<Workshop> _workshops = seedWorkshops();
  Profile _profile = const Profile.empty();
  AppTab _tab = AppTab.explore;
  int _resetVersion = 0;

  void _selectTab(AppTab tab) => setState(() => _tab = tab);
  void _update(Workshop workshop) => setState(() {
    _workshops = _workshops
        .map((current) => current.id == workshop.id ? workshop : current)
        .toList();
  });
  void _toggleFavourite(Workshop workshop) =>
      _update(workshop.copyWith(favourite: workshop.favourite == false));
  void _delete(String id) => setState(() {
    _workshops = _workshops.where((workshop) => workshop.id != id).toList();
  });
  void _open(Workshop workshop) {
    Navigator.of(context).pushNamed<void>(
      Routes.detail,
      arguments: DetailArguments(
        workshop: workshop,
        profile: _profile,
        onChanged: _update,
        onDelete: _delete,
        onSelectTab: _selectTab,
      ),
    );
  }

  Future<void> _create() async {
    final workshop = await Navigator.of(context)
        .pushNamed<Workshop>(Routes.form, arguments: const FormArguments());
    if (mounted == false) return;
    if (workshop == null) return;
    setState(() {
      _workshops = [..._workshops, workshop];
      _tab = AppTab.explore;
    });
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'Restore all twelve workshops and clear your profile?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (mounted == false) return;
    if (confirmed != true) return;
    final restored = seedWorkshops();
    setState(() {
      _workshops = restored;
      _profile = const Profile.empty();
      _resetVersion += 1;
      _tab = AppTab.explore;
    });
  }

  void _about() => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Campus Makers'),
      content: const Text(
        'Small workshops. Shared skills.\n\nAn in-memory campus workshop club built with Flutter. No accounts, network or storage.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(switch (_tab) {
        AppTab.explore => 'Campus Makers',
        AppTab.favourites => 'Favourites',
        AppTab.profile => 'Profile',
      }),
    ),
    drawer: Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.handyman_outlined, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Campus Makers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text('Learn it. Make it. Share it.'),
                ],
              ),
            ),
            ListTile(
              title: const Text('About'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                Navigator.pop(context);
                _about();
              },
            ),
            ListTile(
              title: const Text('Reset data'),
              trailing: const Icon(Icons.restart_alt),
              onTap: () {
                Navigator.pop(context);
                _reset();
              },
            ),
          ],
        ),
      ),
    ),
    body: SafeArea(
      child: IndexedStack(
        index: _tab.index,
        children: [
          WorkshopListTab(
            key: ValueKey('explore-$_resetVersion'),
            workshops: _workshops,
            onOpen: _open,
            onFavourite: _toggleFavourite,
            onBrowse: () => _selectTab(AppTab.explore),
          ),
          WorkshopListTab(
            key: ValueKey('favourites-$_resetVersion'),
            workshops: _workshops,
            favouritesOnly: true,
            onOpen: _open,
            onFavourite: _toggleFavourite,
            onBrowse: () => _selectTab(AppTab.explore),
          ),
          ProfileTab(
            key: ValueKey('profile-$_resetVersion'),
            profile: _profile,
            workshops: _workshops,
            onChanged: (profile) => setState(() => _profile = profile),
            themeMode: widget.themeMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
    ),
    floatingActionButton: _tab == AppTab.profile
        ? null
        : FloatingActionButton.extended(
            onPressed: _create,
            icon: const Icon(Icons.add),
            label: const Text('New workshop'),
          ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab.index,
      onDestinationSelected: (index) => _selectTab(AppTab.values[index]),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favourites',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}
