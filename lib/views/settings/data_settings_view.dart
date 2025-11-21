import 'package:bovicheck/services/database_service.dart';
import 'package:bovicheck/services/pdf_export_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/dashboard_controller.dart';
import '../../services/spreadsheet_service.dart';
import '../../services/user_activity_service.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:bovicheck/providers/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class DataSettingsView extends StatefulWidget {
  const DataSettingsView({super.key});

  @override
  State<DataSettingsView> createState() => _DataSettingsViewState();
}

class _DataSettingsViewState extends State<DataSettingsView> {
  bool _isExporting = false;
  bool _isGeneratingPdf = false;
  bool _isLoadingJson = false;

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

  Future<void> _exportDebugJson() async {
    setState(() => _isLoadingJson = true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      final allAnimals =
          await DatabaseService.instance.getAllAnimalsWithHistory();
      final allLotes = await DatabaseService.instance.getAllLotes();
      final allProps = await DatabaseService.instance.getAllPropriedades();
      final allSnapshots = await DatabaseService.instance.getAnalysisHistory();

      final debugData = <String, dynamic>{};

      debugData['propriedades'] = allProps.map((e) => e.toJson()).toList();
      debugData['lotes'] = allLotes.map((e) => e.toJson()).toList();
      debugData['animals'] = allAnimals.map((e) => e.toJson()).toList();
      debugData['analysisHistory'] =
          allSnapshots.map((e) => e.toJson()).toList();

      if (mounted) {
        debugData['theme'] = context.read<ThemeProvider>().toMap();
      }

      const jsonEncoder = JsonEncoder.withIndent('  ');
      final jsonString = jsonEncoder.convert(debugData);
      final Uint8List bytes = utf8.encode(jsonString);

      final fileName =
          'BoviCheck_DebugData_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar JSON de Debug:',
        fileName: fileName,
      );

      if (outputFile == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Exportação cancelada.'),
              behavior: SnackBarBehavior.floating),
        );
      } else {
        final file = File(outputFile);
        await file.writeAsBytes(bytes);

        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Arquivo JSON de debug salvo!'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
            content: Text('Erro ao gerar JSON: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: theme.colorScheme.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingJson = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Variável de tema adicionada

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados do Aplicativo'),
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
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDataOption(
            context,
            icon: Icons.security_update_good_outlined,
            title: 'Backup e Restauração',
            subtitle: 'Crie ou restaure um backup local dos seus dados.',
            onTap: () => Navigator.pushNamed(context, '/settings/backup'),
            index: 0,
          ),
          const SizedBox(height: 12),
          _buildDataOption(
            context,
            icon: Icons.description_outlined,
            title: 'Exportar Dados para Planilha',
            subtitle: 'Salva todos os registros em um arquivo .xlsx.',
            onTap: _isExporting ? null : _exportAllDataToExcel,
            isLoading: _isExporting,
            index: 1,
          ),
          const SizedBox(height: 12),
          _buildDataOption(
            context,
            icon: Icons.picture_as_pdf_outlined,
            title: 'Exportar Relatório em PDF',
            subtitle: 'Gera um relatório completo do rebanho em PDF.',
            onTap: _isGeneratingPdf ? null : _exportHerdReportToPdf,
            isLoading: _isGeneratingPdf,
            index: 2,
          ),
          const SizedBox(height: 24),
          _buildDataOption(
            context,
            icon: Icons.delete_forever_outlined,
            title: 'Apagar Todos os Dados',
            subtitle: 'Inclui animais, lotes e configurações. Esta ação não pode ser desfeita.',
            onTap: () => _showClearDataConfirmationDialog(context),
            isDestructive: true,
            index: 3,
          ),

          const SizedBox(height: 24),
          Text(
            'Opções de Desenvolvedor',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDataOption(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Exportar JSON (Debug)',
            subtitle: 'Gera um arquivo .json legível com todos os dados do app.',
            onTap: _isLoadingJson ? null : _exportDebugJson,
            isLoading: _isLoadingJson,
            isSecondary: true,
            index: 4,
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

  Widget _buildDataOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required int index,
    bool isLoading = false,
    bool isDestructive = false,
    bool isSecondary = false,
  }) {
    final theme = Theme.of(context);
    final iconColor = isDestructive
        ? theme.colorScheme.error
        : (isSecondary
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.primary);

    return Card(
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: iconColor,
                          ),
                        )
                      : Icon(
                          icon,
                          color: iconColor,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSecondary
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideX(begin: 0.1, end: 0);
  }
}
