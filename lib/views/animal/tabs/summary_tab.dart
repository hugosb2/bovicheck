// lib/views/animal/tabs/summary_tab.dart

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
        _buildInfoCard('Dados Básicos', [
          _buildInfoTile('Nome', animal.nome ?? 'Não informado'),
          _buildInfoTile('Data de Nasc.', '${controller.formattedBirthDate} (${controller.formattedAge})'),
          _buildInfoTile('Sexo', animal.sexo),
          _buildInfoTile('Raça', animal.raca ?? 'Não informada'),
          _buildInfoTile('Status', animal.status.name),
        ]),

        if (animal.sexo == 'Fêmea')
          _buildInfoCard('Desempenho Reprodutivo', [
            _buildInfoTile('Idade ao 1º Parto', results['ageAtFirstCalving'], unit: ' meses'),
            _buildInfoTile('Intervalo Médio Entre Partos', results['averageCalvingInterval'], unit: ' dias'),
          ]),
        
        _buildInfoCard('Desempenho de Peso', [
           _buildInfoTile('GMD Nasc.-Desmame', results['adgBirthToWeaning'], unit: ' kg/dia'),
        ]),

        if (animal.sexo == 'Fêmea' && results['latestLactation'] != null)
          _buildInfoCard('Última Lactação', [
             _buildInfoTile('Produção Média Diária', (results['latestLactation'] as LactationCycle).averageDailyProduction, unit: ' L/dia'),
             _buildInfoTile('Produção Total', (results['latestLactation'] as LactationCycle).totalProduction, unit: ' L'),
             _buildInfoTile('Dias em Lactação', (results['latestLactation'] as LactationCycle).lengthInDays.toDouble(), unit: ' dias', decimalPlaces: 0),
          ]),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> tiles) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...tiles,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, dynamic value, {String unit = '', int decimalPlaces = 1}) {
    String valueStr = 'Dados insuficientes';
    if (value != null) {
      if (value is double) {
        valueStr = '${value.toStringAsFixed(decimalPlaces)}$unit';
      } else {
        valueStr = value.toString();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(valueStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}