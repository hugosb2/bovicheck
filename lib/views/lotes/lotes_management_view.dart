import 'package:bovicheck/controllers/dashboard_controller.dart';
import 'package:bovicheck/models/lote.dart';
import 'package:bovicheck/models/propriedade.dart';
import 'package:bovicheck/services/database_service.dart';
import 'package:bovicheck/styles/app_icons.dart';
import 'package:bovicheck/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class LotesManagementView extends StatefulWidget {
  const LotesManagementView({super.key});

  @override
  State<LotesManagementView> createState() => _LotesManagementViewState();
}

class _LotesManagementViewState extends State<LotesManagementView> {
  late Future<List<Lote>> _lotesFuture;
  late Future<List<Propriedade>> _propriedadesFuture;
  Map<String, String> _propriedadeNomes = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _lotesFuture = DatabaseService.instance.getAllLotes();
      _propriedadesFuture = DatabaseService.instance.getAllPropriedades();
      _propriedadesFuture.then((props) {
        _propriedadeNomes = {for (var p in props) p.id: p.nome};
      });
    });
  }

  String _getPropriedadeNome(String propriedadeId) {
    return _propriedadeNomes[propriedadeId] ?? 'Propriedade não encontrada';
  }

  Future<void> _showLoteDialog(
      {Lote? lote, required List<Propriedade> propriedades}) async {
    final isEditing = lote != null;
    final formKey = GlobalKey<FormState>();
    String nome = lote?.nome ?? '';
    String descricao = lote?.descricao ?? '';
    String? selectedPropriedadeId = lote?.propriedadeId;

    if (selectedPropriedadeId != null &&
        !propriedades.any((p) => p.id == selectedPropriedadeId)) {
      selectedPropriedadeId = null;
    }
    if (!isEditing &&
        propriedades.isNotEmpty &&
        selectedPropriedadeId == null) {
      selectedPropriedadeId = propriedades.first.id;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Lote' : 'Novo Lote'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedPropriedadeId,
                      decoration:
                          const InputDecoration(labelText: 'Propriedade *'),
                      items: propriedades.map((prop) {
                        return DropdownMenuItem(
                          value: prop.id,
                          child: Text(prop.nome),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedPropriedadeId = v),
                      validator: (v) =>
                          v == null ? 'Propriedade é obrigatória' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: nome,
                      decoration:
                          const InputDecoration(labelText: 'Nome do Lote *'),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                      onSaved: (v) => nome = v!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: descricao,
                      decoration: const InputDecoration(
                          labelText: 'Descrição (Opcional)'),
                      onSaved: (v) => descricao = v ?? '',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar')),
                FilledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      final newLote = Lote(
                        id: lote?.id ?? const Uuid().v4(),
                        nome: nome,
                        descricao: descricao,
                        propriedadeId: selectedPropriedadeId!,
                      );
                      await DatabaseService.instance.addOrUpdateLote(newLote);
                      _loadData();
                      if (mounted) {
                        Provider.of<DashboardController>(context, listen: false)
                            .fetchDashboardData();
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteLote(Lote lote) async {
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentContext = context;

    final confirmed = await showDialog<bool>(
      context: currentContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Tem certeza que deseja apagar o lote "${lote.nome}"? Os animais neste lote ficarão sem lote associado.'),
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
      await DatabaseService.instance.deleteLote(lote.id);
      _loadData();
      if (mounted) {
        Provider.of<DashboardController>(context, listen: false)
            .fetchDashboardData();

        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Lote apagado.'),
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _onFabPressed(List<Propriedade> propriedades) async {
    final currentContext = context;
    if (propriedades.isEmpty) {
      showDialog(
        context: currentContext,
        builder: (ctx) => AlertDialog(
          title: const Text('Nenhuma Propriedade Encontrada'),
          content: const Text(
              'Você precisa cadastrar uma Propriedade Rural antes de poder adicionar um Lote.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/settings/propriedades');
              },
              child: const Text('Cadastrar Propriedade'),
            ),
          ],
        ),
      );
    } else {
      _showLoteDialog(propriedades: propriedades);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Lotes'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_lotesFuture, _propriedadesFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar dados: ${snapshot.error}'));
          }

          final lotes = (snapshot.data?[0] as List<Lote>?) ?? [];
          final propriedades = (snapshot.data?[1] as List<Propriedade>?) ?? [];

          if (_propriedadeNomes.isEmpty && propriedades.isNotEmpty) {
            _propriedadeNomes = {for (var p in propriedades) p.id: p.nome};
          }

          if (lotes.isEmpty) {
            return Center(
              child: Text(
                'Nenhum lote criado.\nToque em + para adicionar.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            );
          }

          return ListView.separated(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: lotes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final lote = lotes[index];
              final nomePropriedade = _getPropriedadeNome(lote.propriedadeId);

              return Card(
                // Estilo já vem do AppTheme
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    foregroundColor: theme.colorScheme.onTertiaryContainer,
                    child: const Icon(AppIcons.loteAvatar, size: 20),
                  ),
                  title: Text(lote.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(nomePropriedade),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(AppIcons.edit),
                        tooltip: 'Editar',
                        onPressed: () => _showLoteDialog(
                            lote: lote, propriedades: propriedades),
                      ),
                      IconButton(
                        icon: Icon(AppIcons.delete,
                            color: theme.colorScheme.error),
                        tooltip: 'Apagar',
                        onPressed: () => _deleteLote(lote),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<Propriedade>>(
          future: _propriedadesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox.shrink();
            }
            final propriedades = snapshot.data ?? [];
            return FloatingActionButton(
              onPressed: () => _onFabPressed(propriedades),
              child: const Icon(AppIcons.add),
            );
          }),
    );
  }
}
