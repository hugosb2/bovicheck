// lib/services/pdf_export_service.dart

import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/services/json_storage_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  Future<void> generateAndShareHerdReport() async {
    final animals = JsonStorageService.instance.getAllAnimals();
    final pdf = await _generatePdf(animals);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf,
      name:
          'BoviCheck_Relatorio_Rebanho_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  Future<Uint8List> _generatePdf(List<Animal> animals) async {
    final doc = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/icon.png')).buffer.asUint8List(),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader(logo),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildTitle(boldFont),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 20),
          _buildSummary(animals, font, boldFont),
          pw.SizedBox(height: 20),
          _buildAnimalTable(animals, font, boldFont, dateFormat),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _buildHeader(pw.MemoryImage logo) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
      padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Image(logo, height: 30),
              pw.SizedBox(width: 8),
              pw.Text('BoviCheck - Relatório do Rebanho'),
            ],
          ),
          pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: pw.Theme.of(context)
            .defaultTextStyle
            .copyWith(color: PdfColors.grey),
      ),
    );
  }

  pw.Widget _buildTitle(pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 1 * PdfPageFormat.cm),
        pw.Text(
          'Relatório Geral do Rebanho',
          style: pw.TextStyle(font: boldFont, fontSize: 24),
        ),
        pw.SizedBox(height: 0.5 * PdfPageFormat.cm),
      ],
    );
  }

  pw.Widget _buildSummary(
      List<Animal> animals, pw.Font font, pw.Font boldFont) {
    final total = animals.length;
    final females = animals.where((a) => a.sexo == 'Fêmea').length;
    final males = animals.where((a) => a.sexo == 'Macho').length;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Resumo', style: pw.TextStyle(font: boldFont, fontSize: 18)),
        pw.SizedBox(height: 8),
        pw.RichText(
          text: pw.TextSpan(
            style: pw.TextStyle(font: font, fontSize: 12),
            children: [
              pw.TextSpan(
                  text: 'Total de Animais: ',
                  style: pw.TextStyle(font: boldFont)),
              pw.TextSpan(text: '$total'),
            ],
          ),
        ),
        pw.RichText(
          text: pw.TextSpan(
            style: pw.TextStyle(font: font, fontSize: 12),
            children: [
              pw.TextSpan(
                  text: 'Fêmeas: ', style: pw.TextStyle(font: boldFont)),
              pw.TextSpan(text: '$females'),
            ],
          ),
        ),
        pw.RichText(
          text: pw.TextSpan(
            style: pw.TextStyle(font: font, fontSize: 12),
            children: [
              pw.TextSpan(
                  text: 'Machos: ', style: pw.TextStyle(font: boldFont)),
              pw.TextSpan(text: '$males'),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildAnimalTable(List<Animal> animals, pw.Font font,
      pw.Font boldFont, DateFormat dateFormat) {
    final headers = ['Brinco', 'Nome', 'Data Nasc.', 'Sexo', 'Raça', 'Status'];

    final data = animals.map((animal) {
      return [
        animal.brinco,
        animal.nome ?? 'N/A',
        dateFormat.format(animal.dataNascimento),
        animal.sexo,
        animal.raca ?? 'N/A',
        animal.status.name,
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Lista de Animais',
            style: pw.TextStyle(font: boldFont, fontSize: 18)),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(),
          headerStyle:
              pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(font: font),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellHeight: 30,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerLeft,
            2: pw.Alignment.center,
            3: pw.Alignment.center,
            4: pw.Alignment.centerLeft,
            5: pw.Alignment.center,
          },
        ),
      ],
    );
  }
}
