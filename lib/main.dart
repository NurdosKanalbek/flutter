import 'package:flutter/material.dart';
import 'routes.dart';
import 'screens/shell_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: ThemeData().colorScheme.primary, brightness: brightness);
    return ThemeData(colorScheme: scheme, useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      appBarTheme: AppBarTheme(backgroundColor: scheme.surfaceContainerLow));
  }
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Campus Makers', debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light), darkTheme: _theme(Brightness.dark), themeMode: _themeMode,
    routes: {Routes.shell: (_) => ShellScreen(themeMode: _themeMode,
      onThemeChanged: (mode) => setState(() => _themeMode = mode))},
    onGenerateRoute: Routes.generate, onUnknownRoute: Routes.unknown,
  );
}
