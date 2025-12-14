import 'dart:io';
import 'dart:typed_data';
import 'package:bovicheck/controladores/dashboard_controller.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../servicos/user_activity_service.dart';

class TelaBackupRestauro extends StatefulWidget {
  const TelaBackupRestauro({super.key});

  @override
  State<TelaBackupRestauro> createState() => _TelaBackupRestauroState();
}

class _TelaBackupRestauroState extends State<TelaBackupRestauro> {
  bool _isLoading = false;

  Future<void> _createBackup() async {
    UserActivityService.instance.logAction('action:CreateBackup');
    setState(() => _isLoading = true);

    try {
      // Export the SQLite DB file bytes and save to a backup file
      final Uint8List bytes =
          await DatabaseService.instance.exportDatabaseAsBytes();
      final fileName =
          'BoviCheck_Backup_DB_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.db';

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Por favor, selecione onde salvar o backup:',
        fileName: fileName,
        bytes: bytes,
      );

      if (outputFile != null) {
        _showSnackbar('Backup do banco salvo com sucesso!');
      } else {
        _showSnackbar('Operação de backup cancelada.');
      }
    } catch (e) {
      _showSnackbar('Erro ao criar backup: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restoreBackup() async {
    UserActivityService.instance.logAction('action:RestoreBackup');
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bck'],
    );
    if (result == null) return;
    setState(() => _isLoading = true);
    try {
      // Read raw DB bytes and import into the active database
      final fileBytes = await File(result.files.single.path!).readAsBytes();
      await DatabaseService.instance.importDatabaseFromBytes(fileBytes);

      if (mounted) {
        await context.read<DashboardController>().fetchDashboardData();
      }

      _showSnackbar('Backup do banco restaurado com sucesso!');
    } catch (e) {
      _showSnackbar('Erro ao restaurar backup: Arquivo inválido ou corrompido.',
          isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup e Restauração'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(8),
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined),
                  title: const Text('Criar Backup Local'),
                  subtitle:
                      const Text('Salva todos os dados em um arquivo .bck.'),
                  onTap: _createBackup,
                ),
                ListTile(
                  leading: const Icon(Icons.history_edu_outlined),
                  title: const Text('Restaurar de um Backup'),
                  subtitle: const Text(
                      'Carrega os dados de um arquivo de backup .bck.'),
                  onTap: _restoreBackup,
                ),
              ],
            ),
    );
  }
}

class BackupRestoreView extends TelaBackupRestauro {
  const BackupRestoreView({super.key}) : super();
}
