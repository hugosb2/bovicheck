import 'package:flutter/material.dart';

class CoresApp {
  // Cores de Status Vibrantes
  static const Color sucesso = Color(0xFF00FF00); // Verde Neon
  static const Color atencao = Color(0xFFFFAB00);
  static const Color erro = Color(0xFFFF1744);
  static const Color neutro = Color(0xFF757575);

  static final Color containerSucesso = const Color(0xFF00FF00).withValues(alpha: 0.1);
  static final Color containerAtencao = const Color(0xFFFFAB00).withValues(alpha: 0.1);
  static final Color containerErro = const Color(0xFFFF1744).withValues(alpha: 0.1);

  static const Color statusAtivo = Color(0xFF00C853);
  static final Color containerStatusAtivo = const Color(0xFF00C853).withValues(alpha: 0.15);
  static const Color statusInativo = Color(0xFFD50000);
  static final Color containerStatusInativo = const Color(0xFFD50000).withValues(alpha: 0.15);

  // Paleta de Opções - Sementes Vibrantes
  static const List<Color> opcoesTema = [
    Color(0xFF2E7D32), // Verde BoviCheck (Comum e Sólido)
    Color(0xFF00FF00), // Verde Neon (Elétrico)
    Color(0xFF007BFF), // Azul Elétrico
    Color(0xFF00E5FF), // Ciano Vibrante
    Color(0xFFFF9100), // Laranja Intenso
    Color(0xFFFF1744), // Vermelho Puro
    Color(0xFFD500F9), // Roxo Neon
    Color(0xFF3D5AFE), // Indigo Forte
  ];

  // Definindo o Verde Comum como a cor principal padrão
  static const Color corPadrao = Color(0xFF2E7D32); 
}
