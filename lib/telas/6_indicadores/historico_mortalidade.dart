import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/animal.dart';
import 'widgets/dados_insuficientes.dart';
import '../8_rebanho/form_animal.dart';

class TelaHistoricoMortalidade extends StatefulWidget {
  const TelaHistoricoMortalidade({super.key});

  @override
  State<TelaHistoricoMortalidade> createState() => _TelaHistoricoMortalidadeState();
}

class _TelaHistoricoMortalidadeState extends State<TelaHistoricoMortalidade> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;
  bool _carregando = false;
  List<Animal> _animais = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDados());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients && _scrollController.offset > (140 - kToolbarHeight)) {
      if (!_isCollapsed) setState(() => _isCollapsed = true);
    } else {
      if (_isCollapsed) setState(() => _isCollapsed = false);
    }
  }

  void _carregarDados() {
    final provedor = context.read<ProvedorFazenda>();
    setState(() {
      _animais = provedor.animais;
      _carregando = false;
    });
  }

  List<_DadoAnual> _gerarDadosMortalidade() {
    final now = DateTime.now();
    final dados = <_DadoAnual>[];

    for (var i = 3; i >= 0; i--) {
      final ano = now.year - i;
      final inicio = DateTime(ano, 1, 1);
      final fim = DateTime(ano, 12, 31);

      final totalAno = _animais.where((a) {
        return a.dataNascimento.isBefore(fim);
      }).length;

      final obitosAno = _animais.where((a) {
        return !a.isAtivo && a.dataObito != null && a.dataObito!.isAfter(inicio) && a.dataObito!.isBefore(fim);
      }).length;

      final taxa = totalAno > 0 ? (obitosAno / totalAno * 100) : 0.0;
      dados.add(_DadoAnual(ano: ano.toString(), valor: taxa, obitos: obitosAno, total: totalAno));
    }

    return dados;
  }

  double get _taxaGeral {
    final obitos = _animais.where((a) => !a.isAtivo && a.dataObito != null).length;
    final total = _animais.length;
    return total > 0 ? (obitos / total * 100) : 0;
  }

  bool _temDadosSuficientes() {
    return _animais.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corAppBarBg = _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final corElementos = _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final paddingTitulo = _isCollapsed ? const EdgeInsets.only(left: 60, bottom: 16) : const EdgeInsets.only(left: 16, bottom: 16);

    final dados = _gerarDadosMortalidade();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: corAppBarBg,
            iconTheme: IconThemeData(color: corElementos),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: paddingTitulo,
              expandedTitleScale: 1.6,
              title: Text('Taxa de Mortalidade', style: TextStyle(color: corElementos, fontWeight: FontWeight.bold, fontSize: 18)),
              background: Container(color: theme.colorScheme.surface, child: Align(alignment: Alignment.bottomCenter, child: Container(height: 20, decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)))))),
            ),
          ),
          if (!_temDadosSuficientes())
            SliverFillRemaining(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CardDadosInsuficientes(
                      mensagem: 'Para calcular a Taxa de Mortalidade, você precisa ter:\n\n'
                          '• Animais cadastrados no rebanho\n'
                          '• Registrar quando um animal morrer (data de óbito)',
                      botaoTexto: 'Cadastrar Animal',
                      onBotao: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormAnimal())),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.red.withValues(alpha: 0.1), theme.colorScheme.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.health_and_safety, color: Colors.red, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Taxa Geral', style: theme.textTheme.titleMedium), Text('Mortos / Total Rebanho', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))])),
                      Text('${_taxaGeral.toStringAsFixed(1)}%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: _taxaGeral <= 3 ? Colors.green : (_taxaGeral <= 5 ? Colors.orange : Colors.red))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Evolução Anual', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10,
                      barTouchData: BarTouchData(enabled: true, touchTooltipData: BarTouchTooltipData(getTooltipColor: (_) => theme.colorScheme.primaryContainer, getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dado = dados[groupIndex];
                        return BarTooltipItem('${rod.toY.toStringAsFixed(1)}%\n(${dado.obitos} ób.)', TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold));
                      })),
                      titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) { if (value.toInt() >= 0 && value.toInt() < dados.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(dados[value.toInt()].ano, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline))); return const SizedBox.shrink(); }, reservedSize: 28)), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2, getDrawingHorizontalLine: (value) => FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2), strokeWidth: 1)),
                      extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: 3, color: Colors.green.withValues(alpha: 0.5), dashArray: [5, 5], label: HorizontalLineLabel(show: true, labelResolver: (_) => 'Meta 3%', style: TextStyle(color: Colors.green, fontSize: 10)))]),
                      barGroups: dados.asMap().entries.map((entry) {
                        final cor = entry.value.valor <= 3 ? Colors.green : (entry.value.valor <= 5 ? Colors.orange : Colors.red);
                        return BarChartGroupData(x: entry.key, barRods: [BarChartRodData(toY: entry.value.valor == 0 ? 0.1 : entry.value.valor, color: cor, width: 40, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))]);
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Metas', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(children: [Icon(Icons.circle, size: 8, color: Colors.green), const SizedBox(width: 8), const Text('Ideal: < 3%')]),
                    Row(children: [Icon(Icons.circle, size: 8, color: Colors.orange), const SizedBox(width: 8), const Text('Atenção: 3 - 5%')]),
                    Row(children: [Icon(Icons.circle, size: 8, color: Colors.red), const SizedBox(width: 8), const Text('Ruim: > 5%')]),
                  ]),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DadoAnual {
  final String ano;
  final double valor;
  final int obitos;
  final int total;
  _DadoAnual({required this.ano, required this.valor, required this.obitos, required this.total});
}
