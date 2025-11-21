import 'analysis_history_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/dashboard_controller.dart';
import '../services/spreadsheet_service.dart';
import '../widgets/ai_analysis_card.dart';
import '../widgets/app_drawer.dart';

// --- NOVOS IMPORTS NECESSÁRIOS ---
import 'package:bovicheck/services/database_service.dart';
import 'package:bovicheck/views/animal/animal_form_view.dart';
import 'package:bovicheck/styles/app_icons.dart';
// --- FIM DOS NOVOS IMPORTS ---

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

  // --- NOVO MÉTODO HELPER PARA NAVEGAÇÃO ---
  Future<void> _navigateTo(BuildContext context, String routeName,
      DashboardController controller) async {
    await Navigator.pushNamed(context, routeName);
    // Atualiza o dashboard caso algo tenha mudado (ex: contagem de animais)
    controller.fetchDashboardData();
  }

  // --- NOVO MÉTODO HELPER PARA ADICIONAR ANIMAL ---
  // (Lógica copiada do 'animal_list_view.dart' para garantir a verificação de lotes)
  Future<void> _onAddNewAnimalPressed(
      BuildContext context, DashboardController controller) async {
    final lotes = await DatabaseService.instance.getAllLotes();
    final currentContext = context; // Salva o context para uso após o 'await'
    if (!currentContext.mounted) return;

    if (lotes.isEmpty) {
      showDialog(
        context: currentContext,
        builder: (ctx) => AlertDialog(
          title: const Text('Nenhum Lote Encontrado'),
          content: const Text(
              'Você precisa cadastrar um Lote antes de poder adicionar um Animal.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Navega para a tela de gerenciamento de lotes
                Navigator.pushNamed(currentContext, '/lotes');
              },
              child: const Text('Cadastrar Lote'),
            ),
          ],
        ),
      );
    } else {
      // Se houver lotes, permite a navegação para o formulário
      await Navigator.push(currentContext,
          MaterialPageRoute(builder: (_) => const AnimalFormView()));
      controller.fetchDashboardData();
    }
  }

  // --- NOVO MÉTODO HELPER PARA EXPORTAR ---
  Future<void> _onExportPressed(BuildContext context) async {
    final success = await SpreadsheetService().exportAllData();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Planilha salva!' : 'Exportação cancelada.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final theme = Theme.of(context);

    // Filtra indicadores globais válidos
    final globalAnalysisEntries = controller.latestAnalysis.entries
        .where((entry) =>
            entry.value != null && metricDetails.containsKey(entry.key))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard BoviCheck'),
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
      body: RefreshIndicator(
        onRefresh: controller.fetchDashboardData,
        color: theme.colorScheme.primary,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildWelcomeHeader(context)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.1, end: 0),
            const SizedBox(height: 16),
            if (controller.dashboardAIAnalysis != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AiAnalysisCard(analysis: controller.dashboardAIAnalysis!)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideX(begin: -0.1, end: 0),
              ),
            _buildDashboardSummary(
              context,
              controller.animalCount,
              controller.loteCount,
              controller.propCount,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
            const SizedBox(height: 24),
            _buildAcoesRapidas(context, controller)
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 24),

            // TÍTULO DA ANÁLISE GLOBAL
            if (globalAnalysisEntries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Análise Global do Rebanho (Últimos 365 dias)',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Divider(height: 24),
                  ],
                ),
              ),

            // ESTADO DE CARREGAMENTO
            if (controller.isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            // ESTADO VAZIO (SEM ANIMAIS OU DADOS)
            else if (globalAnalysisEntries.isEmpty &&
                controller.loteAnalyses.isEmpty)
              _buildEmptyState(context)
            // LISTA DE ANÁLISE GLOBAL (CLICÁVEL)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: globalAnalysisEntries.length,
                itemBuilder: (context, index) {
                  final entry = globalAnalysisEntries[index];
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

            // SEÇÕES (ANÁLISE POR LOTE)
            if (controller.loteAnalyses.isNotEmpty && !controller.isLoading)
              ..._buildLoteAnalysisSections(context, controller),
          ],
        ),
      ),
    );
  }

  // Constrói as seções de análise para cada lote
  List<Widget> _buildLoteAnalysisSections(
      BuildContext context, DashboardController controller) {
    final theme = Theme.of(context);
    final List<Widget> loteWidgets = [];

    for (final loteId in controller.loteAnalyses.keys) {
      final loteName =
          controller.allLotesMap[loteId]?.nome ?? 'Lote ID: $loteId';
      final loteResults = controller.loteAnalyses[loteId]!;

      final analysisEntries = loteResults.entries
          .where((entry) =>
              entry.value != null && metricDetails.containsKey(entry.key))
          .toList();

      if (analysisEntries.isEmpty) continue;

      // Adiciona o título do Lote
      loteWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Análise do Lote: $loteName',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Divider(height: 24),
            ],
          ),
        ),
      );

      // Adiciona a lista de indicadores para aquele lote
      loteWidgets.add(
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: analysisEntries.length,
          itemBuilder: (context, index) {
            final entry = analysisEntries[index];
            final details = metricDetails[entry.key]!;
            // Usa o card estático (não clicável)
            return _buildStaticAnalysisCard(
              context,
              title: details['title'],
              value: entry.value!,
              unit: details['unit'],
            );
          },
        ),
      );
    }
    return loteWidgets;
  }

  // Card de análise que não é clicável (para os lotes)
  Widget _buildStaticAnalysisCard(
    BuildContext context, {
    required String title,
    required double value,
    required String unit,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toStringAsFixed(1)}$unit',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const SizedBox(width: 24),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }

  // Card de análise clicável (global)
  Widget _buildAnalysisCard(
    BuildContext context, {
    required String title,
    required double value,
    required String unit,
    required String indexKey,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
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
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${value.toStringAsFixed(1)}$unit',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }

  // --- MÉTODO _buildAcoesRapidas TOTALMENTE ATUALIZADO ---
  Widget _buildAcoesRapidas(
      BuildContext context, DashboardController controller) {
    final theme = Theme.of(context);
    final actions = [
      {'icon': AppIcons.add, 'label': 'Novo Animal', 'action': () => _onAddNewAnimalPressed(context, controller)},
      {'icon': AppIcons.herd, 'label': 'Meu Rebanho', 'action': () => _navigateTo(context, '/animals', controller)},
      {'icon': AppIcons.lotes, 'label': 'Gerenciar Lotes', 'action': () => _navigateTo(context, '/lotes', controller)},
      {'icon': AppIcons.properties, 'label': 'Propriedades', 'action': () => _navigateTo(context, '/settings/propriedades', controller)},
      {'icon': AppIcons.indicators, 'label': 'Indicadores', 'action': () => _navigateTo(context, '/herd-indicators', controller)},
      {'icon': AppIcons.exportExcel, 'label': 'Exportar Planilha', 'action': () => _onExportPressed(context)},
      {'icon': AppIcons.settings, 'label': 'Configurações', 'action': () => _navigateTo(context, '/settings', controller)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          height: 24,
          thickness: 1,
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return _buildActionButton(
              context,
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onPressed: action['action'] as VoidCallback,
            )
                .animate()
                .fadeIn(duration: 200.ms, delay: (index * 50).ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton.tonalIcon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
    );
  }
  // --- FIM DA ATUALIZAÇÃO ---

  Widget _buildWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset('assets/icon.png', height: 64, width: 64),
          ),
          const SizedBox(height: 20),
          Text(
            'BoviCheck',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bem-vindo ao seu painel de controle pecuário',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSummary(
      BuildContext context, int animalCount, int loteCount, int propCount) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
                context,
                AppIcons.herd,
                animalCount.toString(),
                'Animais')
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            _buildSummaryItem(
                context,
                AppIcons.lotes,
                loteCount.toString(),
                'Lotes')
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            _buildSummaryItem(
                context,
                AppIcons.properties,
                propCount.toString(),
                'Propriedades')
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32.0),
      margin: const EdgeInsets.only(top: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surfaceContainer,
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.inbox,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum indicador calculado',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Registre eventos-chave (Partos, Desmames, Pesagens) em seus animais para que as análises de produtividade apareçam aqui.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}
