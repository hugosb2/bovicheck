// lib/services/ai_evaluation_service.dart

import 'package:bovicheck/models/calculation_record.dart';
import 'package:bovicheck/services/json_storage_service.dart';

// Enum para definir o status geral da análise
enum AIStatus { good, average, bad, neutral }

// Classe para encapsular o resultado da análise
class AIAnalysisResult {
  final String summary;
  final AIStatus status;

  AIAnalysisResult({required this.summary, required this.status});
}

class AIEvaluationService {
  // NOVO: "Base de Conhecimento" da IA com dicas para cada índice.
  static const Map<String, String> _improvementAdvice = {
    'Taxa de Natalidade':
        'Para aumentar a natalidade, foque na nutrição adequada das fêmeas, no controle sanitário e na escolha de touros com boa fertilidade.',
    'Taxa de Prenhez':
        'Melhore a taxa de prenhez através da detecção precisa do cio, do uso de protocolos de inseminação eficientes e da avaliação da saúde reprodutiva do rebanho.',
    'Taxa de Desmame':
        'Para garantir que mais bezerros cheguem ao desmame, invista na colostragem de qualidade, no cuidado com a cura do umbigo e no controle de diarreias e pneumonias.',
    'Ganho Médio Diário (GMD)':
        'Para melhorar o GMD, avalie a qualidade da dieta (pasto e suplementação), garanta o conforto térmico e monitore a saúde do rebanho para prevenir doenças.',
    'Peso ao Desmame Ajustado P205':
        'Aumente o peso ao desmame melhorando a produção de leite das matrizes e introduzindo um bom sistema de creep-feeding para os bezerros.',
    'Rendimento de Carcaça':
        'O rendimento de carcaça é influenciado pela genética, pelo nível de acabamento (gordura) e pelo jejum pré-abate. Foque em animais com boa conformação muscular.',
    'Produção de Leite por Vaca/Dia':
        'Para aumentar a produção, forneça uma dieta balanceada e de alta qualidade, água fresca abundante e garanta o máximo de conforto e bem-estar para as vacas em lactação.',
    'Lotação Animal':
        'Para otimizar a lotação, invista no manejo de pastagens, como a rotação de piquetes e a adubação, para aumentar a produção de forragem por hectare.',
    'Idade ao Primeiro Parto':
        'Para reduzir a idade ao primeiro parto, garanta que as novilhas atinjam o peso e o desenvolvimento corporal ideais para a reprodução mais cedo, através de uma nutrição adequada.',
    'Intervalo entre Partos':
        'Para diminuir o intervalo entre partos, foque na rápida recuperação pós-parto das vacas, boa nutrição e um programa de detecção de cio e reprodução eficiente.',
    'Taxa de Mortalidade':
        'Para reduzir a mortalidade, reforce as práticas de bem-estar animal, o saneamento das instalações, um calendário de vacinação rigoroso e o rápido diagnóstico e tratamento de doenças.',
    'Conversão Alimentar':
        'Melhore a conversão alimentar oferecendo uma dieta com a proporção correta de nutrientes, evitando desperdícios de alimento e mantendo os animais saudáveis.',
  };

  static const Map<String, String> _indexType = {
    'Taxa de Natalidade': 'higherIsBetter',
    'Taxa de Prenhez': 'higherIsBetter',
    'Taxa de Desmame': 'higherIsBetter',
    'Ganho Médio Diário (GMD)': 'higherIsBetter',
    'Peso ao Desmame Ajustado P205': 'higherIsBetter',
    'Rendimento de Carcaça': 'higherIsBetter',
    'Produção de Leite por Vaca/Dia': 'higherIsBetter',
    'Lotação Animal': 'higherIsBetter',
    'Idade ao Primeiro Parto': 'lowerIsBetter',
    'Intervalo entre Partos': 'lowerIsBetter',
    'Taxa de Mortalidade': 'lowerIsBetter',
    'Conversão Alimentar': 'lowerIsBetter',
  };

  /// Analisa a situação geral para o Dashboard, focando em pontos de atenção.
  AIAnalysisResult analyzeDashboard(List<CalculationRecord> latestRecords) {
    if (latestRecords.isEmpty) {
      return AIAnalysisResult(
        summary:
            'Ainda não há dados suficientes para uma análise. Comece a calcular seus índices!',
        status: AIStatus.neutral,
      );
    }

    List<String> attentionPoints = [];

    for (var record in latestRecords) {
      final history =
          JsonStorageService.instance.getHistoryForIndex(record.indexName);
      if (history.length < 2) continue;

      final type = _indexType[record.indexName];
      final trend =
          history.first.value - history.last.value; // Recente - Antigo

      // Se a tendência for negativa, marca como ponto de atenção.
      if ((type == 'higherIsBetter' && trend < 0) ||
          (type == 'lowerIsBetter' && trend > 0)) {
        attentionPoints.add(record.indexName);
      }
    }

    if (attentionPoints.isEmpty) {
      return AIAnalysisResult(
        summary:
            'Visão geral positiva! Seus índices demonstram consistência ou melhora. Continue monitorando para manter os ótimos resultados.',
        status: AIStatus.good,
      );
    } else {
      return AIAnalysisResult(
        summary:
            'Notei que **${attentionPoints.join(', ')}** pode(m) precisar de mais atenção. Verifique o histórico de cada um para uma análise detalhada e dicas de como melhorar.',
        status: AIStatus.average,
      );
    }
  }

  /// Analisa o histórico de um índice, focando na tendência e em conselhos práticos.
  AIAnalysisResult analyzeHistory(List<CalculationRecord> records) {
    if (records.length < 2) {
      return AIAnalysisResult(
        summary:
            'É necessário pelo menos dois registros para que a IA possa analisar a tendência deste índice.',
        status: AIStatus.neutral,
      );
    }

    final indexName = records.first.indexName;
    final type = _indexType[indexName];
    final advice = _improvementAdvice[indexName];

    if (type == null || advice == null) {
      return AIAnalysisResult(
          summary: 'Análise detalhada não disponível para este índice.',
          status: AIStatus.neutral);
    }

    final lastValue = records.first.value;
    final firstValue = records.last.value;

    String situation;
    String recommendation;
    AIStatus finalStatus;

    if (lastValue == firstValue) {
      situation =
          'A situação do índice se manteve **estável** no período analisado. É importante avaliar se o patamar atual de **${lastValue.toStringAsFixed(2)}** é satisfatório para seus objetivos.';
      recommendation = '**Para melhorar:** $advice';
      finalStatus = AIStatus.average;
    } else if ((type == 'higherIsBetter' && lastValue > firstValue) ||
        (type == 'lowerIsBetter' && lastValue < firstValue)) {
      situation =
          'A situação é **favorável**, com uma tendência de **melhora** nos resultados ao longo do tempo.';
      recommendation =
          '**Para manter os bons resultados:** Continue aplicando as práticas que levaram a essa evolução. $advice';
      finalStatus = AIStatus.good;
    } else {
      situation =
          'A situação requer **atenção**. Foi observada uma tendência de **piora** nos resultados para este índice.';
      recommendation = '**Para reverter este quadro:** $advice';
      finalStatus = AIStatus.bad;
    }

    return AIAnalysisResult(
      summary: '$situation\n\n$recommendation',
      status: finalStatus,
    );
  }
}
