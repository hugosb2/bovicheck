// lib/views/history_view.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/calculation_record.dart';
import '../services/ai_evaluation_service.dart';
import '../services/json_storage_service.dart';
import '../widgets/ai_analysis_card.dart';

class HistoryView extends StatefulWidget {
  final String indexName;
  const HistoryView({super.key, required this.indexName});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<CalculationRecord> allRecords = [];
  List<CalculationRecord> filteredRecords = [];
  DateTimeRange? selectedDateRange;
  AIAnalysisResult? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    allRecords =
        JsonStorageService.instance.getHistoryForIndex(widget.indexName);
    _applyFilter();
  }

  void _applyFilter() {
    if (selectedDateRange == null) {
      filteredRecords = List.from(allRecords);
    } else {
      final inclusiveEndDate = DateTime(selectedDateRange!.end.year,
          selectedDateRange!.end.month, selectedDateRange!.end.day, 23, 59, 59);

      filteredRecords = allRecords.where((record) {
        return !record.date.isBefore(selectedDateRange!.start) &&
            !record.date.isAfter(inclusiveEndDate);
      }).toList();
    }

    setState(() {
      _aiAnalysis = AIEvaluationService().analyzeHistory(filteredRecords);
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
        _applyFilter();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // =======================================================================
    // CORREÇÃO: Invertemos a lista AQUI para uso exclusivo do gráfico.
    // Isso garante que o gráfico seja desenhado na ordem cronológica correta (do mais antigo para o mais novo).
    final recordsForChart = filteredRecords.reversed.toList();
    // =======================================================================

    const double widthPerBar = 70.0;
    final double chartWidth = recordsForChart.length * widthPerBar;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isScrollable = chartWidth > screenWidth;

    double chartMaxY = 10;
    if (recordsForChart.isNotEmpty) {
      final bool isPercentage = recordsForChart.first.unit == '%';

      if (isPercentage) {
        chartMaxY = 105;
      } else {
        final maxDataValue = recordsForChart.map((r) => r.value).reduce(max);
        chartMaxY = maxDataValue * 1.25;
      }
    }

    const double chartMinY = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de ${widget.indexName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ... (Card de filtro continua o mesmo)
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainer,
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: ExpansionTile(
              title: const Text(
                'Filtrar por Período',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.date_range_outlined),
              subtitle: selectedDateRange != null
                  ? Text(
                      'De ${DateFormat('dd/MM/yy').format(selectedDateRange!.start)} até ${DateFormat('dd/MM/yy').format(selectedDateRange!.end)}')
                  : const Text('Nenhum filtro de data aplicado'),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (selectedDateRange != null)
                      TextButton.icon(
                        icon: const Icon(Icons.filter_list_off_outlined),
                        label: const Text('Limpar'),
                        onPressed: () {
                          setState(() {
                            selectedDateRange = null;
                            _applyFilter();
                          });
                        },
                      ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      icon: const Icon(Icons.edit_calendar_outlined),
                      label: const Text('Selecionar Período'),
                      onPressed: () => _selectDateRange(context),
                    ),
                  ],
                )
              ],
            ),
          ),

          if (_aiAnalysis != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AiAnalysisCard(analysis: _aiAnalysis!),
            ),

          if (recordsForChart.isEmpty)
            // ... (widget de "nenhum registro" continua o mesmo)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Center(
                child: Text(
                  selectedDateRange == null
                      ? 'Nenhum histórico encontrado.'
                      : 'Nenhum registro encontrado para o período selecionado.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          else ...[
            _buildSummaryCard(context,
                filteredRecords), // O resumo ainda usa a ordem original (novo -> antigo)
            const SizedBox(height: 24),
            Text(
              'Evolução do Índice',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16, right: 32),
                      child: SizedBox(
                        height: 300,
                        width: chartWidth,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.center,
                            maxY: chartMaxY,
                            minY: chartMinY,
                            gridData: const FlGridData(show: false),
                            barTouchData: BarTouchData(
                              touchCallback: (event, barTouchResponse) {
                                if (event is FlTapUpEvent &&
                                    barTouchResponse != null &&
                                    barTouchResponse.spot != null) {
                                  final index = barTouchResponse
                                      .spot!.touchedBarGroupIndex;
                                  // CORREÇÃO: Usar a lista invertida para pegar o registro correto
                                  if (index < recordsForChart.length) {
                                    _showDetailsBottomSheet(
                                        context, recordsForChart[index]);
                                  }
                                }
                              },
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => Colors.transparent,
                                tooltipPadding: EdgeInsets.zero,
                                tooltipMargin: 4,
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                  // CORREÇÃO: Usar a lista invertida
                                  final record =
                                      recordsForChart[group.x.toInt()];
                                  return BarTooltipItem(
                                    '${record.value.toStringAsFixed(1)} ${record.unit}',
                                    TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    if (value.toInt() >=
                                        recordsForChart.length) {
                                      return const SizedBox();
                                    }
                                    // CORREÇÃO: Usar a lista invertida
                                    final date =
                                        recordsForChart[value.toInt()].date;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                          DateFormat('dd/MM').format(date),
                                          style: const TextStyle(fontSize: 10)),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            // CORREÇÃO: Mapear sobre a lista invertida
                            barGroups:
                                recordsForChart.asMap().entries.map((entry) {
                              final index = entry.key;
                              final record = entry.value;
                              // A comparação para a cor da barra agora é com o item anterior na lista invertida
                              final previousRecord =
                                  index > 0 ? recordsForChart[index - 1] : null;

                              return BarChartGroupData(
                                x: index,
                                showingTooltipIndicators: [0],
                                barRods: [
                                  BarChartRodData(
                                    toY: record.value,
                                    // A lógica da cor da barra foi ajustada para refletir a nova ordem
                                    gradient: _getBarGradientForChart(
                                        context, record, previousRecord),
                                    width: 35,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    // ... (Widget "Deslize" continua o mesmo)
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // ... (_buildSummaryCard e _buildSummaryItem continuam os mesmos)
  Widget _buildSummaryCard(
      BuildContext context, List<CalculationRecord> records) {
    if (records.length < 2) {
      return const SizedBox.shrink();
    }
    final sortedByValue = List<CalculationRecord>.from(records)
      ..sort((a, b) => a.value.compareTo(b.value));
    final goal = _getGoalForIndex(widget.indexName);
    final bestRecord =
        (goal == 'higherIsBetter') ? sortedByValue.last : sortedByValue.first;
    final worstRecord =
        (goal == 'higherIsBetter') ? sortedByValue.first : sortedByValue.last;
    final newestValue = records.first.value;
    final oldestValue = records.last.value;
    final trend = newestValue - oldestValue;
    IconData trendIcon;
    String trendText;
    Color trendColor = Theme.of(context).colorScheme.tertiary;
    if (trend == 0) {
      trendIcon = Icons.trending_flat;
      trendText = 'Estável';
    } else if ((goal == 'higherIsBetter' && trend > 0) ||
        (goal == 'lowerIsBetter' && trend < 0)) {
      trendIcon = Icons.trending_up;
      trendText = 'Positiva';
      trendColor = Colors.green;
    } else {
      trendIcon = Icons.trending_down;
      trendText = 'Negativa';
      trendColor = Theme.of(context).colorScheme.error;
    }
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo do Período',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryItem(
                    context,
                    Icons.emoji_events_outlined,
                    'Melhor',
                    '${bestRecord.value.toStringAsFixed(2)} ${bestRecord.unit}',
                    Colors.amber.shade700),
                const SizedBox(width: 16),
                _buildSummaryItem(
                    context,
                    Icons.report_outlined,
                    'Pior',
                    '${worstRecord.value.toStringAsFixed(2)} ${worstRecord.unit}',
                    Theme.of(context).colorScheme.error),
                const SizedBox(width: 16),
                _buildSummaryItem(
                    context, trendIcon, 'Tendência', trendText, trendColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, IconData icon, String label,
      String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getGoalForIndex(String indexName) {
    switch (indexName) {
      case 'Taxa de Mortalidade':
      case 'Intervalo entre Partos':
      case 'Idade ao Primeiro Parto':
      case 'Conversão Alimentar':
        return 'lowerIsBetter';
      default:
        return 'higherIsBetter';
    }
  }

  // RENOMEADO: _getBarGradient para _getBarGradientForChart para evitar confusão
  LinearGradient _getBarGradientForChart(BuildContext context,
      CalculationRecord current, CalculationRecord? previous) {
    Color barColor;
    if (previous == null) {
      barColor = Theme.of(context)
          .colorScheme
          .secondary; // Cor base para a primeira barra
    } else {
      final goal = _getGoalForIndex(current.indexName);
      if (current.value == previous.value) {
        barColor = Colors.grey; // Estável
      } else if ((goal == 'higherIsBetter' && current.value > previous.value) ||
          (goal == 'lowerIsBetter' && current.value < previous.value)) {
        barColor = Colors.green; // Melhorou
      } else {
        barColor = Colors.red; // Piorou
      }
    }

    return LinearGradient(
      colors: [
        barColor.withAlpha((255 * 0.8).round()),
        barColor,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
  }

  // ... (_showDetailsBottomSheet, _showDeleteConfirmation, _formatInputKey continuam os mesmos)
  void _showDetailsBottomSheet(BuildContext context, CalculationRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.indexName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bar_chart),
                title: const Text('Valor Calculado'),
                trailing: Text(
                  '${record.value.toStringAsFixed(2)} ${record.unit}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data do Cálculo'),
                trailing: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(record.date),
                ),
              ),
              if (record.inputs.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Valores de Entrada',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...record.inputs.entries.map((entry) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(_formatInputKey(entry.key)),
                    trailing: Text(entry.value,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                }),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(
                        context,
                        '/calculation',
                        arguments: record,
                      ).then((_) {
                        _loadRecords();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Apagar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showDeleteConfirmation(context, record);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, CalculationRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja apagar este registro?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx),
          ),
          FilledButton(
            child: const Text('Apagar'),
            onPressed: () async {
              await JsonStorageService.instance
                  .deleteCalculation(record.id, record.indexName);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadRecords();
            },
          )
        ],
      ),
    );
  }

  String _formatInputKey(String key) {
    key =
        key.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}');
    key = key[0].toUpperCase() + key.substring(1);
    key = key.replaceAll('Kg', '(kg)');
    key = key.replaceAll('Ha', '(ha)');
    key = key.replaceAll('Num', 'Nº');
    return key;
  }
}
