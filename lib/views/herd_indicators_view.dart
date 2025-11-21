import 'package:bovicheck/controllers/herd_indicators_controller.dart';
import 'package:bovicheck/views/analysis_history_view.dart';
import 'package:bovicheck/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HerdIndicatorsView extends StatelessWidget {
  const HerdIndicatorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HerdIndicatorsController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Indicadores do Rebanho'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        drawer: const AppDrawer(),
        body: Consumer<HerdIndicatorsController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final analysisResults = controller.analysisResults;

            // --- ATUALIZAÇÃO ---
            // Listas fixas de todos os indicadores que o app oferece
            const reproductiveKeys = [
              'birthRate',
              'averageCalvingInterval',
              'averageAgeAtFirstCalving'
            ];
            const herdKeys = [
              'mortalityRate',
              'averageAdgBirthToWeaning',
              'averageDailyMilkProduction' // Movido para cá
            ];

            // Verifica se *algum* dado foi calculado
            final bool hasAnyData =
                analysisResults.values.any((v) => v != null);
            // --- FIM DA ATUALIZAÇÃO ---

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(context, controller),
                  const SizedBox(height: 16),
                  const SizedBox(height: 32),

                  // --- SEÇÃO REPRODUTIVA ATUALIZADA ---
                  _buildCategoryTitle(context, 'Índices Reprodutivos'),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      final crossAxisCount = isMobile ? 1 : 2;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isMobile ? 1.2 : 0.9,
                        children: reproductiveKeys.map((key) {
                          final details = _getIndicatorDetails(key);
                          final value = analysisResults[key];

                          if (value != null) {
                            return _buildIndicatorCard(
                              context,
                              title: details['title'] ?? key,
                              indexKey: key,
                              value: value,
                              unit: details['unit'] ?? '',
                              goal: details['goal'] ?? 0,
                              max: details['max'] ?? 100,
                              lowerIsBetter: details['lowerIsBetter'] ?? false,
                            );
                          } else {
                            return _buildEmptyIndicatorCard(
                              context,
                              title: details['title'] ?? key,
                              helpText:
                                  details['helpText'] ?? 'Dados insuficientes.',
                            );
                          }
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // --- SEÇÃO REBANHO ATUALIZADA ---
                  _buildCategoryTitle(context, 'Índices de Cria e Rebanho'),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      final crossAxisCount = isMobile ? 1 : 2;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isMobile ? 1.2 : 0.9,
                        children: herdKeys.map((key) {
                          final details = _getIndicatorDetails(key);
                          final value = analysisResults[key];

                          if (value != null) {
                            return _buildIndicatorCard(
                              context,
                              title: details['title'] ?? key,
                              indexKey: key,
                              value: value,
                              unit: details['unit'] ?? '',
                              goal: details['goal'] ?? 0,
                              max: details['max'] ?? 100,
                              lowerIsBetter: details['lowerIsBetter'] ?? false,
                            );
                          } else {
                            // NOVO: Mostra o card de ajuda
                            return _buildEmptyIndicatorCard(
                              context,
                              title: details['title'] ?? key,
                              helpText:
                                  details['helpText'] ?? 'Dados insuficientes.',
                            );
                          }
                        }).toList(),
                      );
                    },
                  ),

                  if (!hasAnyData)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: Text(
                          "Registre os eventos dos animais (partos, pesagens, etc) para calcular os indicadores.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- DICIONÁRIO DE DETALHES ATUALIZADO ---
  Map<String, dynamic> _getIndicatorDetails(String key) {
    switch (key) {
      case 'birthRate':
        return {
          'title': 'Taxa de Natalidade',
          'unit': '%',
          'goal': 85.0,
          'helpText':
              'Requer fêmeas aptas (> 15 meses) e registros de Parto no período.'
        };
      case 'averageCalvingInterval':
        return {
          'title': 'Intervalo Partos',
          'unit': ' dias',
          'goal': 380.0,
          'max': 500.0,
          'lowerIsBetter': true,
          'helpText': 'Requer animais com pelo menos 2 registros de Parto.'
        };
      case 'averageAgeAtFirstCalving':
        return {
          'title': 'Idade 1º Parto',
          'unit': ' meses',
          'goal': 24.0,
          'max': 40.0,
          'lowerIsBetter': true,
          'helpText': 'Requer fêmeas com pelo menos 1 registro de Parto.'
        };
      case 'mortalityRate':
        return {
          'title': 'Taxa de Mortalidade',
          'unit': '%',
          'goal': 2.0,
          'max': 10.0,
          'lowerIsBetter': true,
          'helpText':
              'Requer animais que existiam no início do período e registros de Morte.'
        };
      case 'averageAdgBirthToWeaning':
        return {
          'title': 'GMD Nasc.-Desmame',
          'unit': ' kg/dia',
          'goal': 0.7,
          'max': 1.5,
          'helpText':
              'Requer animais com data de desmame e pesagens próximas ao nascimento e ao desmame.'
        };
      case 'averageDailyMilkProduction':
        return {
          'title': 'Média de Leite',
          'unit': ' L/dia',
          'goal': 10.0,
          'max': 30.0,
          'helpText':
              'Requer registros de Parto (para iniciar a lactação) e registros de Leite.'
        };
      default:
        return {
          'title': key,
          'unit': '',
          'goal': 0.0,
          'helpText': 'Dados insuficientes.'
        };
    }
  }

  // --- NOVO WIDGET ---
  // Card para indicadores sem dados
  Widget _buildEmptyIndicatorCard(
    BuildContext context, {
    required String title,
    required String helpText,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.05),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      color: theme.colorScheme.surfaceContainer,
      child: Tooltip(
        message: helpText,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surfaceContainer,
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 6,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '--',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
  // --- FIM DO NOVO WIDGET ---

  Widget _buildPeriodSelector(
      BuildContext context, HerdIndicatorsController controller) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yy');
    return Card(
      elevation: 2,
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
          onTap: () async {
            final newPeriod = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              initialDateRange: controller.selectedPeriod,
            );
            if (newPeriod != null) {
              await controller.setPeriod(newPeriod);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.date_range_outlined,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Período de Análise',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dateFormat.format(controller.selectedPeriod.start)} - ${dateFormat.format(controller.selectedPeriod.end)}',
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
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0);
  }

  Widget _buildCategoryTitle(BuildContext context, String title) {
    // ... (este método permanece o mesmo)
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: theme.colorScheme.outlineVariant, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(
    BuildContext context, {
    required String title,
    required String indexKey,
    required double? value,
    required String unit,
    required double goal,
    double max = 100,
    bool lowerIsBetter = false,
  }) {
    final theme = Theme.of(context);
    final bool hasData = value != null;
    final double displayValue = hasData ? value : 0;
    final effectiveMax = (hasData && displayValue > max) ? displayValue : max;
    final double progress =
        hasData ? (displayValue / effectiveMax).clamp(0.0, 1.0) : 0.0;

    Color progressColor = theme.colorScheme.outlineVariant;
    if (hasData) {
      final bool achievedGoal = (lowerIsBetter && displayValue <= goal) ||
          (!lowerIsBetter && displayValue >= goal);
      if (achievedGoal) {
        progressColor = Colors.green.shade600;
      } else {
        double performanceRatio;
        if (lowerIsBetter) {
          performanceRatio =
              (displayValue > 0 ? displayValue : 0.1) / (goal > 0 ? goal : 0.1);
          if (performanceRatio < 1.25)
            progressColor = Colors.orange.shade600;
          else
            progressColor = Colors.red.shade600;
        } else {
          performanceRatio = displayValue / (goal > 0 ? goal : 1.0);
          if (performanceRatio > 0.75)
            progressColor = Colors.orange.shade600;
          else
            progressColor = Colors.red.shade600;
        }
      }
    }

    return Card(
      elevation: 2,
      shadowColor: progressColor.withOpacity(0.2),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasData
              ? () {
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
                }
              : null,
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        color: progressColor,
                        strokeCap: StrokeCap.round,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          hasData
                              ? '${value.toStringAsFixed(unit == '%' ? 0 : 1)}${unit.isNotEmpty ? unit : ''}'
                              : '--',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: hasData ? progressColor : theme.colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasData) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Meta: ${goal.toStringAsFixed(unit == '%' ? 0 : 1)}$unit',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}
