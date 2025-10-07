import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bovicheck/providers/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/json_storage_service.dart';
import '../../services/user_activity_service.dart'; // ADICIONADO

class BackupRestoreView extends StatefulWidget {
  const BackupRestoreView({super.key});

  @override
  State<BackupRestoreView> createState() => _BackupRestoreViewState();
}

class _BackupRestoreViewState extends State<BackupRestoreView> {
  bool _isLoading = false;

  Future<void> _createBackup() async {
    // ADICIONADO
    UserActivityService.instance.logAction('action:CreateBackup');

    final allData = JsonStorageService.instance.getAllData();
    if (allData.isEmpty) {
      _showSnackbar('Nenhum dado para fazer backup.');
      return;
    }
    // ... resto da função permanece igual
    final selectedOptions =
        await _showBackupOptionsDialog(allData.keys.toList());
    if (selectedOptions == null) return;

    final indicesToBackup = selectedOptions['indices'] as List<String>;
    final includeTheme = selectedOptions['theme'] as bool;

    if (indicesToBackup.isEmpty && !includeTheme) {
      _showSnackbar('Nenhuma opção selecionada para o backup.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final backupData = <String, dynamic>{};

      if (indicesToBackup.isNotEmpty) {
        final calculations = {
          for (var key in indicesToBackup) key: allData[key]
        };
        backupData['calculations'] = calculations;
      }

      if (includeTheme) {
        if (mounted) {
          backupData['theme'] = context.read<ThemeProvider>().toMap();
        }
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
    // ADICIONADO
    UserActivityService.instance.logAction('action:RestoreBackup');

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bck'],
    );
    // ... resto da função permanece igual
    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final fileBytes = await File(result.files.single.path!).readAsBytes();
      final jsonString = utf8.decode(fileBytes);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      if (backupData.containsKey('calculations')) {
        final data = backupData['calculations'] as Map<String, dynamic>;
        await JsonStorageService.instance.restoreAllData(data);
      }

      if (backupData.containsKey('theme')) {
        if (mounted) {
          final themeData = backupData['theme'] as Map<String, dynamic>;
          await context.read<ThemeProvider>().fromMap(themeData);
        }
      }
      _showSnackbar('Backup restaurado com sucesso!');
    } catch (e) {
      _showSnackbar('Erro ao restaurar backup: Arquivo inválido ou corrompido.',
          isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ... O resto do arquivo (dialogs, build method) permanece o mesmo
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

  Future<Map<String, dynamic>?> _showBackupOptionsDialog(
      List<String> allIndices) async {
    final selectedIndices = <String>{...allIndices};
    bool includeTheme = true;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Opções de Backup'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selecione os dados para incluir:'),
                    const Divider(),
                    CheckboxListTile(
                      title: const Text('Preferências de Tema'),
                      value: includeTheme,
                      onChanged: (value) =>
                          setDialogState(() => includeTheme = value!),
                    ),
                    const Divider(),
                    ...allIndices.map((indice) {
                      return CheckboxListTile(
                        title: Text(indice),
                        value: selectedIndices.contains(indice),
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedIndices.add(indice);
                            } else {
                              selectedIndices.remove(indice);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'indices': selectedIndices.toList(),
                      'theme': includeTheme,
                    });
                  },
                  child: const Text('Criar Backup'),
                ),
              ],
            );
          },
        );
      },
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
                  subtitle: const Text(
                      'Salva os dados de índices e temas em um arquivo .bck no seu dispositivo.'),
                  onTap: _createBackup,
                ),
                ListTile(
                  leading: const Icon(Icons.history_edu_outlined),
                  title: const Text('Restaurar de um Backup'),
                  subtitle: const Text(
                      'Carrega os dados de um arquivo de backup .bck salvo anteriormente.'),
                  onTap: _restoreBackup,
                ),
              ],
            ),
    );
  }
}