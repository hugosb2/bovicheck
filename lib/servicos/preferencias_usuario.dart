import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  static const _keyTema = 'tema_app_v2';
  static const _keyCor = 'cor_app_v2';
  static const _keyUltimaFazenda = 'ultima_fazenda_id';

  Future<void> salvarTemaMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTema, mode.index);
  }

  Future<ThemeMode> carregarTemaMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyTema) ?? 0;
    return ThemeMode.values[index];
  }

  Future<void> salvarCorSemente(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCor, colorValue);
  }

  Future<int?> carregarCorSemente() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCor);
  }

  Future<void> salvarUltimaFazenda(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUltimaFazenda, id);
  }

  Future<String?> carregarUltimaFazenda() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUltimaFazenda);
  }

  Future<void> limparPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
