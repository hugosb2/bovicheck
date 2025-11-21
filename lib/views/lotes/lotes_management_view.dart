import 'package:bovicheck/controllers/dashboard_controller.dart';
import 'package:bovicheck/models/lote.dart';
import 'package:bovicheck/models/propriedade.dart';
import 'package:bovicheck/services/database_service.dart';
import 'package:bovicheck/styles/app_icons.dart';
import 'package:bovicheck/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';

// 1. IMPORTE A NOVA TELA DE DETALHE
import 'lote_detail_view.dart';

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
        if (mounted) {
          // Adiciona verificação de 'mounted'
          setState(() {
            _propriedadeNomes = {for (var p in props) p.id: p.nome};
          });
        }
      });
    });
  }

  String _getPropriedadeNome(String propriedadeId) {
    return _propriedadeNomes[propriedadeId] ?? 'Propriedade não encontrada';
  }

  // 2. CRIE O MÉTODO DE NAVEGAÇÃO PARA O DETALHE
  Future<void> _navigateToDetailView(Lote lote) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoteDetailView(loteId: lote.id)),
    );
    _loadData();
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
                      decoration: InputDecoration(
                        labelText: 'Propriedade *',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
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
                      decoration: InputDecoration(
                        labelText: 'Nome do Lote *',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                      onSaved: (v) => nome = v!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: descricao,
                      decoration: InputDecoration(
                        labelText: 'Descrição (Opcional)',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
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
                    onTap: () => _navigateToDetailView(lote),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.tertiaryContainer,
                                  theme.colorScheme.tertiaryContainer.withOpacity(0.7),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.tertiary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              AppIcons.loteAvatar,
                              size: 24,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lote.nome,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nomePropriedade,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
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
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.primary,
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
            return FloatingActionButton.extended(
              onPressed: () => _onFabPressed(propriedades),
              icon: const Icon(AppIcons.add),
              label: const Text('Novo Lote'),
              elevation: 4,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .scale(begin: const Offset(0, 0), end: const Offset(1, 1));
          }),
    );
  }
}
