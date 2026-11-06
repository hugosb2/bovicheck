import 'dart:convert';
import 'package:http/http.dart' as http;
import 'configuracao.dart';
import 'rag/rag_servico.dart';
import 'rag/modelo_documento.dart';

class ResultadoIA {
  final String texto;
  final List<DocumentoRAG> fontes;
  final List<ResultadoRetrieval> retrievals;
  final bool usouRAG;
  final bool usouGroq;
  final String? modeloUsado;
  final String? erro;

  ResultadoIA({
    required this.texto,
    required this.fontes,
    required this.retrievals,
    required this.usouRAG,
    required this.usouGroq,
    this.modeloUsado,
    this.erro,
  });
}

/// Cliente da Groq (API compatível com OpenAI Chat Completions).
///
/// Fluxo: retrieval local (TF-IDF) → prompt aumentado → LLM na nuvem.
/// Sem chave configurada (ou em falha de rede/quota) usa fallback 100% offline.
class IAGroqCliente {
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _sistema =
      'Você é um assistente técnico de pecuária bovina. Siga rigorosamente as '
      'instruções da mensagem do usuário, responda em Markdown e nunca invente '
      'dados que não estejam no contexto fornecido.';

  final RAGService _ragService;

  IAGroqCliente({RAGService? ragService})
      : _ragService = ragService ?? RAGService();

  /// Mantém compatibilidade com a assinatura antiga (retorna só String).
  Future<String> analisarRebanho(Map<String, dynamic> dadosRebanho) async {
    final res = await analisarRebanhoComRAG(dadosRebanho);
    return res.texto;
  }

  /// Versão rica: retorna texto + fontes + metadados para a UI.
  Future<ResultadoIA> analisarRebanhoComRAG(
    Map<String, dynamic> dadosRebanho,
  ) async {
    // 1. Retrieval
    final ragContext = _ragService.recuperarContexto(dadosRebanho, topK: 3);
    final prompt = _ragService.construirPrompt(dadosRebanho, ragContext);
    final fontes = ragContext.resultados.map((r) => r.documento).toList();

    // 2. Sem chave → fallback local com RAG (offline-first)
    if (!Configuracao.temChaveGroq) {
      return ResultadoIA(
        texto: _gerarFallbackLocal(dadosRebanho, ragContext),
        fontes: fontes,
        retrievals: ragContext.resultados,
        usouRAG: ragContext.resultados.isNotEmpty,
        usouGroq: false,
      );
    }

    // 3. Chama a Groq com o prompt aumentado
    try {
      final resposta = await _chamarGroq(prompt);
      return ResultadoIA(
        texto: resposta,
        fontes: fontes,
        retrievals: ragContext.resultados,
        usouRAG: ragContext.resultados.isNotEmpty,
        usouGroq: true,
        modeloUsado: Configuracao.modeloGroq,
      );
    } catch (e) {
      final motivo = _mensagemErro(e);
      final fallback =
          '${_gerarFallbackLocal(dadosRebanho, ragContext)}\n\n'
          '> ⚠️ Falha ao chamar a Groq: $motivo\n'
          '> Exibindo análise local com RAG.';
      return ResultadoIA(
        texto: fallback,
        fontes: fontes,
        retrievals: ragContext.resultados,
        usouRAG: ragContext.resultados.isNotEmpty,
        usouGroq: false,
        erro: motivo,
      );
    }
  }

  // ---------------------------------------------------------------- Groq API

  Future<String> _chamarGroq(String prompt) async {
    final resposta = await _postGroq(
      chave: Configuracao.chaveGroq,
      modelo: Configuracao.modeloGroq,
      mensagens: [
        {'role': 'system', 'content': _sistema},
        {'role': 'user', 'content': prompt},
      ],
      maxTokens: 1500,
    );
    return resposta;
  }

  /// Testa uma chave (e modelo) sem depender da configuração salva.
  /// Lança [Exception] com mensagem amigável em caso de falha.
  static Future<String> testarConexao({
    required String chave,
    String? modelo,
  }) async {
    final usado = modelo ?? Configuracao.modeloGroq;
    return _postGroq(
      chave: chave,
      modelo: usado,
      mensagens: [
        {'role': 'user', 'content': 'Responda apenas: OK'},
      ],
      maxTokens: 16,
    );
  }

  static Future<String> _postGroq({
    required String chave,
    required String modelo,
    required List<Map<String, String>> mensagens,
    required int maxTokens,
  }) async {
    if (chave.trim().isEmpty) {
      throw Exception('nenhuma chave configurada');
    }

    final resp = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${chave.trim()}',
          },
          body: jsonEncode({
            'model': modelo,
            'messages': mensagens,
            'temperature': 0.3,
            'max_tokens': maxTokens,
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (resp.statusCode != 200) {
      throw Exception(_mensagemDeStatus(resp.statusCode, resp.body));
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('resposta vazia da Groq');
    }
    final message = choices.first['message'] as Map<String, dynamic>?;
    final texto = message?['content'] as String?;
    if (texto == null || texto.trim().isEmpty) {
      throw Exception('resposta sem conteúdo da Groq');
    }
    return texto.trim();
  }

  static String _mensagemDeStatus(int status, String corpo) {
    final detalhe = _extrairErroApi(corpo);
    switch (status) {
      case 400:
        if (detalhe.toLowerCase().contains('model')) {
          return 'modelo indisponível na Groq ($detalhe). '
              'Escolha outro modelo nas configurações.';
        }
        return 'requisição inválida (400): $detalhe';
      case 401:
        return 'chave de API inválida ou revogada (401).';
      case 403:
        return 'chave sem permissão de acesso (403).';
      case 404:
        return 'modelo não encontrado (404): $detalhe. '
            'Escolha outro modelo nas configurações.';
      case 413:
        return 'requisição muito grande (413).';
      case 429:
        return 'limite de requisições/cota atingido (429). Tente novamente em instantes.';
      case 503:
        return 'serviço da Groq indisponível (503).';
      default:
        return 'erro HTTP $status: $detalhe';
    }
  }

  /// Extrai a mensagem de erro do JSON padrão da Groq, se existir.
  static String _extrairErroApi(String corpo) {
    try {
      final json = jsonDecode(corpo);
      if (json is Map && json['error'] is Map) {
        final msg = json['error']['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    } catch (_) {
      // corpo não é JSON: usa o texto puro
    }
    return corpo.length > 200 ? corpo.substring(0, 200) : corpo;
  }

  static String _mensagemErro(Object e) {
    final texto = e.toString().replaceFirst('Exception: ', '');
    if (e is FormatException) return 'resposta inválida da Groq';
    return texto;
  }

  // ------------------------------------------------------- Fallback offline

  /// Análise determinística (sem LLM) usando apenas o contexto recuperado.
  String _gerarFallbackLocal(Map<String, dynamic> dados, RagContext rag) {
    final total = dados['totalAnimais'] ?? 0;
    final ativos = dados['totalAnimaisAtivos'] ?? 0;
    final doentes = dados['animaisDoentes'] ?? 0;

    final b = StringBuffer();
    b.writeln('### 🩺 Análise local (RAG sem LLM)');
    b.writeln('');
    b.writeln('Rebanho: **$ativos ativos / $total total**.');
    if (doentes is int && doentes > 0) {
      b.writeln('⚠️ **$doentes animal(is) com alerta sanitário nos últimos 7 dias.**');
    }
    b.writeln('');

    if (rag.resultados.isEmpty) {
      b.writeln('### ⚠️ Pontos de Atenção');
      b.writeln(
          '* Dados insuficientes para retrieval. Registre pesagens, partos e leite regularmente.');
    } else {
      b.writeln('### 📚 Contexto Técnico Recuperado (RAG)');
      for (final r in rag.resultados) {
        b.writeln(
            '- **${r.documento.titulo}** (${r.documento.fonte}) — score ${r.score.toStringAsFixed(3)}');
      }
      b.writeln('');
      b.writeln('### ⚠️ Pontos de Atenção');
      for (final r in rag.resultados) {
        final cat = r.documento.categoria;
        final trecho = _trecho(r.documento.conteudo, 120);
        if (cat.contains('Crescimento') || r.documento.id.contains('gmd')) {
          b.writeln('* **GMD**: $trecho');
        } else if (cat.contains('Reprodução')) {
          b.writeln('* **Reprodução**: $trecho');
        } else if (cat.contains('Sanidade')) {
          b.writeln('* **Sanidade**: $trecho');
        } else {
          b.writeln('* **$cat**: $trecho');
        }
      }
    }

    b.writeln('');
    b.writeln('### ✅ Recomendações');
    b.writeln('1. 🥩 Verificar suplementação se GMD <0,50 kg/dia (ver doc GMD).');
    b.writeln('2. 💉 Revisar calendário sanitário: Aftosa + Clostridioses (ver doc Sanitário).');
    b.writeln('3. 📊 Registrar pesagens a cada 30d e diagnóstico de prenhez 30d pós-IATF.');
    b.writeln('');
    b.writeln('### 📖 Referências RAG');
    if (rag.resultados.isEmpty) {
      b.writeln('_Nenhuma fonte recuperada._');
    } else {
      for (final r in rag.resultados) {
        b.writeln('- ${r.documento.titulo} — *${r.documento.fonte}*');
      }
    }
    b.writeln('');
    b.writeln(
        '> ℹ️ Modo offline: configure a chave da Groq em **Configurações → Consultor IA** '
        'para receber análise generativa completa com RAG + LLM.');

    return b.toString();
  }

  /// Recorta o texto sem estourar [RangeError] em documentos curtos.
  static String _trecho(String texto, int limite) {
    if (texto.length <= limite) return texto;
    return '${texto.substring(0, limite)}...';
  }
}
