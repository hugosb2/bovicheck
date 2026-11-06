import 'package:flutter_test/flutter_test.dart';
import 'package:bovicheck/servicos/rag/retrieval_servico.dart';
import 'package:bovicheck/servicos/rag/rag_servico.dart';
import 'package:bovicheck/servicos/ia_groq_cliente.dart';

void main() {
  group('RAG Retrieval', () {
    test('recupera doc GMD para query de ganho baixo', () {
      final retrieval = RetrievalService();
      final res = retrieval.recuperar('gmd baixo ganho peso suplementação', topK: 2);
      expect(res.length, greaterThan(0));
      expect(res.first.documento.id.contains('gmd'), isTrue);
      expect(res.first.score, greaterThan(0.1));
    });

    test('recupera doc mortalidade para mortalidade alta', () {
      final retrieval = RetrievalService();
      final res = retrieval.recuperar('mortalidade alta sanidade óbito vacina', topK: 1);
      expect(res.first.documento.id, contains('mortal'));
    });

    test('RAGService monta prompt com contexto', () {
      final rag = RAGService();
      final dados = {
        'fazenda': 'Fazenda Teste',
        'local': 'Campo Grande/MS',
        'totalAnimais': 50,
        'totalAnimaisAtivos': 45,
        'distribuicao': {'machos': 20, 'femeas': 25},
        'lotes': ['Piquete A'],
        'animaisDoentes': 3,
        'indicadores': {
          'taxaMortalidade': 6.0,
          'mediaGMD': 0.4,
          'totalLeiteMes': 1200.0,
        }
      };
      final ctx = rag.recuperarContexto(dados, topK: 3);
      expect(ctx.resultados.length, greaterThan(0));
      final prompt = rag.construirPrompt(dados, ctx);
      expect(prompt, contains('RAG'));
      expect(prompt, contains('Fazenda Teste'));
    });

    test('IAGroqCliente fallback com RAG sem API key', () async {
      final cliente = IAGroqCliente();
      final dados = {
        'fazenda': 'Teste',
        'local': 'MS',
        'totalAnimais': 10,
        'totalAnimaisAtivos': 8,
        'distribuicao': {'machos': 5, 'femeas': 5},
        'lotes': ['A'],
        'animaisDoentes': 1,
        'indicadores': {'taxaMortalidade': 5.5, 'mediaGMD': 0.3}
      };
      final res = await cliente.analisarRebanhoComRAG(dados);
      expect(res.usouRAG, isTrue);
      expect(res.usouGroq, isFalse);
      expect(res.fontes, isNotEmpty);
      expect(res.texto, contains('RAG'));
    });
  });
}
