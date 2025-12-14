import 'package:bovicheck/servicos/pdf_export_service.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class TelaExportacaoPdf extends StatefulWidget {
  const TelaExportacaoPdf({super.key});

  @override
  State<TelaExportacaoPdf> createState() => _TelaExportacaoPdfState();
}

class _TelaExportacaoPdfState extends State<TelaExportacaoPdf> {
  bool _exportAnimals = true;
  bool _exportPropriedades = true;
  bool _exportAreasPastagem = true;
  bool _exportLotes = true;
  bool _exportIndicators = true;
  bool _isExporting = false;

  Future<void> _exportData() async {
    if (!_exportAnimals &&
        !_exportPropriedades &&
        !_exportAreasPastagem &&
        !_exportLotes &&
        !_exportIndicators) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione pelo menos uma opção para exportar.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isExporting = true);

    try {
      final pdfService = PdfExportService();
      final pdfBytes = await pdfService.generateSelectedPdf(
        exportAnimals: _exportAnimals,
        exportPropriedades: _exportPropriedades,
        exportAreasPastagem: _exportAreasPastagem,
        exportLotes: _exportLotes,
        exportIndicators: _exportIndicators,
      );

      if (mounted) {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename:
              'BoviCheck_Relatorio_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF exportado com sucesso!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar PDF: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar para PDF'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Selecione os dados que deseja exportar:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Resumo de Animais'),
            subtitle: const Text('Tabela com dados básicos dos animais'),
            value: _exportAnimals,
            onChanged: (value) {
              setState(() {
                _exportAnimals = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Propriedades Rurais'),
            subtitle: const Text('Informações sobre as propriedades'),
            value: _exportPropriedades,
            onChanged: (value) {
              setState(() {
                _exportPropriedades = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Áreas de Pastagem'),
            subtitle: const Text('Detalhes das áreas de pastagem'),
            value: _exportAreasPastagem,
            onChanged: (value) {
              setState(() {
                _exportAreasPastagem = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Lotes'),
            subtitle: const Text('Informações dos lotes cadastrados'),
            value: _exportLotes,
            onChanged: (value) {
              setState(() {
                _exportLotes = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Índices Produtivos'),
            subtitle: const Text('Índices e indicadores cadastrados'),
            value: _exportIndicators,
            onChanged: (value) {
              setState(() {
                _exportIndicators = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              textStyle: theme.textTheme.titleMedium,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: _isExporting ? null : _exportData,
            child: _isExporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Exportar PDF'),
          ),
        ],
      ),
    );
  }
}

class PdfExportView extends TelaExportacaoPdf {
  const PdfExportView({super.key}) : super();
}
