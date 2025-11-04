import 'package:flutter/material.dart';
import 'theme_service.dart';

class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  final ThemeService _themeService = ThemeService();
  
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeData? get lightTheme => _lightTheme;
  ThemeData? get darkTheme => _darkTheme;
  ThemeMode get themeMode => _themeMode;

  Future<void> loadTheme() async {
    _lightTheme = await _themeService.getLightTheme();
    _darkTheme = await _themeService.getDarkTheme();
    _themeMode = await _themeService.getThemeMode();
    notifyListeners();
  }

  Future<void> updateTheme() async {
    await loadTheme();
  }
}