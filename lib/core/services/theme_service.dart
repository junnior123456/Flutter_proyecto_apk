import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _themeKey = 'user_theme_preference';
  static const String _colorKey = 'user_color_preference';
  static const String _darkModeKey = 'user_dark_mode';

  /// 🎨 Colores predefinidos disponibles
  static const Map<String, FlexScheme> availableColors = {
    'orange': FlexScheme.amber,
    'blue': FlexScheme.blue,
    'green': FlexScheme.green,
    'purple': FlexScheme.deepPurple,
    'red': FlexScheme.red,
    'pink': FlexScheme.sakura,
    'teal': FlexScheme.aquaBlue,
    'amber': FlexScheme.amber,
  };

  /// 💾 Guardar preferencia de color
  Future<void> saveColorPreference(String colorName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorKey, colorName);
  }

  /// 📖 Obtener preferencia de color
  Future<String> getColorPreference() async {
    final prefs = await SharedPreferences.getInstance();
    // Forzar naranja siempre para PawFinder
    await prefs.setString(_colorKey, 'orange');
    return 'orange';
  }

  /// 🌙 Guardar preferencia de modo oscuro
  Future<void> saveDarkModePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }

  /// 🌞 Obtener preferencia de modo oscuro
  Future<bool> getDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false; // Default: modo claro
  }

  /// 🎨 Generar tema claro
  Future<ThemeData> getLightTheme() async {
    final colorName = await getColorPreference();
    final flexScheme = availableColors[colorName] ?? FlexScheme.material;
    
    return FlexThemeData.light(
      scheme: flexScheme,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );
  }

  /// 🌙 Generar tema oscuro
  Future<ThemeData> getDarkTheme() async {
    final colorName = await getColorPreference();
    final flexScheme = availableColors[colorName] ?? FlexScheme.material;
    
    return FlexThemeData.dark(
      scheme: flexScheme,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );
  }

  /// 🔄 Obtener modo de tema actual
  Future<ThemeMode> getThemeMode() async {
    final isDark = await getDarkModePreference();
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// 🎨 Obtener color primario actual
  Future<Color> getPrimaryColor() async {
    final colorName = await getColorPreference();
    final flexScheme = availableColors[colorName] ?? FlexScheme.material;
    final theme = FlexThemeData.light(scheme: flexScheme);
    return theme.primaryColor;
  }

  /// 📋 Obtener lista de colores disponibles con nombres amigables
  Map<String, String> getColorNames() {
    return {
      'orange': '🧡 Naranja',
      'blue': '💙 Azul',
      'green': '💚 Verde',
      'purple': '💜 Morado',
      'red': '❤️ Rojo',
      'pink': '🩷 Rosa',
      'teal': '💎 Turquesa',
      'amber': '🟡 Ámbar',
    };
  }
}