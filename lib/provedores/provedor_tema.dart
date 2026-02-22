import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../estilos/cores.dart';

class ProvedorTema extends ChangeNotifier {
  static const String _chaveModoTema = 'tema_modo';
  static const String _chaveCorSemente = 'tema_cor';

  ThemeMode _modoTema = ThemeMode.system;
  Color _corSemente = CoresApp.corPadrao;

  ThemeMode get modoTema => _modoTema;
  Color get corSemente => _corSemente;

  ProvedorTema() {
    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();

    // Carrega Modo (0=System, 1=Light, 2=Dark)
    final modoIndex = prefs.getInt(_chaveModoTema) ?? 0;
    _modoTema = ThemeMode.values[modoIndex];

    // Carrega Cor
    final corInt = prefs.getInt(_chaveCorSemente);
    if (corInt != null) {
      _corSemente = Color(corInt);
    }

    notifyListeners();
  }

  Future<void> alterarModoTema(ThemeMode novoModo) async {
    if (_modoTema == novoModo) return;

    _modoTema = novoModo;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveModoTema, novoModo.index);
  }

  Future<void> alterarCorSemente(Color novaCor) async {
    if (_corSemente == novaCor) return;

    _corSemente = novaCor;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveCorSemente, novaCor.value);
  }
}
