import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static const String route = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: isDarkModeEnabled,
            onChanged: (value) {
              setState(() {
                isDarkModeEnabled = value;
                // Здесь вы можете применить изменения темы
              });
            },
          ),
        ],
      ),
    );
  }
}