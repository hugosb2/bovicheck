import 'package:bovicheck/models/propriedade.dart';
import 'package:bovicheck/services/database_service.dart';
import 'package:bovicheck/views/propriedade/propriedade_form_view.dart';
import 'package:flutter/material.dart';

class PropriedadeManagementView extends StatefulWidget {
  const PropriedadeManagementView({super.key});

  @override
  State<PropriedadeManagementView> createState() =>
      _PropriedadeManagementViewState();
}

class _PropriedadeManagementViewState extends State<PropriedadeManagementView> {
  late Future<List<Propriedade>> _propriedadesFuture;

  @override
  void initState() {
    super.initState();
    _loadPropriedades();
  }

  void _loadPropriedades() {
    setState(() {
      _propriedadesFuture = DatabaseService.instance.getAllPropriedades();
    });
  }

  Future<void> _navigateToAddForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PropriedadeFormView()),
    );
    _loadPropriedades();
  }

  Future<void> _navigateToEditForm(Propriedade prop) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PropriedadeFormView(propriedade: prop)),
    );
    _loadPropriedades();
  }

  Future<void> _deletePropriedade(Propriedade prop) async {
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentContext = context;

    final canDelete =
        !await DatabaseService.instance.isPropriedadeInUse(prop.id);

    if (!currentContext.mounted) return;

    if (!canDelete) {
      showDialog(
        context: currentContext,
        builder: (ctx) => AlertDialog(
          title: const Text('Exclusão Bloqueada'),
          content: Text(
              'Não é possível apagar a propriedade "${prop.nome}", pois ela já está vinculada a um ou mais lotes. Remova os lotes primeiro.'),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendi')),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: currentContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content:
            Text('Tem certeza que deseja apagar a propriedade "${prop.nome}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.instance.deletePropriedade(prop.id);
      _loadPropriedades();
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Propriedade apagada.'),
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Propriedades'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: FutureBuilder<List<Propriedade>>(
        future: _propriedadesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child:
                    Text('Erro ao carregar propriedades: ${snapshot.error}'));
          }

          final propriedades = snapshot.data ?? [];

          if (propriedades.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma propriedade criada.\nToque em + para adicionar.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            );
          }

          return ListView.separated(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: propriedades.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final prop = propriedades[index];
              String subtitle = '${prop.cidade}, ${prop.estado}';
              String proprietario = 'Proprietário: ${prop.proprietario}';
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(100)),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    child: const Icon(Icons.home_work_outlined, size: 20),
                  ),
                  title: Text(prop.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$subtitle\n$proprietario'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar',
                        onPressed: () => _navigateToEditForm(prop),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: theme.colorScheme.error),
                        tooltip: 'Apagar',
                        onPressed: () => _deletePropriedade(prop),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
