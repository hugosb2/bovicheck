import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fonte central das credenciais do Consultor IA (Groq).
///
/// Precedência da chave:
///   1. Chave salva em Configurações → Consultor IA (SharedPreferences)
///   2. `GROQ_API_KEY` do `.env` (compatibilidade / builds de desenvolvimento)
///
/// A chave digitada pelo usuário fica apenas no dispositivo e nunca é
/// embutida no APK, ao contrário do `.env`.
class Configuracao {
  Configuracao._();

  static const String _prefChaveGroq = 'ia_groq_api_key';
  static const String _prefModeloGroq = 'ia_groq_modelo';

  /// Modelos de chat disponíveis na Groq (id → rótulo exibido).
  static const Map<String, String> modelosGroq = {
    'llama-3.3-70b-versatile': 'Llama 3.3 70B (recomendado)',
    'llama-3.1-8b-instant': 'Llama 3.1 8B (mais rápido)',
    'openai/gpt-oss-120b': 'GPT-OSS 120B',
    'openai/gpt-oss-20b': 'GPT-OSS 20B',
    'meta-llama/llama-4-scout-17b-16e-instruct': 'Llama 4 Scout 17B',
    'meta-llama/llama-4-maverick-17b-128e-instruct': 'Llama 4 Maverick 17B',
    'qwen/qwen3-32b': 'Qwen3 32B',
  };

  static const String modeloGroqPadrao = 'llama-3.3-70b-versatile';

  static String _chaveCache = '';
  static String _modeloCache = modeloGroqPadrao;
  static bool _origemEnv = false;

  /// Chave efetivamente em uso (pode vir das prefs ou do `.env`).
  static String get chaveGroq => _chaveCache;

  static bool get temChaveGroq => _chaveCache.trim().isNotEmpty;

  static String get modeloGroq => _modeloCache;

  /// `true` quando a chave em uso foi lida do `.env` e não salva pelo usuário.
  static bool get chaveVeioDoEnv => _origemEnv && temChaveGroq;

  /// Versão segura para exibir na UI: `gsk_••••••••a1b2`.
  static String get chaveGroqMascarada {
    if (!temChaveGroq) return '';
    final chave = _chaveCache.trim();
    if (chave.length <= 10) return '••••••';
    return '${chave.substring(0, 4)}••••••••${chave.substring(chave.length - 4)}';
  }

  /// Carrega a configuração para o cache em memória. Deve ser chamado no
  /// `main()` (após `dotenv.load`).
  static Future<void> carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salva = (prefs.getString(_prefChaveGroq) ?? '').trim();

      if (salva.isNotEmpty) {
        _chaveCache = salva;
        _origemEnv = false;
      } else {
        _chaveCache = _chaveDoEnv();
        _origemEnv = _chaveCache.isNotEmpty;
      }

      final modelo = prefs.getString(_prefModeloGroq);
      _modeloCache = (modelo != null && modelosGroq.containsKey(modelo))
          ? modelo
          : modeloGroqPadrao;
    } catch (_) {
      _chaveCache = _chaveDoEnv();
      _origemEnv = _chaveCache.isNotEmpty;
      _modeloCache = modeloGroqPadrao;
    }
  }

  /// Salva a chave digitada nas Configurações. Chave vazia remove a configuração.
  static Future<void> salvarChaveGroq(String chave) async {
    final valor = chave.trim();
    final prefs = await SharedPreferences.getInstance();
    if (valor.isEmpty) {
      await prefs.remove(_prefChaveGroq);
      _chaveCache = _chaveDoEnv();
      _origemEnv = _chaveCache.isNotEmpty;
      return;
    }
    await prefs.setString(_prefChaveGroq, valor);
    _chaveCache = valor;
    _origemEnv = false;
  }

  /// Remove a chave salva pelo usuário (volta ao `.env`, se existir).
  static Future<void> removerChaveGroq() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefChaveGroq);
    _chaveCache = _chaveDoEnv();
    _origemEnv = _chaveCache.isNotEmpty;
  }

  static Future<void> salvarModeloGroq(String modelo) async {
    if (!modelosGroq.containsKey(modelo)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefModeloGroq, modelo);
    _modeloCache = modelo;
  }

  static String _chaveDoEnv() {
    try {
      return (dotenv.env['GROQ_API_KEY'] ?? '').trim();
    } catch (_) {
      return '';
    }
  }
}
