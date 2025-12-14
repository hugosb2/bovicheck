import 'package:bovicheck/servicos/spreadsheet_service.dart';
import 'package:flutter/material.dart';

class TelaExportacaoPlanilha extends StatefulWidget {
  const TelaExportacaoPlanilha({super.key});

  @override
  State<TelaExportacaoPlanilha> createState() => _TelaExportacaoPlanilhaState();
}

class _TelaExportacaoPlanilhaState extends State<TelaExportacaoPlanilha> {
  bool _exportAnimals = true;
  bool _exportIndicators = true;
  bool _isExporting = false;

  Future<void> _exportData() async {
    if (!_exportAnimals && !_exportIndicators) {
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

    final spreadsheetService = SpreadsheetService();
    final success = await spreadsheetService.exportSelectedData(
      exportAnimals: _exportAnimals,
      exportIndicators: _exportIndicators,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Planilha salva com sucesso!'
              : 'Exportação cancelada ou sem dados para exportar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (success) {
        Navigator.pop(context);
      }
    }

    setState(() => _isExporting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar para Planilha'),
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
            title: const Text('Lista de Animais'),
            subtitle: const Text('Dados básicos e histórico dos animais'),
            value: _exportAnimals,
            onChanged: (value) {
              setState(() {
                _exportAnimals = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Índices Produtivos'),
            subtitle: const Text('Índices cadastrados e seus valores'),
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
                : const Text('Exportar Planilha'),
          ),
        ],
      ),
    );
  }
}

class SpreadsheetExportView extends TelaExportacaoPlanilha {
  const SpreadsheetExportView({super.key}) : super();
}
