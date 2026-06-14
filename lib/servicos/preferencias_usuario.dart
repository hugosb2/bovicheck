import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Representa as preferências do usuário conforme o diagrama de classes.
class PreferenciasUsuario {
  final String id;
  final String temaApp; // 'light', 'dark' ou 'system'
  final String corDestaque;
  final bool notificacoesAtivas;
  final bool lembrarSenha;
  final String idioma;

  static const _keyTema = 'tema_app_v2';
  static const _keyUltimaFazenda = 'ultima_fazenda_id';

  PreferenciasUsuario({
    String? id,
    this.temaApp = 'system',
    this.corDestaque = '#4CAF50',
    this.notificacoesAtivas = true,
    this.lembrarSenha = false,
    this.idioma = 'pt_BR',
  }) : id = id ?? 'default';

  // --- Métodos do Diagrama de Classes ---

  /// Salva as configurações do usuário no armazenamento local.
  Future<void> salvarConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = temaApp == 'light'
        ? ThemeMode.light.index
        : temaApp == 'dark'
            ? ThemeMode.dark.index
            : ThemeMode.system.index;
    await prefs.setInt(_keyTema, modeIndex);
    await prefs.setString('cor_destaque', corDestaque);
    await prefs.setBool('notificacoes', notificacoesAtivas);
    await prefs.setBool('lembrar_senha', lembrarSenha);
    await prefs.setString('idioma', idioma);
  }

  /// Carrega as configurações salvas do armazenamento local.
  static Future<PreferenciasUsuario> carregarConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_keyTema) ?? ThemeMode.system.index;
    String temaString = 'system';
    if (modeIndex == ThemeMode.light.index) temaString = 'light';
    if (modeIndex == ThemeMode.dark.index) temaString = 'dark';

    return PreferenciasUsuario(
      temaApp: temaString,
      corDestaque: prefs.getString('cor_destaque') ?? '#4CAF50',
      notificacoesAtivas: prefs.getBool('notificacoes') ?? true,
      lembrarSenha: prefs.getBool('lembrar_senha') ?? false,
      idioma: prefs.getString('idioma') ?? 'pt_BR',
    );
  }

  /// Retorna as preferências padrão do aplicativo.
  static PreferenciasUsuario getDefault() {
    return PreferenciasUsuario();
  }

  // --- Métodos auxiliares mantidos para compatibilidade ---

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

  /// Converte o temaApp string para ThemeMode do Flutter.
  ThemeMode get themeMode {
    switch (temaApp) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

