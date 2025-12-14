import 'package:bovicheck/modelos/herd_indicator.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:bovicheck/estilos/app_icons.dart';
import 'package:bovicheck/telas/herd_indicator_detail_view.dart';
import 'package:bovicheck/telas/herd_indicator_form_view.dart';
import 'package:bovicheck/componentes/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HerdIndicatorsView extends StatefulWidget {
  const HerdIndicatorsView({super.key});

  @override
  State<HerdIndicatorsView> createState() => _HerdIndicatorsViewState();
}

class _HerdIndicatorsViewState extends State<HerdIndicatorsView> {
  late Future<List<HerdIndicator>> _indicatorsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _indicatorsFuture = DatabaseService.instance.getAllHerdIndicators();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicadores do Rebanho'),
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
      body: FutureBuilder<List<HerdIndicator>>(
        future: _indicatorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar dados: ${snapshot.error}'));
          }

          final indicators = snapshot.data ?? [];

          if (indicators.isEmpty) {
            return Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 80,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Nenhum indicador adicionado.\nToque em + para adicionar.',
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
            itemCount: indicators.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final indicator = indicators[index];
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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HerdIndicatorDetailView(
                            indicatorId: indicator.id,
                          ),
                        ),
                      );
                      _loadData();
                    },
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
                              Icons.bar_chart,
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
                                  indicator.indicatorTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_getApplicationText(indicator)} • ${indicator.indicatorUnit}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HerdIndicatorFormView(),
            ),
          );
          _loadData();
        },
        icon: const Icon(AppIcons.add),
        label: const Text('Adicionar Índice'),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
    );
  }

  String _getApplicationText(HerdIndicator indicator) {
    final parts = <String>[];
    if (indicator.applyToLote) parts.add('Lote');
    if (indicator.applyToProperty) parts.add('Propriedade');
    return parts.join(', ');
  }
}
