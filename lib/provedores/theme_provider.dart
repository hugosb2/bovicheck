import 'package:bovicheck/estilos/app_colors.dart'; // IMPORTADO
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _useDynamicColorsKey = 'use_dynamic_colors';
  static const String _selectedColorKey = 'selected_color';

  static const Color _defaultColor = AppColors.defaultThemeColor;

  ThemeMode _themeMode = ThemeMode.system;
  bool _useDynamicColors = true;
  Color _selectedColor = _defaultColor;

  ThemeMode get themeMode => _themeMode;
  bool get useDynamicColors => _useDynamicColors;
  Color get selectedColor => _selectedColor;

  ThemeProvider();

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _savePreferences();
    notifyListeners();
  }

  void setUseDynamicColors(bool value) {
    if (_useDynamicColors == value) return;
    _useDynamicColors = value;
    _savePreferences();
    notifyListeners();
  }

  void setSelectedColor(Color color) {
    if (_selectedColor == color) return;
    _selectedColor = color;
    _savePreferences();
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_themeModeKey, _themeMode.index);
    prefs.setBool(_useDynamicColorsKey, _useDynamicColors);
    prefs.setInt(_selectedColorKey, _selectedColor.toARGB32());
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];

    _useDynamicColors = prefs.getBool(_useDynamicColorsKey) ?? true;

    final colorValue = prefs.getInt(_selectedColorKey) ?? _defaultColor.toARGB32();
    _selectedColor = Color(colorValue);
  }

  Map<String, dynamic> toMap() {
    return {
      'theme_mode': _themeMode.index,
      'use_dynamic_colors': _useDynamicColors,
      'selected_color': _selectedColor.toARGB32(),
    };
  }

  Future<void> fromMap(Map<String, dynamic> map) async {
    _themeMode = ThemeMode.values[map['theme_mode'] ?? ThemeMode.system.index];
    _useDynamicColors = map['use_dynamic_colors'] ?? true;
    _selectedColor = Color(map['selected_color'] ?? _defaultColor.toARGB32());
    await _savePreferences();
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _useDynamicColors = true;
    _selectedColor = _defaultColor;
    await _savePreferences();
    notifyListeners();
  }
}
