// lib/views/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/dashboard_controller.dart';
import '../models/calculation_record.dart';
import '../services/json_storage_service.dart';
import '../services/spreadsheet_service.dart';
import '../widgets/ai_analysis_card.dart';
import '../widgets/app_drawer.dart';
import 'history_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardController>(context, listen: false)
          .fetchLatestRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard BoviCheck'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: controller.fetchLatestRecords,
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
            _buildDashboardSummary(context, controller.latestRecords),
            const SizedBox(height: 24),
            _buildAcoesRapidas(context, controller),
            const SizedBox(height: 24),
            if (controller.latestRecords.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Últimos Registros',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            if (controller.isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            else if (controller.latestRecords.isEmpty)
              _buildEmptyState(context)
            else
              ...controller.latestRecords
                  .map((record) => _buildIndiceCard(context, record)),
          ],
        ),
      ),
    );
  }

  Widget _buildAcoesRapidas(
      BuildContext context, DashboardController controller) {
    final Map<String, Map<String, dynamic>> actionDetails = {
      'navigate:IndicesList': {
        'label': 'Calcular Índice',
        'icon': Icons.calculate_outlined,
        'action': () async {
          await Navigator.pushNamed(context, '/indices');
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
      'action:CreateBackup': {
        'label': 'Criar Backup',
        'icon': Icons.backup_outlined,
        'action': () async {
          await Navigator.pushNamed(context, '/settings/backup');
        }
      },
      'navigate:Dashboard': {
        'label': 'Dashboard',
        'icon': Icons.dashboard_outlined,
        'action': () async {}
      },
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (controller.mostUsedActions.isEmpty && !controller.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Use o app para ver seus atalhos mais usados aqui!',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        else
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: controller.mostUsedActions.map((actionId) {
              if (actionId.startsWith('calculate:')) {
                final indexName = actionId.split(':')[1];
                return FilledButton.tonal(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/calculation',
                        arguments: indexName);
                    controller.fetchLatestRecords();
                  },
                  child: Text(indexName),
                );
              } else if (actionDetails.containsKey(actionId)) {
                final details = actionDetails[actionId]!;
                return FilledButton.tonalIcon(
                  icon: Icon(details['icon']),
                  label: Text(details['label']),
                  onPressed: () async {
                    await details['action']();
                    controller.fetchLatestRecords();
                  },
                );
              }

              return const SizedBox.shrink();
            }).toList(),
          ),
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
      BuildContext context, List<CalculationRecord> records) {
    final totalIndices = records.length;
    final totalRegistros = JsonStorageService.instance.getTotalRecordsCount();

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
            _buildSummaryItem(context, Icons.storage_outlined,
                totalIndices.toString(), 'Índices Ativos'),
            _buildSummaryItem(context, Icons.format_list_numbered_rounded,
                totalRegistros.toString(), 'Total de Registros'),
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

  Widget _buildIndiceCard(BuildContext context, CalculationRecord record) {
    final controller = context.read<DashboardController>();
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryView(indexName: record.indexName),
                    ),
                  );
                  controller.fetchLatestRecords();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.indexName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.value.toStringAsFixed(2)} ${record.unit}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined,
                  color: Theme.of(context).colorScheme.error),
              tooltip: 'Apagar histórico de ${record.indexName}',
              onPressed: () =>
                  _showClearIndexConfirmationDialog(context, record.indexName),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClearIndexConfirmationDialog(
      BuildContext context, String indexName) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Apagar Histórico de "$indexName"?'),
          content: const Text(
              'Esta ação não pode ser desfeita e irá apagar todos os registros salvos para este índice.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
              child: const Text('Apagar'),
              onPressed: () async {
                await JsonStorageService.instance
                    .clearHistoryForIndex(indexName);
                if (dialogContext.mounted) {
                  Provider.of<DashboardController>(dialogContext, listen: false)
                      .fetchLatestRecords();
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
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
            'Nenhum registro encontrado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Calcule um índice para vê-lo aqui e começar a acompanhar seus resultados.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
