import 'package:bovicheck/controladores/dashboard_controller.dart';
import 'package:bovicheck/modelos/lote.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:bovicheck/estilos/app_icons.dart';
import 'package:bovicheck/componentes/app_drawer.dart';
import 'package:bovicheck/telas/lotes/lote_form_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  Map<String, String> _propriedadeNomes = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _lotesFuture = DatabaseService.instance.getAllLotes();
      _loadPropriedadeNomes();
    });
  }

  Future<void> _loadPropriedadeNomes() async {
    final props = await DatabaseService.instance.getAllPropriedades();
    if (mounted) {
      setState(() {
        _propriedadeNomes = {for (var p in props) p.id: p.nome};
      });
    }
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

  Future<void> _navigateToForm({Lote? lote}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoteFormView(lote: lote),
      ),
    );
    _loadData();
    if (mounted) {
      Provider.of<DashboardController>(context, listen: false)
          .fetchDashboardData();
    }
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

  Future<void> _onFabPressed() async {
    _navigateToForm();
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
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Lote>>(
        future: _lotesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar dados: ${snapshot.error}'));
          }

          final lotes = snapshot.data ?? [];

          if (lotes.isEmpty) {
            return Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nenhum lote criado.\nToque em + para adicionar.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 100,
                  right: 20,
                  child: Icon(
                    Icons.arrow_downward,
                    size: 40,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ).animate(onPlay: (controller) => controller.repeat()).moveY(
                      begin: 0,
                      end: 10,
                      duration: 1000.ms,
                      curve: Curves.easeInOut),
                ),
              ],
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
                shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _navigateToDetailView(lote),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                                  theme.colorScheme.tertiaryContainer
                                      .withValues(alpha: 0.7),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.tertiary
                                      .withValues(alpha: 0.2),
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
                                onPressed: () => _navigateToForm(lote: lote),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        icon: const Icon(AppIcons.add),
        label: const Text('Novo Lote'),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
    );
  }
}
