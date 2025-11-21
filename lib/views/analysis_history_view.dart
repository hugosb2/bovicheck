import 'dart:math';

import 'package:bovicheck/models/analysis_snapshot.dart';
import 'package:bovicheck/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class AnalysisHistoryView extends StatefulWidget {
  final String indexKey;
  final String indexName;
  final String unit;

  const AnalysisHistoryView({
    super.key,
    required this.indexKey,
    required this.indexName,
    required this.unit,
  });

  @override
  State<AnalysisHistoryView> createState() => _AnalysisHistoryViewState();
}

class _AnalysisHistoryViewState extends State<AnalysisHistoryView> {
  List<AnalysisSnapshot> _fullHistory = [];
  List<AnalysisSnapshot> _filteredHistory = [];
  DateTimeRange? _selectedPeriod;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _fullHistory = await DatabaseService.instance.getAnalysisHistory();
    _fullHistory.sort((a, b) => a.date.compareTo(b.date));

    if (_fullHistory.isNotEmpty) {
      _selectedPeriod = DateTimeRange(
        start: _fullHistory.first.date,
        end: _fullHistory.last.date,
      );
    }
    _filterHistoryByDate();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterHistoryByDate() {
    if (_selectedPeriod == null) {
      setState(() {
        _filteredHistory = [];
      });
      return;
    }

    final relevantSnapshots = _fullHistory
        .where((s) =>
            s.results.containsKey(widget.indexKey) &&
            s.results[widget.indexKey] != null)
        .where((s) {
      final recordDate = s.date;
      final startDate = _selectedPeriod!.start;
      final endDate = _selectedPeriod!.end;
      return !recordDate.isBefore(startDate) &&
          !recordDate.isAfter(endDate.add(const Duration(days: 1)));
    }).toList();

    setState(() {
      _filteredHistory = relevantSnapshots;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double barWidth = 40.0;
    const double barSpacing = 20.0;
    final double chartWidth = max(
      screenWidth - 32,
      _filteredHistory.length * (barWidth + barSpacing),
    );

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de ${widget.indexName}'),
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
      body: _isLoading // ADICIONADO
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPeriodSelector()
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 24),
                Text(
                  'Evolução do Índice',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms),
                const SizedBox(height: 24),
                if (_filteredHistory.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32.0),
                    margin: const EdgeInsets.symmetric(vertical: 16),
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
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.bar_chart_outlined,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _fullHistory.isEmpty
                                ? 'Nenhum snapshot foi salvo ainda.'
                                : 'Nenhum registro encontrado para o período selecionado.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                    .animate()
                    .fadeIn(duration: 400.ms)
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        height: 300,
                        width: chartWidth,
                        child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.center,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                final snapshot = _filteredHistory[groupIndex];
                                final date = DateFormat('dd/MM/yy')
                                    .format(snapshot.date);
                                return BarTooltipItem(
                                  '$date\n${rod.toY.toStringAsFixed(1)} ${widget.unit}',
                                  TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) {
                                  final snapshot =
                                      _filteredHistory[value.toInt()];
                                  final result =
                                      snapshot.results[widget.indexKey]!;
                                  return Text(result.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 10));
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final date =
                                      _filteredHistory[value.toInt()].date;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                        DateFormat('dd/MM').format(date),
                                        style: const TextStyle(fontSize: 10)),
                                  );
                                },
                                reservedSize: 20,
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups:
                              _filteredHistory.asMap().entries.map((entry) {
                            final index = entry.key;
                            final snapshot = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: snapshot.results[widget.indexKey]!,
                                  color: Theme.of(context).colorScheme.primary,
                                  width: barWidth,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                const SizedBox(height: 32),
                Text(
                  'Registros Salvos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 300.ms),
                const SizedBox(height: 16),
                if (_filteredHistory.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Nenhum registro a ser exibido.",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 400.ms)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredHistory.length,
                    itemBuilder: (context, index) {
                      final snapshot =
                          _filteredHistory.reversed.toList()[index];
                      final value = snapshot.results[widget.indexKey];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.history,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            value != null
                                ? '${value.toStringAsFixed(1)} ${widget.unit}'
                                : 'Dado não disponível',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy \'às\' HH:mm')
                                .format(snapshot.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (400 + index * 50).ms)
                          .slideX(begin: 0.1, end: 0);
                    },
                  ),
              ],
            ),
    );
  }

  Widget _buildPeriodSelector() {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yy');
    final bool isEnabled = _fullHistory.isNotEmpty;

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
            if (!isEnabled) return;

            final newPeriod = await showDateRangePicker(
              context: context,
              firstDate: _fullHistory.first.date,
              lastDate: _fullHistory.last.date,
              initialDateRange: _selectedPeriod,
            );
            if (newPeriod != null) {
              setState(() {
                _selectedPeriod = newPeriod;
              });
              _filterHistoryByDate();
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
                        _selectedPeriod != null
                            ? '${dateFormat.format(_selectedPeriod!.start)} - ${dateFormat.format(_selectedPeriod!.end)}'
                            : 'Nenhum registro encontrado',
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
    );
  }
}
