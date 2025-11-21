import 'package:bovicheck/controllers/dashboard_controller.dart';
import 'package:bovicheck/models/propriedade.dart';
import 'package:bovicheck/services/database_service.dart';
import 'package:bovicheck/styles/app_icons.dart';
import 'package:bovicheck/views/propriedade/propriedade_form_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

// 1. IMPORTE A NOVA TELA DE DETALHE
import 'propriedade_detail_view.dart';

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
    if (mounted) {
      Provider.of<DashboardController>(context, listen: false)
          .fetchDashboardData();
    }
  }

  Future<void> _navigateToEditForm(Propriedade prop) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PropriedadeFormView(propriedade: prop)),
    );
    _loadPropriedades();
    if (mounted) {
      Provider.of<DashboardController>(context, listen: false)
          .fetchDashboardData();
    }
  }

  // 2. CRIE O MÉTODO DE NAVEGAÇÃO PARA O DETALHE
  Future<void> _navigateToDetailView(Propriedade prop) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PropriedadeDetailView(propriedadeId: prop.id)),
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
        Provider.of<DashboardController>(context, listen: false)
            .fetchDashboardData();

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
                    onTap: () => _navigateToDetailView(prop),
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
                                  theme.colorScheme.secondaryContainer,
                                  theme.colorScheme.secondaryContainer.withOpacity(0.7),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.secondary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              AppIcons.propertyAvatar,
                              size: 24,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prop.nome,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  proprietario,
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
                                onPressed: () => _navigateToEditForm(prop),
                              ),
                              IconButton(
                                icon: Icon(AppIcons.delete,
                                    color: theme.colorScheme.error),
                                tooltip: 'Apagar',
                                onPressed: () => _deletePropriedade(prop),
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
        onPressed: _navigateToAddForm,
        icon: const Icon(AppIcons.add),
        label: const Text('Nova Propriedade'),
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
