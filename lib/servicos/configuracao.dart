import 'package:flutter_dotenv/flutter_dotenv.dart';

class Configuracao {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static bool get temApiKey => geminiApiKey.isNotEmpty;
}
