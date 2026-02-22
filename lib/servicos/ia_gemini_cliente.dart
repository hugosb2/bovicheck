import 'dart:convert';
// import 'package:google_generative_ai/google_generative_ai.dart';
// OBS: Descomentar acima se adicionar o package 'google_generative_ai'

class IAGeminiCliente {
  static const String _apiKey = "SUA_API_KEY_AQUI";
  static const String _modelo = "gemini-1.5-flash";

  Future<String> analisarRebanho(Map<String, dynamic> dadosRebanho) async {
    try {
      if (_apiKey == "SUA_API_KEY_AQUI") {
        return "⚠️ Configuração Pendente: Adicione sua API Key do Google Gemini no arquivo `ia_gemini_cliente.dart`.";
      }

      await Future.delayed(const Duration(seconds: 2));

      final jsonDados = jsonEncode(dadosRebanho);
      final prompt =
          '''
        Atue como um veterinário e consultor zootécnico especialista.
        Analise os seguintes dados brutos de uma fazenda de gado:
        $jsonDados
        
        Forneça um relatório conciso em Markdown com:
        1. **Diagnóstico Geral**: Situação atual do rebanho.
        2. **Pontos de Atenção**: Índices que estão ruins (ex: alta mortalidade, baixo ganho de peso).
        3. **Recomendações Práticas**: 3 ações imediatas para o produtor.
        
        Seja direto e use emojis para facilitar a leitura.
      ''';

      return '''
### 🩺 Diagnóstico Veterinário IA

Baseado nos dados fornecidos (${dadosRebanho['totalAnimais']} animais), o rebanho apresenta estabilidade, mas requer atenção em alguns índices reprodutivos.

### ⚠️ Pontos de Atenção
* **Natalidade**: Abaixo do ideal para a região.
* **Sanidade**: Foram registrados ${dadosRebanho['animaisDoentes'] ?? 0} casos recentes que exigem monitoramento.

### ✅ Recomendações
1.  🥩 **Suplementação**: Reforçar proteinado no cocho para o Lote de Engorda.
2.  💉 **Vacinação**: Revisar calendário de Clostridiose.
3.  📊 **Dados**: Aumentar a frequência de pesagens para melhorar a precisão do GMD.
      ''';
    } catch (e) {
      return "Erro ao conectar com a IA: $e. Verifique sua conexão.";
    }
  }
}
