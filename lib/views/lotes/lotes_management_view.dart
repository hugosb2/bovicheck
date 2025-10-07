// lib/views/lotes/lotes_management_view.dart

import 'package:bovicheck/models/lote.dart';
import 'package:bovicheck/services/json_storage_service.dart';
import 'package:bovicheck/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class LotesManagementView extends StatefulWidget {
  const LotesManagementView({super.key});

  @override
  State<LotesManagementView> createState() => _LotesManagementViewState();
}

class _LotesManagementViewState extends State<LotesManagementView> {
  List<Lote> _lotes = [];

  @override
  void initState() {
    super.initState();
    _loadLotes();
  }

  void _loadLotes() {
    setState(() {
      _lotes = JsonStorageService.instance.getAllLotes();
    });
  }

  Future<void> _showLoteDialog({Lote? lote}) async {
    final isEditing = lote != null;
    final formKey = GlobalKey<FormState>();
    String nome = lote?.nome ?? '';
    String descricao = lote?.descricao ?? '';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Lote' : 'Novo Lote'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nome,
                  decoration: const InputDecoration(labelText: 'Nome do Lote'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  onSaved: (v) => nome = v!,
                ),
                TextFormField(
                  initialValue: descricao,
                  decoration: const InputDecoration(labelText: 'Descrição (Opcional)'),
                  onSaved: (v) => descricao = v ?? '',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final newLote = Lote(
                    id: lote?.id ?? const Uuid().v4(),
                    nome: nome,
                    descricao: descricao,
                  );
                  await JsonStorageService.instance.addOrUpdateLote(newLote);
                  _loadLotes();
                  if(mounted) Navigator.pop(dialogContext);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteLote(Lote lote) async {
    // Captura o context antes do await
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja apagar o lote "${lote.nome}"? Os animais neste lote ficarão sem lote.'),
        actions: [
          TextButton(onPressed: () => navigator.pop(false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            onPressed: () => navigator.pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await JsonStorageService.instance.deleteLote(lote.id);
      _loadLotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Lotes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: const AppDrawer(),
      body: _lotes.isEmpty
          ? const Center(child: Text('Nenhum lote criado. Toque em + para adicionar.'))
          : ListView.builder(
              itemCount: _lotes.length,
              itemBuilder: (context, index) {
                final lote = _lotes[index];
                return ListTile(
                  title: Text(lote.nome),
                  subtitle: Text(lote.descricao ?? 'Sem descrição'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showLoteDialog(lote: lote)),
                      IconButton(icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error), onPressed: () => _deleteLote(lote)),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}