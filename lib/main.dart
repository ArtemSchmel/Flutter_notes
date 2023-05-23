import 'package:flutter/material.dart';
import 'package:notes_app/helper/note_provider.dart';
import 'package:notes_app/screens/note_edit_screen.dart';
import 'package:notes_app/screens/note_view_screen.dart';
import 'package:notes_app/screens/settings_screen.dart';
import 'package:notes_app/screens/note_list_screen.dart';
import 'package:notes_app/utils/constants.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NoteProvider>(
      create: (_) => NoteProvider(),
      child: MaterialApp(
        title: "Flutter Notes",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.light().copyWith(
            background: Color.fromRGBO(238, 255, 212, 1), // Задайте желаемый цвет фона для светлой темы
            secondary: Color.fromRGBO(51, 85, 0, 1),
            primary: Color.fromRGBO(187, 255, 84, 1),
            onPrimary: Color.fromRGBO(51, 85, 0, 1),
            onBackground: black,
            surface: white,
            // Другие цвета для светлой темы
          ),
          // Другие настройки темы
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark().copyWith(
            background: Color.fromRGBO(61, 61, 61, 1), // Задайте желаемый цвет фона для тёмной темы
            // Другие цвета для тёмной темы
          ),
          // Другие настройки тёмной темы
        ),
        themeMode: ThemeMode.light, // Автоматическое определение темы системой
        initialRoute: '/',
        routes: {
          '/': (context) => const NoteListScreen(),
          NoteViewScreen.route: (context) => NoteViewScreen(),
          NoteEditScreen.route: (context) => NoteEditScreen(),
          SettingsScreen.route: (context) => SettingsScreen(),
        },
      ),
    );
  }
}