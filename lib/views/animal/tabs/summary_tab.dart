import 'package:bovicheck/controllers/animal_detail_controller.dart';
import 'package:bovicheck/services/herd_analysis_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SummaryTab extends StatelessWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimalDetailController>();
    final animal = controller.animal!;
    final results = controller.analysisResults;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(context, 'Dados Básicos', [
          _buildInfoTile(context, 'Nome', animal.nome ?? 'Não informado'),
          _buildInfoTile(context, 'Data de Nasc.',
              '${controller.formattedBirthDate} (${controller.formattedAge})'),
          _buildInfoTile(context, 'Sexo', animal.sexo),
          _buildInfoTile(context, 'Raça', animal.raca ?? 'Não informada'),
          _buildInfoTile(context, 'Status', animal.status.name),
        ]),
        if (animal.sexo == 'Fêmea')
          _buildInfoCard(context, 'Desempenho Reprodutivo', [
            _buildInfoTile(context, 'Idade ao 1º Parto', results['ageAtFirstCalving'],
                unit: ' meses',
                helpText: 'Requer registro de Parto'),
            _buildInfoTile(context, 'Intervalo Médio Entre Partos',
                results['averageCalvingInterval'],
                unit: ' dias', helpText: 'Requer 2+ Partos'),
          ]),
        _buildInfoCard(context, 'Desempenho de Peso', [
          _buildInfoTile(context, 'GMD Nasc.-Desmame', results['adgBirthToWeaning'],
              unit: ' kg/dia',
              helpText: 'Requer Desmame e Pesagens'),
        ]),
        if (animal.sexo == 'Fêmea' && results['latestLactation'] != null)
          _buildInfoCard(context, 'Última Lactação', [
            _buildInfoTile(context,
                'Produção Média Diária',
                (results['latestLactation'] as LactationCycle)
                    .averageDailyProduction,
                unit: ' L/dia'),
            _buildInfoTile(context, 'Produção Total',
                (results['latestLactation'] as LactationCycle).totalProduction,
                unit: ' L'),
            _buildInfoTile(context,
                'Dias em Lactação',
                (results['latestLactation'] as LactationCycle)
                    .lengthInDays
                    .toDouble(),
                unit: ' dias',
                decimalPlaces: 0),
          ]),
        if (animal.sexo == 'Fêmea' && results['latestLactation'] == null)
          _buildInfoCard(context, 'Lactação', [
            _buildInfoTile(context, 'Produção Média Diária', null,
                unit: ' L/dia', helpText: 'Requer Parto e Registros de Leite'),
          ]),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> tiles) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            ...tiles,
          ],
        ),
      ),
    );
  }

  // --- MÉTODO ATUALIZADO ---
  Widget _buildInfoTile(BuildContext context, String title, dynamic value,
      {String unit = '', int decimalPlaces = 1, String? helpText}) {
    final theme = Theme.of(context);
    String valueStr;
    bool isHelp = false;

    if (value != null) {
      if (value is double) {
        valueStr = '${value.toStringAsFixed(decimalPlaces)}$unit';
      } else {
        valueStr = value.toString();
      }
    } else {
      // Se o valor for nulo, use o texto de ajuda
      valueStr = helpText ?? 'Dados insuficientes';
      isHelp = true;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valueStr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isHelp ? FontWeight.normal : FontWeight.bold,
              fontStyle: isHelp ? FontStyle.italic : FontStyle.normal,
              color: isHelp
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
  // --- FIM DA ATUALIZAÇÃO ---
}
