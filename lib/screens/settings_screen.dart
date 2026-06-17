import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (value) {
              settings.toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Default Difficulty'),
            trailing: DropdownButton<String>(
              value: settings.difficulty,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  settings.setDifficulty(newValue);
                }
              },
              items: <String>['Easy', 'Medium', 'Hard']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}