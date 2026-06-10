import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _difficulty = 'Medium';

  bool get isDarkMode => _isDarkMode;
  String get difficulty => _difficulty;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _difficulty = prefs.getString('difficulty') ?? 'Medium';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setDifficulty(String newDifficulty) async {
    _difficulty = newDifficulty;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty', _difficulty);
    notifyListeners();
  }
}