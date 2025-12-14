import 'dart:typed_data';
import 'package:bovicheck/modelos/herd_indicator.dart';
import 'package:bovicheck/modelos/lote.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:bovicheck/modelos/animal/animal.dart';

class SpreadsheetService {
  Future<bool> exportSelectedData({
    bool exportAnimals = true,
    bool exportLotes = true,
    bool exportIndicators = true,
  }) async {
    var excel = Excel.createExcel();

    var headerStyle = CellStyle(
      bold: true,
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Center,
    );
    headerStyle.wrap = TextWrapping.WrapText;

    bool hasData = false;

    if (exportAnimals) {
      final animals = await DatabaseService.instance.getAllAnimalsWithHistory();
      if (animals.isNotEmpty) {
        hasData = true;
        _createAnimalSheet(excel, animals, headerStyle);
        _createWeightSheet(excel, animals, headerStyle);
        _createHealthSheet(excel, animals, headerStyle);
        _createReproductiveSheet(excel, animals, headerStyle);
        _createMilkSheet(excel, animals, headerStyle);
      }
    }

    if (exportLotes) {
      final lotes = await DatabaseService.instance.getAllLotes();
      if (lotes.isNotEmpty) {
        hasData = true;
        _createLotesSheet(excel, lotes, headerStyle);
      }
    }

    if (exportIndicators) {
      final indicators = await DatabaseService.instance.getAllHerdIndicators();
      if (indicators.isNotEmpty) {
        hasData = true;
        _createIndicatorsSheet(excel, indicators, headerStyle);
      }
    }

    if (!hasData) {
      return false;
    }

    excel.delete('Sheet1');

    final fileBytes = excel.encode();
    if (fileBytes == null) {
      return false;
    }

    final fileName =
        'BoviCheck_Export_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
    final Uint8List bytes = Uint8List.fromList(fileBytes);

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar planilha como:',
      fileName: fileName,
      bytes: bytes,
    );

    return outputFile != null;
  }

  Future<bool> exportAllData() async {
    return exportSelectedData(
      exportAnimals: true,
      exportLotes: true,
      exportIndicators: true,
    );
  }

  void _createAnimalSheet(
      Excel excel, List<Animal> animals, CellStyle headerStyle) {
    Sheet sheet = excel['Rebanho'];
    final headers = [
      'ID',
      'Brinco',
      'Nome',
      'Data Nasc.',
      'Sexo',
      'Raça',
      'Lote ID',
      'Status',
      'Data Saída',
      'Motivo Saída'
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    for (var i = 0; i < animals.length; i++) {
      final animal = animals[i];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(animal.id);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(animal.brinco);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue(animal.nome ?? '');
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
              .value =
          TextCellValue(DateFormat('dd/MM/yyyy').format(animal.dataNascimento));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = TextCellValue(animal.sexo);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
          .value = TextCellValue(animal.raca ?? '');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1))
          .value = TextCellValue(animal.loteId ?? '');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1))
          .value = TextCellValue(animal.status.name);
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 1))
              .value =
          TextCellValue(animal.dataSaida != null
              ? DateFormat('dd/MM/yyyy').format(animal.dataSaida!)
              : '');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 1))
          .value = TextCellValue(animal.motivoSaida ?? '');
    }
  }

  void _createWeightSheet(
      Excel excel, List<Animal> animals, CellStyle headerStyle) {
    Sheet sheet = excel['Pesagens'];
    final headers = ['Animal Brinco', 'Data', 'Peso (kg)'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    int rowIndex = 1;
    for (final animal in animals) {
      for (final record in animal.historicoPeso) {
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(animal.brinco);
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 1, rowIndex: rowIndex))
                .value =
            TextCellValue(DateFormat('dd/MM/yyyy').format(record.date));
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = DoubleCellValue(record.weight);
        rowIndex++;
      }
    }
  }

  void _createHealthSheet(
      Excel excel, List<Animal> animals, CellStyle headerStyle) {
    Sheet sheet = excel['Saude'];
    final headers = [
      'Animal Brinco',
      'Data',
      'Diagnóstico',
      'Tratamento',
      'Medicação',
      'Tipo Medicação',
      'Dose'
    ]; // Headers combinados
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    int rowIndex = 1;
    for (final animal in animals) {
      // Eventos de Saúde
      for (final record in animal.historicoSaude) {
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(animal.brinco);
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 1, rowIndex: rowIndex))
                .value =
            TextCellValue(DateFormat('dd/MM/yyyy').format(record.date));
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(record.diagnosis);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(record.treatment ?? '');
        rowIndex++;
      }
      // Registros de Medicação
      for (final record in animal.historicoMedicacao) {
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(animal.brinco);
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 1, rowIndex: rowIndex))
                .value =
            TextCellValue(DateFormat('dd/MM/yyyy').format(record.date));
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(record.productName);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(record.type);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(record.dose);
        rowIndex++;
      }
    }
  }

  void _createReproductiveSheet(
      Excel excel, List<Animal> animals, CellStyle headerStyle) {
    Sheet sheet = excel['Reproducao'];
    final headers = ['Animal Brinco', 'Data', 'Tipo de Evento', 'Resultado'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    int rowIndex = 1;
    for (final animal in animals) {
      for (final record in animal.historicoReprodutivo) {
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(animal.brinco);
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 1, rowIndex: rowIndex))
                .value =
            TextCellValue(DateFormat('dd/MM/yyyy').format(record.date));
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(record.eventType);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(record.result ?? '');
        rowIndex++;
      }
    }
  }

  void _createMilkSheet(
      Excel excel, List<Animal> animals, CellStyle headerStyle) {
    Sheet sheet = excel['Producao_Leite'];
    final headers = [
      'Animal Brinco',
      'Data',
      'Prod. Manhã (L)',
      'Prod. Tarde (L)',
      'Total (L)'
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    int rowIndex = 1;
    for (final animal in animals) {
      for (final record in animal.historicoLeite) {
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(animal.brinco);
        sheet
                .cell(CellIndex.indexByColumnRow(
                    columnIndex: 1, rowIndex: rowIndex))
                .value =
            TextCellValue(DateFormat('dd/MM/yyyy').format(record.date));
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = DoubleCellValue(record.morningProduction);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = DoubleCellValue(record.afternoonProduction);
        sheet
            .cell(
                CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = DoubleCellValue(record.totalProduction);
        rowIndex++;
      }
    }
  }

  void _createLotesSheet(Excel excel, List<Lote> lotes, CellStyle headerStyle) {
    Sheet sheet = excel['Lotes'];
    final headers = ['ID', 'Nome', 'Descrição', 'Propriedade ID'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    for (var i = 0; i < lotes.length; i++) {
      final lote = lotes[i];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(lote.id);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(lote.nome);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue(lote.descricao ?? '');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = TextCellValue(lote.propriedadeId);
    }
  }

  void _createIndicatorsSheet(
      Excel excel, List<HerdIndicator> indicators, CellStyle headerStyle) {
    Sheet sheet = excel['Indices_Produtivos'];
    final headers = [
      'ID',
      'Nome do Índice',
      'Unidade',
      'Aplicar a Área de Pastagem',
      'Aplicar a Propriedade',
      'Data de Criação'
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    for (var i = 0; i < indicators.length; i++) {
      final indicator = indicators[i];
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1))
          .value = TextCellValue(indicator.id);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1))
          .value = TextCellValue(indicator.indicatorTitle);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1))
          .value = TextCellValue(indicator.indicatorUnit);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1))
          .value = TextCellValue(indicator.applyToLote ? 'Sim' : 'Não');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1))
          .value = TextCellValue(indicator.applyToProperty ? 'Sim' : 'Não');
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1))
              .value =
          TextCellValue(
              DateFormat('dd/MM/yyyy HH:mm').format(indicator.createdAt));
    }
  }
}
