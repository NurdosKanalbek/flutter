import 'package:flutter/material.dart';

import 'models/profile.dart';
import 'models/workshop.dart';
import 'screens/detail_screen.dart';
import 'screens/workshop_form_screen.dart';

enum AppTab { explore, favourites, profile }

abstract final class Routes {
  static const shell = '/';
  static const detail = '/workshop';
  static const form = '/workshop/form';

  static Route<dynamic>? generate(RouteSettings settings) =>
      switch ((settings.name, settings.arguments)) {
        (detail, DetailArguments arguments) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => DetailScreen(arguments: arguments),
        ),
        (form, FormArguments arguments) => MaterialPageRoute<Workshop>(
          settings: settings,
          builder: (_) => WorkshopFormScreen(workshop: arguments.workshop),
        ),
        _ => null,
      };

  static Route<void> unknown(RouteSettings settings) => MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}

class DetailArguments {
  const DetailArguments({
    required this.workshop,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onSelectTab,
  });
  final Workshop workshop;
  final Profile profile;
  final ValueChanged<Workshop> onChanged;
  final ValueChanged<String> onDelete;
  final ValueChanged<AppTab> onSelectTab;
}

class FormArguments {
  const FormArguments({this.workshop});
  final Workshop? workshop;
}
