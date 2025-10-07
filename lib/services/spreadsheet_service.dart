// lib/services/spreadsheet_service.dart

import 'dart:typed_data'; // CORRIGIDO: import 'dart:typed_data';
import 'dart:math';      // CORRIGIDO: import 'dart:math';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'json_storage_service.dart';

class SpreadsheetService {
  Future<bool> exportAllData() async {
    final allData = JsonStorageService.instance.getAllData();

    if (allData.isEmpty) {
      return false;
    }

    var excel = Excel.createExcel();

    var headerStyle = CellStyle(
      bold: true,
      verticalAlign: VerticalAlign.Center,
      horizontalAlign: HorizontalAlign.Center,
    );
    headerStyle.wrap = TextWrapping.WrapText;

    var dataStyle = CellStyle(
      verticalAlign: VerticalAlign.Center,
    );
    dataStyle.wrap = TextWrapping.WrapText;
    
    allData.forEach((indexName, records) {
      if (records.isNotEmpty) {
        String sheetName = indexName.replaceAll(RegExp(r'[\/:*?\[\]]'), '').substring(0, min(31, indexName.length));
        Sheet sheetObject = excel[sheetName];

        List<String> headerTitles = ['Nome do Índice', 'Valor', 'Unidade', 'Data e Hora'];
        for (var i = 0; i < headerTitles.length; i++) {
          var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.value = TextCellValue(headerTitles[i]);
          cell.cellStyle = headerStyle;
        }

        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
        for (var rowIndex = 0; rowIndex < records.length; rowIndex++) {
          var record = records[rowIndex];
          var rowData = [
            TextCellValue(record.indexName),
            DoubleCellValue(record.value),
            TextCellValue(record.unit),
            TextCellValue(dateFormat.format(record.date)),
          ];
          
          for (var colIndex = 0; colIndex < rowData.length; colIndex++) {
            var cell = sheetObject.cell(CellIndex.indexByColumnRow(
              columnIndex: colIndex, 
              rowIndex: rowIndex + 1,
            ));
            cell.value = rowData[colIndex];
            cell.cellStyle = dataStyle;
          }
        }

        for (var i = 0; i < headerTitles.length; i++) {
          sheetObject.setColumnAutoFit(i);
        }
      }
    });

    if (excel.sheets.containsKey('Sheet1') && excel.sheets['Sheet1']!.maxRows == 0) {
      excel.delete('Sheet1');
    }

    final fileBytes = excel.encode();
    if (fileBytes == null) {
      return false;
    }
    
    final fileName = 'BoviCheck_Export_Completo_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
    final Uint8List bytes = Uint8List.fromList(fileBytes);

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar planilha como:',
      fileName: fileName,
      bytes: bytes,
    );

    return outputFile != null;
  }
}