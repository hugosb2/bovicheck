import 'package:bovicheck/modelos/animal/animal.dart';
import 'package:bovicheck/modelos/area_pastagem.dart';
import 'package:bovicheck/modelos/herd_indicator.dart';
import 'package:bovicheck/modelos/lote.dart';
import 'package:bovicheck/modelos/propriedade.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  Future<void> generateAndShareHerdReport() async {
    final animals = await DatabaseService.instance.getAllAnimals();
    final lotes = await DatabaseService.instance.getAllLotes();
    final propriedades = await DatabaseService.instance.getAllPropriedades();
    final areasPastagem = await DatabaseService.instance.getAllAreaPastagens();
    final indicators = await DatabaseService.instance.getAllHerdIndicators();
    final pdf = await _generatePdf(
        animals, lotes, propriedades, areasPastagem, indicators);

    await Printing.sharePdf(
      bytes: pdf,
      filename:
          'BoviCheck_Relatorio_Completo_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  Future<Uint8List> _generatePdf(
    List<Animal> animals,
    List<Lote> lotes,
    List<Propriedade> propriedades,
    List<AreaPastagem> areasPastagem,
    List<HerdIndicator> indicators,
  ) async {
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
          if (propriedades.isNotEmpty) ...[
            _buildPropriedadesSection(propriedades, font, boldFont, dateFormat),
            pw.SizedBox(height: 20),
          ],
          if (areasPastagem.isNotEmpty) ...[
            _buildPastureAreasSection(areasPastagem, font, boldFont),
            pw.SizedBox(height: 20),
          ],
          if (lotes.isNotEmpty) ...[
            _buildLotesSection(lotes, font, boldFont),
            pw.SizedBox(height: 20),
          ],
          _buildAnimalTable(animals, font, boldFont, dateFormat),
          if (indicators.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildIndicatorsSection(indicators, font, boldFont, dateFormat),
          ],
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
        pw.TableHelper.fromTextArray(
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

  pw.Widget _buildPropriedadesSection(List<Propriedade> propriedades,
      pw.Font font, pw.Font boldFont, DateFormat dateFormat) {
    final headers = [
      'Nome',
      'Proprietário',
      'Município',
      'Estado',
      'Área Total (ha)'
    ];
    final data = propriedades.map((prop) {
      return [
        prop.nome,
        prop.proprietario,
        prop.municipio,
        prop.estado,
        prop.areaTotal.toStringAsFixed(2),
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Propriedades Rurais',
            style: pw.TextStyle(font: boldFont, fontSize: 18)),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(),
          headerStyle:
              pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(font: font),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellHeight: 30,
        ),
      ],
    );
  }

  pw.Widget _buildPastureAreasSection(
      List<AreaPastagem> areas, pw.Font font, pw.Font boldFont) {
    final headers = ['Nome', 'Área Destinada (ha)', 'Descrição'];
    final data = areas.map((area) {
      return [
        area.nome,
        area.areaDestinada.toStringAsFixed(2),
        area.descricao ?? 'N/A',
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Áreas de Pastagem',
            style: pw.TextStyle(font: boldFont, fontSize: 18)),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(),
          headerStyle:
              pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(font: font),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellHeight: 30,
        ),
      ],
    );
  }

  pw.Widget _buildLotesSection(
      List<Lote> lotes, pw.Font font, pw.Font boldFont) {
    final headers = ['Nome', 'Descrição', 'Propriedade ID'];
    final data = lotes.map((lote) {
      return [
        lote.nome,
        lote.descricao ?? 'N/A',
        lote.propriedadeId,
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Lotes', style: pw.TextStyle(font: boldFont, fontSize: 18)),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(),
          headerStyle:
              pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(font: font),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellHeight: 30,
        ),
      ],
    );
  }

  pw.Widget _buildIndicatorsSection(List<HerdIndicator> indicators,
      pw.Font font, pw.Font boldFont, DateFormat dateFormat) {
    final headers = ['Índice', 'Unidade', 'Aplicação', 'Data de Criação'];
    final data = indicators.map((ind) {
      final applications = <String>[];
      if (ind.applyToLote) applications.add('Lote');
      if (ind.applyToProperty) applications.add('Propriedade');
      return [
        ind.indicatorTitle,
        ind.indicatorUnit,
        applications.join(', '),
        dateFormat.format(ind.createdAt),
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Índices Produtivos',
            style: pw.TextStyle(font: boldFont, fontSize: 18)),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(),
          headerStyle:
              pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(font: font),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellHeight: 30,
        ),
      ],
    );
  }
}
