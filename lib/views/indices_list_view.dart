import 'package:flutter/material.dart';
import '../models/indice_info.dart';
import '../widgets/app_drawer.dart';

class IndicesListView extends StatelessWidget {
  IndicesListView({super.key});

  final List<Map<String, dynamic>> categorias = [
    {
      'titulo': 'Índices Reprodutivos',
      'icone': Icons.favorite_border_outlined,
      'indices': [
        IndiceInfo(
          titulo: 'Taxa de Natalidade',
          icone: Icons.percent_outlined,
          descricao: 'Mede a eficiência reprodutiva do rebanho, indicando o percentual de nascimentos.',
        ),
        IndiceInfo(
          titulo: 'Taxa de Prenhez',
          icone: Icons.percent_outlined,
          descricao: 'Percentual de fêmeas que ficaram prenhas em relação ao total de fêmeas expostas.',
        ),
        IndiceInfo(
          titulo: 'Idade ao Primeiro Parto',
          icone: Icons.calendar_today_outlined,
          descricao: 'Indica a idade média (em meses) em que as fêmeas do rebanho parem pela primeira vez.',
        ),
        IndiceInfo(
          titulo: 'Intervalo entre Partos',
          icone: Icons.repeat_outlined,
          descricao: 'Mede o tempo médio (em dias) entre um parto e o parto seguinte da mesma vaca.',
        ),
      ],
    },
    {
      'titulo': 'Índices de Cria',
      'icone': Icons.child_friendly_outlined,
      'indices': [
        IndiceInfo(
          titulo: 'Taxa de Desmame',
          icone: Icons.percent_outlined,
          descricao: 'Indica a porcentagem de bezerros que sobreviveram do nascimento até o desmame.',
        ),
        IndiceInfo(
          titulo: 'Taxa de Mortalidade',
          icone: Icons.percent_outlined,
          descricao: 'Mede a porcentagem de animais que morreram em relação ao total do rebanho.',
        ),
        IndiceInfo(
          titulo: 'Peso ao Desmame Ajustado P205',
          icone: Icons.scale_outlined,
          descricao: 'Padroniza o peso dos bezerros a uma idade de 205 dias para comparações justas.',
        ),
      ],
    },
    {
      'titulo': 'Índices de Desempenho e Carcaça',
      'icone': Icons.trending_up_outlined,
      'indices': [
        IndiceInfo(
          titulo: 'Ganho Médio Diário (GMD)',
          icone: Icons.trending_up_outlined,
          descricao: 'Mostra o ganho de peso médio de um animal por dia em um determinado período.',
        ),
        IndiceInfo(
          titulo: 'Conversão Alimentar',
          icone: Icons.swap_horiz_outlined,
          descricao: 'Mede a eficiência com que o animal converte o alimento consumido em peso vivo.',
        ),
        IndiceInfo(
          titulo: 'Rendimento de Carcaça',
          icone: Icons.kitchen_outlined,
          descricao: 'Indica a porcentagem do peso vivo do animal que se transforma em carcaça após o abate.',
        ),
      ],
    },
    {
      'titulo': 'Índices de Manejo e Produção',
      'icone': Icons.grass_outlined,
      'indices': [
        IndiceInfo(
          titulo: 'Lotação Animal',
          icone: Icons.grass_outlined,
          descricao: 'Relaciona o peso total dos animais com a área de pastagem disponível (UA/ha).',
        ),
        IndiceInfo(
          titulo: 'Produção de Leite por Vaca/Dia',
          icone: Icons.local_drink_outlined,
          descricao: 'Calcula a média de litros de leite produzidos por cada vaca em lactação por dia.',
        ),
      ],
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Índice'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final List<IndiceInfo> indices = categoria['indices'];

          return Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: ExpansionTile(
              leading: Icon(categoria['icone'], color: Theme.of(context).colorScheme.primary),
              title: Text(
                categoria['titulo'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              childrenPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              children: indices.map((indice) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListTile(
                    title: Text(indice.titulo),
                    subtitle: Text(indice.descricao),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/calculation',
                        arguments: indice.titulo,
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      )
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}