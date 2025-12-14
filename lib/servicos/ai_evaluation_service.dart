import 'package:bovicheck/modelos/propriedade.dart';
import 'package:intl/intl.dart';

enum AIStatus { good, average, bad, neutral }

class AIAnalysisResult {
  final String summary;
  final AIStatus status;

  AIAnalysisResult({required this.summary, required this.status});
}

class AIEvaluationService {
  AIAnalysisResult analyzeDashboard(Map<String, double?> analysis,
      {Propriedade? propriedade}) {
    String? regiao;
    if (propriedade != null) {
      if (propriedade.municipio.isNotEmpty) {
        regiao = propriedade.municipio;
        if (propriedade.estado.isNotEmpty) {
          regiao += ' - ${propriedade.estado}';
        }
      }
    }

    if (analysis.isEmpty || analysis.values.every((v) => v == null)) {
      return AIAnalysisResult(
        summary:
            'Cadastre os dados dos seus animais (partos, pesagens, etc.) para que a IA possa analisar o desempenho do rebanho e fornecer sugestões.',
        status: AIStatus.neutral,
      );
    }

    final List<String> attentionPoints = [];
    final List<String> goodPoints = [];
    final formatter = NumberFormat("0.0");

    final mortalityRate = analysis['mortalityRate'];
    if (mortalityRate != null) {
      String sufixoRegiao =
          regiao != null ? ' para a região de **$regiao**' : '';
      if (mortalityRate > 3) {
        attentionPoints.add(
          '**Taxa de Mortalidade Alta (${formatter.format(mortalityRate)}%):** Este é um ponto crítico. Uma taxa acima de 3%$sufixoRegiao indica perdas significativas. **Sugestão:** Investigue as principais causas de morte (doenças, predadores, problemas de parto), reforce os cuidados com os recém-nascidos (cura de umbigo, colostragem) e revise o calendário de vacinação.',
        );
      } else {
        goodPoints.add('baixa Taxa de Mortalidade');
      }
    }

    final birthRate = analysis['birthRate'];
    if (birthRate != null) {
      if (birthRate < 80) {
        attentionPoints.add(
          '**Taxa de Natalidade Baixa (${formatter.format(birthRate)}%):** Uma taxa abaixo de 80% impacta diretamente o crescimento do rebanho. **Sugestão:** Avalie a saúde reprodutiva e o escore corporal das matrizes, verifique a qualidade do sêmen ou a saúde dos touros e ajuste o manejo nutricional pré-estação de monta.',
        );
      } else {
        goodPoints.add('boa Taxa de Natalidade');
      }
    }

    final calvingInterval = analysis['averageCalvingInterval'];
    if (calvingInterval != null) {
      if (calvingInterval > 420) {
        attentionPoints.add(
          '**Intervalo Entre Partos Alto (${formatter.format(calvingInterval)} dias):** Um IEP longo significa que as vacas demoram muito para emprenhar novamente, reduzindo a eficiência. **Sugestão:** Foque na nutrição pós-parto para uma rápida recuperação uterina e melhore a observação de cio para inseminar os animais no momento certo.',
        );
      }
    }

    final ageAtFirstCalving = analysis['averageAgeAtFirstCalving'];
    if (ageAtFirstCalving != null) {
      if (ageAtFirstCalving > 36) {
        attentionPoints.add(
          '**Idade ao 1º Parto Elevada (${formatter.format(ageAtFirstCalving)} meses):** Novilhas parindo tarde aumentam o custo de produção. **Sugestão:** Garanta que as bezerras e novilhas tenham um plano nutricional adequado para atingir o peso ideal para a primeira cobertura mais cedo (geralmente entre 14-18 meses).',
        );
      }
    }

    String tituloRegiao = regiao != null
        ? 'Análise para a propriedade **${propriedade!.nome}** (Região de $regiao)'
        : 'Análise geral do rebanho';

    if (attentionPoints.isNotEmpty) {
      return AIAnalysisResult(
        summary:
            '$tituloRegiao:\n\nIdentifiquei alguns pontos de atenção no seu rebanho:\n\n${attentionPoints.join('\n\n')}',
        status: AIStatus.bad,
      );
    }

    if (goodPoints.isNotEmpty) {
      return AIAnalysisResult(
        summary:
            '$tituloRegiao:\n\nParabéns! Sua gestão está mostrando ótimos resultados, especialmente na **${goodPoints.join(' e na ')}**. Continue o bom trabalho e siga monitorando os índices.',
        status: AIStatus.good,
      );
    }

    return AIAnalysisResult(
      summary:
          '$tituloRegiao:\n\nOs índices do seu rebanho estão dentro do esperado. Continue registrando os dados para um monitoramento contínuo e para identificar tendências ao longo do tempo.',
      status: AIStatus.neutral,
    );
  }
}
