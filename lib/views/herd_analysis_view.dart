// lib/views/herd_analysis_view.dart

import 'package:bovicheck/controllers/herd_analysis_controller.dart';
import 'package:bovicheck/widgets/app_drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HerdAnalysisView extends StatelessWidget {
  const HerdAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HerdAnalysisController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Análise do Rebanho'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        drawer: const AppDrawer(),
        body: Consumer<HerdAnalysisController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(context, controller),
                  const SizedBox(height: 24),

                  _buildCategoryTitle(context, 'Índices Reprodutivos'),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                       _buildGaugeCard(
                        context,
                        title: 'Intervalo Entre Partos',
                        value: controller.analysisResults['averageCalvingInterval'],
                        unit: ' dias',
                        goal: 380,
                        max: 500, // Valor máximo esperado para o gráfico
                        lowerIsBetter: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildCategoryTitle(context, 'Índices de Cria e Rebanho'),
                   Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildGaugeCard(
                        context,
                        title: 'GMD Nasc.-Desmame',
                        value: controller.analysisResults['averageAdgBirthToWeaning'],
                        unit: ' kg/dia',
                        goal: 0.7,
                        max: 1.5,
                        lowerIsBetter: false,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, HerdAnalysisController controller) {
    final dateFormat = DateFormat('dd/MM/yy');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.date_range_outlined),
        title: const Text('Período de Análise'),
        subtitle: Text('${dateFormat.format(controller.selectedPeriod.start)} - ${dateFormat.format(controller.selectedPeriod.end)}'),
        onTap: () async {
          final newPeriod = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            initialDateRange: controller.selectedPeriod,
          );
          if (newPeriod != null) {
            controller.setPeriod(newPeriod);
          }
        },
      ),
    );
  }
  
  Widget _buildCategoryTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildGaugeCard(BuildContext context, {
    required String title,
    required double? value,
    required String unit,
    required double goal,
    double max = 100,
    bool lowerIsBetter = false,
  }) {
    final size = MediaQuery.of(context).size;
    final cardWidth = (size.width / 2) - 24; 
    
    final bool hasData = value != null;
    final double displayValue = hasData ? value : 0;

    final double performance = lowerIsBetter 
      ? (goal / (displayValue > 0 ? displayValue : 1)) 
      : (displayValue / goal);
      
    Color progressColor = Colors.grey;
    if (hasData) {
      if ((lowerIsBetter && displayValue <= goal) || (!lowerIsBetter && displayValue >= goal)) {
        progressColor = Colors.green;
      } else if (performance > 0.75) {
        progressColor = Colors.orange;
      } else {
        progressColor = Colors.red;
      }
    }

    return SizedBox(
      width: cardWidth,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: hasData ? displayValue.clamp(0, max) : 0,
                            color: progressColor,
                            radius: 10,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: hasData ? (max - displayValue).clamp(0, max) : max,
                            color: Colors.grey.withOpacity(0.3),
                            radius: 10,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      hasData ? '${value.toStringAsFixed(1)}${unit.split(' ')[0]}' : '--',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}