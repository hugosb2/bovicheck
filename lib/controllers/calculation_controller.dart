import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/indice_calculator.dart';
import '../models/calculation_record.dart';
import '../services/json_storage_service.dart';
import '../services/user_activity_service.dart';

class CalculationController extends ChangeNotifier {
  final CalculadoraIndicesProdutivos _calculator = CalculadoraIndicesProdutivos();
  final String indiceSelecionado;
  final CalculationRecord? recordToEdit;

  String _resultado = '';
  bool _hasError = false;

  String get resultado => _resultado;
  bool get hasError => _hasError;

  final Map<String, TextEditingController> textControllers = {
    'numBezerrosNascidosVivos': TextEditingController(),
    'totalFemeasAptasReproducao': TextEditingController(),
    'numBezerrosDesmamados': TextEditingController(),
    'numBezerrosNascidosVivosPeriodo': TextEditingController(),
    'pesoInicialKg': TextEditingController(),
    'pesoFinalKg': TextEditingController(),
    'numDias': TextEditingController(),
    'pesoAoNascerKg': TextEditingController(),
    'pesoRealDesmamaKg': TextEditingController(),
    'idadeRealDesmamaDias': TextEditingController(),
    'numAnimaisMortos': TextEditingController(),
    'totalAnimaisInicioPeriodo': TextEditingController(),
    'numTotalAnimais': TextEditingController(),
    'pesoVivoMedioAnimalKg': TextEditingController(),
    'areaTotalPastagemHa': TextEditingController(),
    'producaoTotalLeiteDiaL': TextEditingController(),
    'numVacasEmLactacao': TextEditingController(),
    'dataNascimentoNovilha': TextEditingController(),
    'dataPrimeiroParto': TextEditingController(),
    'dataPartoAnterior': TextEditingController(),
    'dataPartoAtual': TextEditingController(),
    'numFemeasPrenhes': TextEditingController(),
    'totalFemeasAptas': TextEditingController(),
    'consumoMateriaSecaKg': TextEditingController(),
    'ganhoPesoVivoKg': TextEditingController(),
    'pesoVivoAntesAbateKg': TextEditingController(),
    'pesoCarcacaKg': TextEditingController(),
  };

  CalculationController({required this.indiceSelecionado, this.recordToEdit}) {
    if (recordToEdit != null) {
      recordToEdit!.inputs.forEach((key, value) {
        if (textControllers.containsKey(key)) {
          textControllers[key]!.text = value;
        }
      });
    }
  }

  void calcular() {
    try {
      UserActivityService.instance.logAction('calculate:$indiceSelecionado');

      double valorCalculado = 0;
      String unidade = '';
      final values = textControllers.map((key, controller) =>
          MapEntry(key, controller.text.replaceAll(',', '.')));
      final dateFormat = DateFormat('dd/MM/yyyy');

      List<String> inputKeys = _getInputKeysForIndex(indiceSelecionado);
      final Map<String, String> inputsParaSalvar = {
        for (var key in inputKeys) key: textControllers[key]!.text
      };

      switch (indiceSelecionado) {
        case 'Taxa de Natalidade':
          valorCalculado = _calculator.taxaDeNatalidade(
            numBezerrosNascidosVivos: int.parse(values['numBezerrosNascidosVivos']!),
            totalFemeasAptasReproducao: int.parse(values['totalFemeasAptasReproducao']!),
          );
          unidade = '%';
          break;
        case 'Taxa de Desmame':
          valorCalculado = _calculator.taxaDeDesmame(
            numBezerrosDesmamados: int.parse(values['numBezerrosDesmamados']!),
            numBezerrosNascidosVivosPeriodo: int.parse(values['numBezerrosNascidosVivosPeriodo']!),
          );
          unidade = '%';
          break;
        case 'Ganho Médio Diário (GMD)':
          valorCalculado = _calculator.ganhoMedioDiario(
            pesoInicialKg: double.parse(values['pesoInicialKg']!),
            pesoFinalKg: double.parse(values['pesoFinalKg']!),
            numDias: int.parse(values['numDias']!),
          );
          unidade = 'kg/dia';
          break;
        case 'Peso ao Desmame Ajustado P205':
          valorCalculado = _calculator.pesoAoDesmameAjustadoP205(
            pesoAoNascerKg: double.parse(values['pesoAoNascerKg']!),
            pesoRealDesmamaKg: double.parse(values['pesoRealDesmamaKg']!),
            idadeRealDesmamaDias: int.parse(values['idadeRealDesmamaDias']!),
          );
          unidade = 'kg';
          break;
        case 'Taxa de Mortalidade':
          valorCalculado = _calculator.taxaDeMortalidade(
            numAnimaisMortos: int.parse(values['numAnimaisMortos']!),
            totalAnimaisInicioPeriodo: int.parse(values['totalAnimaisInicioPeriodo']!),
          );
          unidade = '%';
          break;
        case 'Lotação Animal':
          valorCalculado = _calculator.lotacaoAnimal(
            numTotalAnimais: int.parse(values['numTotalAnimais']!),
            pesoVivoMedioAnimalKg: double.parse(values['pesoVivoMedioAnimalKg']!),
            areaTotalPastagemHa: double.parse(values['areaTotalPastagemHa']!),
          );
          unidade = 'UA/ha';
          break;
        case 'Produção de Leite por Vaca/Dia':
          valorCalculado = _calculator.producaoLeitePorVacaDia(
            producaoTotalLeiteDiaL: double.parse(values['producaoTotalLeiteDiaL']!),
            numVacasEmLactacao: int.parse(values['numVacasEmLactacao']!),
          );
          unidade = 'L/vaca/dia';
          break;
        case 'Idade ao Primeiro Parto':
          valorCalculado = _calculator.idadeAoPrimeiroParto(
            dataNascimentoNovilha: dateFormat.parse(values['dataNascimentoNovilha']!),
            dataPrimeiroParto: dateFormat.parse(values['dataPrimeiroParto']!),
          );
          unidade = 'meses';
          break;
        case 'Intervalo entre Partos':
          valorCalculado = _calculator.intervaloEntrePartos(
            dateFormat.parse(values['dataPartoAnterior']!),
            dateFormat.parse(values['dataPartoAtual']!),
          );
          unidade = 'dias';
          break;
        case 'Taxa de Prenhez':
          valorCalculado = _calculator.taxaDePrenhez(
            numFemeasPrenhes: int.parse(values['numFemeasPrenhes']!),
            totalFemeasAptas: int.parse(values['totalFemeasAptas']!),
          );
          unidade = '%';
          break;
        case 'Conversão Alimentar':
          valorCalculado = _calculator.conversaoAlimentar(
            consumoMateriaSecaKg: double.parse(values['consumoMateriaSecaKg']!),
            ganhoPesoVivoKg: double.parse(values['ganhoPesoVivoKg']!),
          );
          unidade = '';
          break;
        case 'Rendimento de Carcaça':
          valorCalculado = _calculator.rendimentoDeCarcaca(
            pesoVivoAntesAbateKg: double.parse(values['pesoVivoAntesAbateKg']!),
            pesoCarcacaKg: double.parse(values['pesoCarcacaKg']!),
          );
          unidade = '%';
          break;
      }

      final record = CalculationRecord(
        id: recordToEdit?.id ?? const Uuid().v4(),
        indexName: indiceSelecionado,
        value: valorCalculado,
        unit: unidade,
        date: DateTime.now(),
        inputs: inputsParaSalvar,
      );

      if (recordToEdit != null) {
        JsonStorageService.instance.updateCalculation(record);
        _resultado = 'Resultado: ${valorCalculado.toStringAsFixed(2)} $unidade\nAlterações salvas!';
      } else {
        JsonStorageService.instance.addCalculation(record);
        _resultado = 'Resultado: ${valorCalculado.toStringAsFixed(2)} $unidade\nSalvo no histórico!';
      }
      
      _hasError = false;
    } catch (e) {
      _resultado = 'Erro nos dados: Verifique os valores e formatos.';
      _hasError = true;
    }
    notifyListeners();
  }

  List<String> _getInputKeysForIndex(String indexName) {
    switch (indexName) {
      case 'Taxa de Natalidade':
        return ['numBezerrosNascidosVivos', 'totalFemeasAptasReproducao'];
      case 'Taxa de Desmame':
        return ['numBezerrosDesmamados', 'numBezerrosNascidosVivosPeriodo'];
      case 'Ganho Médio Diário (GMD)':
        return ['pesoInicialKg', 'pesoFinalKg', 'numDias'];
      case 'Peso ao Desmame Ajustado P205':
        return ['pesoAoNascerKg', 'pesoRealDesmamaKg', 'idadeRealDesmamaDias'];
      case 'Taxa de Mortalidade':
        return ['numAnimaisMortos', 'totalAnimaisInicioPeriodo'];
      case 'Lotação Animal':
        return ['numTotalAnimais', 'pesoVivoMedioAnimalKg', 'areaTotalPastagemHa'];
      case 'Produção de Leite por Vaca/Dia':
        return ['producaoTotalLeiteDiaL', 'numVacasEmLactacao'];
      case 'Idade ao Primeiro Parto':
        return ['dataNascimentoNovilha', 'dataPrimeiroParto'];
      case 'Intervalo entre Partos':
        return ['dataPartoAnterior', 'dataPartoAtual'];
      case 'Taxa de Prenhez':
        return ['numFemeasPrenhes', 'totalFemeasAptas'];
      case 'Conversão Alimentar':
        return ['consumoMateriaSecaKg', 'ganhoPesoVivoKg'];
      case 'Rendimento de Carcaça':
        return ['pesoVivoAntesAbateKg', 'pesoCarcacaKg'];
      default:
        return [];
    }
  }

  @override
  void dispose() {
    textControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}