import 'package:bovicheck/services/database_service.dart'; // ADICIONADO
import 'package:bovicheck/services/pdf_export_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dashboard_controller.dart';
// import '../../services/json_storage_service.dart'; // REMOVIDO
import '../../services/spreadsheet_service.dart';
import '../../services/user_activity_service.dart';

class DataSettingsView extends StatefulWidget {
  const DataSettingsView({super.key});

  @override
  State<DataSettingsView> createState() => _DataSettingsViewState();
}

class _DataSettingsViewState extends State<DataSettingsView> {
  bool _isExporting = false;
  bool _isGeneratingPdf = false;

  Future<void> _exportAllDataToExcel() async {
    UserActivityService.instance.logAction('action:ExportToExcel');

    setState(() => _isExporting = true);

    final spreadsheetService = SpreadsheetService();
    final success = await spreadsheetService.exportAllData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Planilha salva com sucesso!'
              : 'Exportação cancelada ou sem dados para exportar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => _isExporting = false);
  }

  Future<void> _exportHerdReportToPdf() async {
    setState(() => _isGeneratingPdf = true);

    final pdfService = PdfExportService();
    await pdfService.generateAndShareHerdReport();

    if (mounted) {
      setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados do Aplicativo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          ListTile(
            leading: const Icon(Icons.security_update_good_outlined),
            title: const Text('Backup e Restauração'),
            subtitle:
                const Text('Crie ou restaure um backup local dos seus dados.'),
            onTap: () {
              Navigator.pushNamed(context, '/settings/backup');
            },
          ),
          ListTile(
            leading: _isExporting
                ? const SizedBox(
                    width: 24, height: 24, child: CircularProgressIndicator())
                : const Icon(Icons.description_outlined),
            title: const Text('Exportar Dados para Planilha'),
            subtitle:
                const Text('Salva todos os registros em um arquivo .xlsx.'),
            onTap: _isExporting ? null : _exportAllDataToExcel,
          ),
          ListTile(
            leading: _isGeneratingPdf
                ? const SizedBox(
                    width: 24, height: 24, child: CircularProgressIndicator())
                : const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('Exportar Relatório em PDF'),
            subtitle:
                const Text('Gera um relatório completo do rebanho em PDF.'),
            onTap: _isGeneratingPdf ? null : _exportHerdReportToPdf,
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error),
            title: const Text('Apagar Todos os Dados'),
            subtitle: const Text(
                'Inclui animais, lotes e configurações. Esta ação não pode ser desfeita.'),
            onTap: () => _showClearDataConfirmationDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearDataConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão Total'),
          content: const Text(
              'Você tem certeza que deseja apagar permanentemente TODOS os dados do aplicativo?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
              child: const Text('Apagar Tudo'),
              onPressed: () async {
                await DatabaseService.instance.clearAllData();
                if (dialogContext.mounted) {
                  Provider.of<DashboardController>(dialogContext, listen: false)
                      .fetchDashboardData();
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos os dados foram apagados.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
