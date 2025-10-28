import 'package:bovicheck/views/analysis_history_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/dashboard_controller.dart';
import '../services/spreadsheet_service.dart';
import '../widgets/ai_analysis_card.dart';
import '../widgets/app_drawer.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final Map<String, Map<String, dynamic>> metricDetails = {
    'birthRate': {'title': 'Taxa de Natalidade', 'unit': '%'},
    'pregnancyRate': {'title': 'Taxa de Prenhez', 'unit': '%'},
    'weaningRate': {'title': 'Taxa de Desmame', 'unit': '%'},
    'mortalityRate': {'title': 'Taxa de Mortalidade', 'unit': '%'},
    'averageAgeAtFirstCalving': {
      'title': 'Idade ao 1º Parto',
      'unit': ' meses'
    },
    'averageCalvingInterval': {
      'title': 'Intervalo Entre Partos',
      'unit': ' dias'
    },
    'averageAdgBirthToWeaning': {
      'title': 'GMD Nasc.-Desmame',
      'unit': ' kg/dia'
    },
    'averageDailyMilkProduction': {
      'title': 'Produção Leite/Vaca',
      'unit': ' L/dia'
    },
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardController>(context, listen: false)
          .fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final theme = Theme.of(context);

    final analysisEntries = controller.latestAnalysis.entries
        .where((entry) =>
            entry.value != null && metricDetails.containsKey(entry.key))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard BoviCheck'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: controller.fetchDashboardData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildWelcomeHeader(context),
            const SizedBox(height: 16),
            if (controller.dashboardAIAnalysis != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child:
                    AiAnalysisCard(analysis: controller.dashboardAIAnalysis!),
              ),
            _buildDashboardSummary(
              context,
              controller.animalCount,
              controller.loteCount,
              controller.propCount,
            ),
            const SizedBox(height: 24),
            _buildAcoesRapidas(context, controller),
            const SizedBox(height: 24),
            if (analysisEntries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Análise do Rebanho (Últimos 365 dias)',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Divider(height: 24),
                  ],
                ),
              ),
            if (controller.isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            else if (analysisEntries.isEmpty)
              _buildEmptyState(context)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: analysisEntries.length,
                itemBuilder: (context, index) {
                  final entry = analysisEntries[index];
                  final details = metricDetails[entry.key]!;
                  return _buildAnalysisCard(
                    context,
                    title: details['title'],
                    value: entry.value!,
                    unit: details['unit'],
                    indexKey: entry.key,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context, {
    required String title,
    required double value,
    required String unit,
    required String indexKey,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnalysisHistoryView(
                indexKey: indexKey,
                indexName: title,
                unit: unit,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcoesRapidas(
      BuildContext context, DashboardController controller) {
    final Map<String, Map<String, dynamic>> actionDetails = {
      'navigate:HerdIndicators': {
        'label': 'Indicadores do Rebanho',
        'icon': Icons.analytics_outlined,
        'action': () async {
          await Navigator.pushNamed(context, '/herd-indicators');
        }
      },
      'navigate:animals': {
        'label': 'Meu Rebanho',
        'icon': Icons.tag_outlined, // ÍCONE ALTERADO
        'action': () async {
          await Navigator.pushNamed(context, '/animals');
        }
      },
      'navigate:Settings': {
        'label': 'Configurações',
        'icon': Icons.settings_outlined,
        'action': () async {
          await Navigator.pushNamed(context, '/settings');
        }
      },
      'action:ExportToExcel': {
        'label': 'Exportar Planilha',
        'icon': Icons.description_outlined,
        'action': () async {
          final success = await SpreadsheetService().exportAllData();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(success ? 'Planilha salva!' : 'Exportação cancelada.'),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      },
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const Divider(height: 24),
        if (controller.mostUsedActions.isEmpty && !controller.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Use o app para ver seus atalhos mais usados aqui!',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        else
          Wrap(spacing: 12.0, runSpacing: 12.0, children: [
            FilledButton.tonalIcon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Novo Animal"),
              onPressed: () async {
                await Navigator.pushNamed(context, '/animals');
                controller.fetchDashboardData();
              },
            ),
            ...controller.mostUsedActions.map((actionId) {
              if (actionDetails.containsKey(actionId)) {
                final details = actionDetails[actionId]!;
                return FilledButton.tonalIcon(
                  icon: Icon(details['icon']),
                  label: Text(details['label']),
                  onPressed: () async {
                    await details['action']();
                    controller.fetchDashboardData();
                  },
                );
              }
              return const SizedBox.shrink();
            })
          ]),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Image.asset('assets/icon.png', height: 80, width: 80),
          const SizedBox(height: 16),
          Text(
            'BoviCheck',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bem-vindo ao seu painel de controle pecuário',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSummary(
      BuildContext context, int animalCount, int loteCount, int propCount) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
                context,
                Icons.tag_outlined, // ÍCONE ALTERADO
                animalCount.toString(),
                'Animais'),
            _buildSummaryItem(context, Icons.grid_view_outlined,
                loteCount.toString(), 'Lotes'),
            _buildSummaryItem(
                context,
                Icons.cottage_outlined, // Ícone para Propriedades
                propCount.toString(),
                'Propriedades'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.only(top: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum animal cadastrado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione animais ao seu rebanho para começar a ver as análises de produtividade aqui.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
