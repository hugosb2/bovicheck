import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../estilos/cores.dart';
import '../../../modelos/eventos/pesagem.dart';

class GraficoEvolutivo extends StatelessWidget {
  final List<Pesagem> historicoPeso;

  const GraficoEvolutivo({super.key, required this.historicoPeso});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (historicoPeso.isEmpty || historicoPeso.length < 2) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              "Dados insuficientes para gráfico",
              style: TextStyle(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 4),
            const Text(
              "Adicione pelo menos 2 pesagens",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final dadosOrdenados = List<Pesagem>.from(historicoPeso)
      ..sort((a, b) => a.data.compareTo(b.data));

    final pontos = dadosOrdenados.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.pesoKg);
    }).toList();

    final maxPeso = dadosOrdenados
        .map((e) => e.pesoKg)
        .reduce((a, b) => a > b ? a : b);
    final minPeso = dadosOrdenados
        .map((e) => e.pesoKg)
        .reduce((a, b) => a < b ? a : b);

    return AspectRatio(
      aspectRatio: 1.7,
      child: Container(
        padding: const EdgeInsets.only(right: 16, left: 0, top: 24, bottom: 0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < dadosOrdenados.length) {
                      if (index == 0 || index == dadosOrdenados.length - 1) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat(
                              'dd/MM',
                            ).format(dadosOrdenados[index].data),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
            ),
            borderData: FlBorderData(show: false),
            minY: (minPeso * 0.9).floorToDouble(),
            maxY: (maxPeso * 1.1).ceilToDouble(),
            lineBarsData: [
              LineChartBarData(
                spots: pontos,
                isCurved: true,
                color: CoresApp.sucesso,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: CoresApp.sucesso.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
