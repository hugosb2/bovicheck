import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/calculation_controller.dart';
import '../models/calculation_record.dart';

class CalculationView extends StatelessWidget {
  const CalculationView({super.key});

  String _getIndiceDescription(String indexName) {
    switch (indexName) {
      case 'Taxa de Natalidade':
        return 'Mede a eficiência reprodutiva do rebanho, indicando o percentual de nascimentos a partir do total de fêmeas aptas.';
      case 'Taxa de Desmame':
        return 'Indica a porcentagem de bezerros que sobreviveram do nascimento até o desmame, em relação ao total de nascidos vivos.';
      case 'Ganho Médio Diário (GMD)':
        return 'Mostra o ganho de peso médio de um animal por dia em um determinado período, um indicador chave da performance de engorda.';
      case 'Peso ao Desmame Ajustado P205':
        return 'Padroniza o peso dos bezerros a uma idade de 205 dias para permitir comparações justas de desempenho entre eles.';
      case 'Taxa de Mortalidade':
        return 'Mede a porcentagem de animais que morreram em relação ao total de animais existentes no início do período.';
      case 'Lotação Animal':
        return 'Relaciona o peso total dos animais (convertido em Unidade Animal - UA) com a área de pastagem disponível (em hectares).';
      case 'Produção de Leite por Vaca/Dia':
        return 'Calcula a média de litros de leite produzidos por cada vaca em lactação em um único dia.';
      case 'Idade ao Primeiro Parto':
        return 'Indica a idade média, em meses, em que as fêmeas do rebanho (novilhas) parem pela primeira vez.';
      case 'Intervalo entre Partos':
        return 'Mede o tempo médio, em dias, entre um parto e o parto seguinte da mesma vaca, refletindo a eficiência reprodutiva.';
      case 'Taxa de Prenhez':
        return 'Calcula o percentual de fêmeas que foram diagnosticadas como prenhas em relação ao total de fêmeas expostas à reprodução.';
      case 'Conversão Alimentar':
        return 'Mede a eficiência com que o animal converte o alimento consumido (em matéria seca) em peso vivo.';
      case 'Rendimento de Carcaça':
        return 'Indica a porcentagem do peso vivo do animal que se transforma em carcaça após o abate e a retirada das partes não comestíveis.';
      default:
        return 'Descrição não encontrada.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic argument = ModalRoute.of(context)!.settings.arguments;

    final String indiceSelecionado =
        argument is CalculationRecord ? argument.indexName : argument as String;
    final CalculationRecord? recordToEdit =
        argument is CalculationRecord ? argument : null;

    return ChangeNotifierProvider(
      create: (_) => CalculationController(
        indiceSelecionado: indiceSelecionado,
        recordToEdit: recordToEdit,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(recordToEdit == null
              ? indiceSelecionado
              : 'Editar $indiceSelecionado'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Consumer<CalculationController>(
          builder: (context, controller, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _getIndiceDescription(indiceSelecionado),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._buildInputFields(indiceSelecionado, controller),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: controller.calcular,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: Text(
                          recordToEdit == null ? 'Calcular' : 'Salvar Alterações'),
                    ),
                    const SizedBox(height: 24),
                    if (controller.resultado.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: controller.hasError
                              ? Theme.of(context).colorScheme.errorContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          controller.resultado,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: controller.hasError
                                ? Theme.of(context).colorScheme.onErrorContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildInputFields(
      String indiceSelecionado, CalculationController controller) {
    switch (indiceSelecionado) {
      case 'Taxa de Natalidade':
        return [
          _buildTextField(controller, 'numBezerrosNascidosVivos',
              'Nº de bezerros nascidos vivos'),
          _buildTextField(controller, 'totalFemeasAptasReproducao',
              'Nº total de fêmeas aptas'),
        ];
      case 'Taxa de Desmame':
        return [
          _buildTextField(
              controller, 'numBezerrosDesmamados', 'Nº de bezerros desmamados'),
          _buildTextField(controller, 'numBezerrosNascidosVivosPeriodo',
              'Nº de bezerros nascidos vivos no período'),
        ];
      case 'Ganho Médio Diário (GMD)':
        return [
          _buildTextField(controller, 'pesoInicialKg', 'Peso inicial (kg)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          _buildTextField(controller, 'pesoFinalKg', 'Peso final (kg)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          _buildTextField(
              controller, 'numDias', 'Nº de dias entre pesagens'),
        ];
      case 'Peso ao Desmame Ajustado P205':
        return [
          _buildTextField(controller, 'pesoAoNascerKg', 'Peso ao nascer (kg)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          _buildTextField(
              controller, 'pesoRealDesmamaKg', 'Peso real à desmama (kg)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          _buildTextField(controller, 'idadeRealDesmamaDias',
              'Idade real à desmama (dias)'),
        ];
      case 'Taxa de Mortalidade':
        return [
          _buildTextField(
              controller, 'numAnimaisMortos', 'Nº de animais mortos'),
          _buildTextField(controller, 'totalAnimaisInicioPeriodo',
              'Nº total de animais no início'),
        ];
      case 'Lotação Animal':
        return [
          _buildTextField(
              controller, 'numTotalAnimais', 'Nº total de animais'),
          _buildTextField(controller, 'pesoVivoMedioAnimalKg',
              'Peso vivo médio por animal (kg)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          _buildTextField(
              controller, 'areaTotalPastagemHa', 'Área total de pastagem (ha)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
        ];
      case 'Produção de Leite por Vaca/Dia':
        return [
          _buildTextField(controller, 'producaoTotalLeiteDiaL',
              'Produção total de leite no dia (L)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          _buildTextField(
              controller, 'numVacasEmLactacao', 'Nº de vacas em lactação'),
        ];
      case 'Idade ao Primeiro Parto':
        return [
          _buildTextField(controller, 'dataNascimentoNovilha',
              'Data de nascimento da novilha (dd/mm/aaaa)',
              isDate: true),
          _buildTextField(controller, 'dataPrimeiroParto',
              'Data do primeiro parto (dd/mm/aaaa)',
              isDate: true),
        ];
      case 'Intervalo entre Partos':
        return [
          _buildTextField(controller, 'dataPartoAnterior',
              'Data do parto anterior (dd/mm/aaaa)',
              isDate: true),
          _buildTextField(controller, 'dataPartoAtual',
              'Data do parto atual (dd/mm/aaaa)',
              isDate: true),
        ];
      case 'Taxa de Prenhez':
        return [
          _buildTextField(controller, 'numFemeasPrenhes',
              'Nº de fêmeas diagnosticadas prenhas'),
          _buildTextField(
              controller, 'totalFemeasAptas', 'Nº total de fêmeas aptas (expostas)'),
        ];
      case 'Conversão Alimentar':
        return [
          _buildTextField(controller, 'consumoMateriaSecaKg',
              'Consumo de matéria seca (MS em kg)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          _buildTextField(
              controller, 'ganhoPesoVivoKg', 'Ganho de peso vivo (PV em kg)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
        ];
      case 'Rendimento de Carcaça':
        return [
          _buildTextField(controller, 'pesoVivoAntesAbateKg',
              'Peso vivo antes do abate (kg)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
          _buildTextField(
              controller, 'pesoCarcacaKg', 'Peso da carcaça (kg)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true)),
        ];
      default:
        return [];
    }
  }

  Widget _buildTextField(
      CalculationController controller, String key, String label,
      {TextInputType keyboardType = TextInputType.number, bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller.textControllers[key],
        decoration: InputDecoration(
            labelText: label, hintText: isDate ? 'dd/mm/aaaa' : null),
        keyboardType: keyboardType,
      ),
    );
  }
}