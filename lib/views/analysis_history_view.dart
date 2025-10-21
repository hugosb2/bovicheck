import 'dart:math';

import 'package:bovicheck/models/analysis_snapshot.dart';
import 'package:bovicheck/services/json_storage_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  late List<AnalysisSnapshot> _fullHistory;
  List<AnalysisSnapshot> _filteredHistory = [];
  DateTimeRange? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _fullHistory = JsonStorageService.instance.getAnalysisHistory()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (_fullHistory.isNotEmpty) {
      _selectedPeriod = DateTimeRange(
        start: _fullHistory.first.date,
        end: _fullHistory.last.date,
      );
    }
    _filterHistoryByDate();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de ${widget.indexName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          Text(
            'Evolução do Índice',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_filteredHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_fullHistory.isEmpty
                    ? 'Nenhum snapshot foi salvo ainda.'
                    : 'Nenhum registro encontrado para o período selecionado.'),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                height: 300,
                width: chartWidth,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final snapshot = _filteredHistory[groupIndex];
                          final date =
                              DateFormat('dd/MM/yy').format(snapshot.date);
                          return BarTooltipItem(
                            '$date\n${rod.toY.toStringAsFixed(1)} ${widget.unit}',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
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
                            final snapshot = _filteredHistory[value.toInt()];
                            final result = snapshot.results[widget.indexKey]!;
                            return Text(result.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = _filteredHistory[value.toInt()].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(DateFormat('dd/MM').format(date),
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
                    barGroups: _filteredHistory.asMap().entries.map((entry) {
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
          const Divider(height: 40),
          Text(
            'Registros Salvos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (_filteredHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text("Nenhum registro a ser exibido."),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredHistory.length,
              itemBuilder: (context, index) {
                final snapshot = _filteredHistory.reversed.toList()[index];
                final value = snapshot.results[widget.indexKey];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(
                    value != null
                        ? '${value.toStringAsFixed(1)} ${widget.unit}'
                        : 'Dado não disponível',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(DateFormat('dd/MM/yyyy \'às\' HH:mm')
                      .format(snapshot.date)),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final dateFormat = DateFormat('dd/MM/yy');
    final bool isEnabled = _fullHistory.isNotEmpty;

    return Card(
      child: ListTile(
        enabled: isEnabled,
        leading: const Icon(Icons.date_range_outlined),
        title: const Text('Período de Análise'),
        subtitle: Text(
          _selectedPeriod != null
              ? '${dateFormat.format(_selectedPeriod!.start)} - ${dateFormat.format(_selectedPeriod!.end)}'
              : 'Nenhum registro encontrado',
        ),
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
      ),
    );
  }
}
