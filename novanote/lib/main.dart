import 'package:flutter/material.dart';
import 'package:novanote/screens/category_screen.dart';
import 'package:novanote/screens/note_list_screen.dart';
import 'package:novanote/screens/setting_screen.dart';
import 'package:novanote/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final darkMode = prefs.getBool('darkMode') ?? false;

  runApp(MyApp(darkMode: darkMode));
}

class MyApp extends StatelessWidget {
  final bool darkMode;

  const MyApp({super.key, required this.darkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaNote',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const NoteListScreen(),
        '/settings': (context) => SettingsScreen(),
        '/categories': (context) => const CategoryScreen(),
      },
    );
  }
}
