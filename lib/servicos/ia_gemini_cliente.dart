import 'dart:convert';
// import 'package:google_generative_ai/google_generative_ai.dart';
// OBS: Descomentar acima se adicionar o package 'google_generative_ai'

class IAGeminiCliente {
  static const String _apiKey = "SUA_API_KEY_AQUI";
  static const String _modeloId = "gemini-2.5-flash";

  // --- Métodos do Diagrama de Classes ---

  /// Analisa os dados gerais do rebanho e retorna insights em Markdown.
  Future<String> analisarRebanho(Map<String, dynamic> dadosRebanho) async {
    try {
      if (_apiKey == "SUA_API_KEY_AQUI") {
        return "⚠️ Configuração Pendente: Adicione sua API Key do Google Gemini no arquivo `ia_gemini_cliente.dart`.";
      }

      await Future.delayed(const Duration(seconds: 2));

      final jsonDados = jsonEncode(dadosRebanho);
      final prompt = '''
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

  /// Gera insights específicos sobre pesagens de um animal.
  Future<String> gerarInsightsPesagem(Map<String, dynamic> dadosAnimal) async {
    try {
      if (_apiKey == "SUA_API_KEY_AQUI") {
        return "⚠️ Configuração Pendente: Adicione sua API Key do Google Gemini.";
      }

      await Future.delayed(const Duration(seconds: 1));

      final brinco = dadosAnimal['brinco'] ?? 'desconhecido';
      final gmd = dadosAnimal['gmd'] ?? 0.0;
      return '''
### 📊 Insights de Pesagem — Animal $brinco

* **GMD atual**: ${gmd.toStringAsFixed(3)} kg/dia
* **Avaliação**: ${gmd >= 0.6 ? '✅ Ganho satisfatório.' : '⚠️ Ganho abaixo do esperado.'}
* **Recomendação**: ${gmd < 0.6 ? 'Revisar dieta e suplementação.' : 'Manter manejo atual.'}
      '''.trim();
    } catch (e) {
      return "Erro ao gerar insights: $e";
    }
  }

  /// Responde a uma mensagem de chat no contexto de consultoria zootécnica.
  Future<String> chatConsultor(
      String mensagem, Map<String, dynamic> contexto) async {
    try {
      if (_apiKey == "SUA_API_KEY_AQUI") {
        return "⚠️ Configuração Pendente: Adicione sua API Key do Google Gemini.";
      }

      await Future.delayed(const Duration(seconds: 1));

      return '''
🤖 **Consultor IA**: Recebi sua pergunta: *"$mensagem"*

Com base nos dados da fazenda (${contexto['nomeFazenda'] ?? 'informada'}), avaliando ${contexto['totalAnimais'] ?? 0} animais:

> Esta é uma resposta simulada. Integre a API Key real do Gemini para obter respostas precisas.
      '''.trim();
    } catch (e) {
      return "Erro no chat: $e";
    }
  }
}

