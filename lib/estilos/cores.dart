import 'package:flutter/material.dart';

class CoresApp {
  static const Color sucesso = Color(0xFF2E7D32);
  static const Color atencao = Color(0xFFE65100);
  static const Color erro = Color(0xFFC62828);
  static const Color neutro = Color(0xFF757575);

  static final Color containerSucesso = const Color(0xFF2E7D32).withValues(alpha: 0.12);
  static final Color containerAtencao = const Color(0xFFE65100).withValues(alpha: 0.12);
  static final Color containerErro = const Color(0xFFC62828).withValues(alpha: 0.12);

  static const Color statusAtivo = Color(0xFF2E7D32);
  static final Color containerStatusAtivo = const Color(0xFF2E7D32).withValues(alpha: 0.15);
  static const Color statusInativo = Color(0xFFC62828);
  static final Color containerStatusInativo = const Color(0xFFC62828).withValues(alpha: 0.15);

  static const List<Color> opcoesTema = [
    Color(0xFF2E7D32), // Verde floresta (padrão)
    Color(0xFF33691E), // Verde oliva
    Color(0xFF00695C), // Verde petrório
    Color(0xFF4E342E), // Marrom terra
    Color(0xFFFF6F00), // Laranja cenoura
    Color(0xFF1565C0), // Azul fazenda
    Color(0xFF6A1B9A), // Roxo campo
    Color(0xFFBF360C), // Terracota
  ];

  static const Color corPadrao = Color(0xFF2E7D32);
}
