import 'package:bovicheck/controllers/herd_indicators_controller.dart';
import 'package:bovicheck/views/analysis_history_view.dart';
import 'package:bovicheck/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
        ),
        drawer: const AppDrawer(),
        body: Consumer<HerdIndicatorsController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final analysisResults = controller.analysisResults;

            final reproductiveIndicators = analysisResults.entries
                .where((e) =>
                    [
                      'birthRate',
                      'averageCalvingInterval',
                      'averageAgeAtFirstCalving'
                    ].contains(e.key) &&
                    e.value != null)
                .toList();
            final herdIndicators = analysisResults.entries
                .where((e) =>
                    ['mortalityRate', 'averageAdgBirthToWeaning']
                        .contains(e.key) &&
                    e.value != null)
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(context, controller),
                  const SizedBox(height: 16),
                  const SizedBox(height: 32),
                  if (reproductiveIndicators.isNotEmpty) ...[
                    _buildCategoryTitle(context, 'Índices Reprodutivos'),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                      children: reproductiveIndicators.map((entry) {
                        final details = _getIndicatorDetails(entry.key);
                        return _buildIndicatorCard(
                          context,
                          title: details['title'] ?? entry.key,
                          indexKey: entry.key,
                          value: entry.value,
                          unit: details['unit'] ?? '',
                          goal: details['goal'] ?? 0,
                          max: details['max'] ?? 100,
                          lowerIsBetter: details['lowerIsBetter'] ?? false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                  if (herdIndicators.isNotEmpty) ...[
                    _buildCategoryTitle(context, 'Índices de Cria e Rebanho'),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                      children: herdIndicators.map((entry) {
                        final details = _getIndicatorDetails(entry.key);
                        return _buildIndicatorCard(
                          context,
                          title: details['title'] ?? entry.key,
                          indexKey: entry.key,
                          value: entry.value,
                          unit: details['unit'] ?? '',
                          goal: details['goal'] ?? 0,
                          max: details['max'] ?? 100,
                          lowerIsBetter: details['lowerIsBetter'] ?? false,
                        );
                      }).toList(),
                    ),
                  ],
                  if (reproductiveIndicators.isEmpty && herdIndicators.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child:
                            Text("Nenhum indicador calculado para o período."),
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

  Map<String, dynamic> _getIndicatorDetails(String key) {
    switch (key) {
      case 'birthRate':
        return {'title': 'Taxa de Natalidade', 'unit': '%', 'goal': 85.0};
      case 'averageCalvingInterval':
        return {
          'title': 'Intervalo Partos',
          'unit': ' dias',
          'goal': 380.0,
          'max': 500.0,
          'lowerIsBetter': true
        };
      case 'averageAgeAtFirstCalving':
        return {
          'title': 'Idade 1º Parto',
          'unit': ' meses',
          'goal': 24.0,
          'max': 40.0,
          'lowerIsBetter': true
        };
      case 'mortalityRate':
        return {
          'title': 'Taxa de Mortalidade',
          'unit': '%',
          'goal': 2.0,
          'max': 10.0,
          'lowerIsBetter': true
        };
      case 'averageAdgBirthToWeaning':
        return {
          'title': 'GMD Nasc.-Desmame',
          'unit': ' kg/dia',
          'goal': 0.7,
          'max': 1.5
        };
      default:
        return {'title': key, 'unit': '', 'goal': 0.0};
    }
  }

  Widget _buildPeriodSelector(
      BuildContext context, HerdIndicatorsController controller) {
    final dateFormat = DateFormat('dd/MM/yy');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      child: ListTile(
        leading: const Icon(Icons.date_range_outlined),
        title: const Text('Período de Análise'),
        subtitle: Text(
            '${dateFormat.format(controller.selectedPeriod.start)} - ${dateFormat.format(controller.selectedPeriod.end)}'),
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
      ),
    );
  }

  Widget _buildCategoryTitle(BuildContext context, String title) {
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
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side:
            BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(100)),
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 6,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      color: progressColor,
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      hasData
                          ? '${value.toStringAsFixed(unit == '%' ? 0 : 1)}${unit.isNotEmpty ? unit : ''}'
                          : '--',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
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
                  style: theme.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
