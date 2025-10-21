import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bovicheck/controllers/dashboard_controller.dart';
import 'package:bovicheck/providers/theme_provider.dart';
import 'package:bovicheck/services/database_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/user_activity_service.dart';

class BackupRestoreView extends StatefulWidget {
  const BackupRestoreView({super.key});

  @override
  State<BackupRestoreView> createState() => _BackupRestoreViewState();
}

class _BackupRestoreViewState extends State<BackupRestoreView> {
  bool _isLoading = false;

  Future<void> _createBackup() async {
    UserActivityService.instance.logAction('action:CreateBackup');
    setState(() => _isLoading = true);

    try {
      final allAnimals =
          await DatabaseService.instance.getAllAnimalsWithHistory();
      final allLotes = await DatabaseService.instance.getAllLotes();
      final allProps = await DatabaseService.instance.getAllPropriedades();
      final allSnapshots = await DatabaseService.instance.getAnalysisHistory();

      if (allAnimals.isEmpty &&
          allLotes.isEmpty &&
          allProps.isEmpty &&
          allSnapshots.isEmpty) {
        _showSnackbar('Nenhum dado para fazer backup.');
        setState(() => _isLoading = false);
        return;
      }

      final backupData = <String, dynamic>{};

      backupData['propriedades'] = allProps.map((e) => e.toJson()).toList();
      backupData['lotes'] = allLotes.map((e) => e.toJson()).toList();
      backupData['animals'] = allAnimals.map((e) => e.toJson()).toList();
      backupData['analysisHistory'] =
          allSnapshots.map((e) => e.toJson()).toList();

      if (mounted) {
        backupData['theme'] = context.read<ThemeProvider>().toMap();
      }

      final jsonString = jsonEncode(backupData);
      final Uint8List bytes = utf8.encode(jsonString);
      final fileName =
          'BoviCheck_Backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.bck';

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Por favor, selecione onde salvar o backup:',
        fileName: fileName,
        bytes: bytes,
      );

      if (outputFile != null) {
        _showSnackbar('Backup salvo com sucesso!');
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
      final fileBytes = await File(result.files.single.path!).readAsBytes();
      final jsonString = utf8.decode(fileBytes);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      await DatabaseService.instance.restoreFromBackup(backupData);

      if (backupData.containsKey('theme')) {
        if (mounted) {
          final themeData = backupData['theme'] as Map<String, dynamic>;
          await context.read<ThemeProvider>().fromMap(themeData);
        }
      }

      if (mounted) {
        await context.read<DashboardController>().fetchDashboardData();
      }

      _showSnackbar('Backup restaurado com sucesso!');
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
