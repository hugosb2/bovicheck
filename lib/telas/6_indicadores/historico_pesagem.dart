import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/cores.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/eventos/pesagem.dart';
import '../../modelos/animal.dart';
import '../../servicos/banco_dados_servico.dart';

class TelaHistoricoPesagem extends StatefulWidget {
  const TelaHistoricoPesagem({super.key});

  @override
  State<TelaHistoricoPesagem> createState() => _TelaHistoricoPesagemState();
}

class _TelaHistoricoPesagemState extends State<TelaHistoricoPesagem> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;
  bool _carregando = true;
  List<Pesagem> _pesagens = [];
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

  Future<void> _carregarDados() async {
    final provedor = context.read<ProvedorFazenda>();
    if (provedor.propriedadeAtiva == null) return;

    setState(() => _carregando = true);
    final db = BancoDadosServico.instancia;

    final animais = provedor.animais;
    List<Pesagem> pesagens = [];
    for (var animal in animais) {
      pesagens.addAll(await db.getPesagensPorAnimal(animal.id));
    }

    if (mounted) {
      setState(() {
        _animais = animais;
        _pesagens = pesagens;
        _carregando = false;
      });
    }
  }

  List<_DadoMensal> _gerarDadosPesoMedio() {
    final mesesPesos = <String, List<double>>{};
    final now = DateTime.now();
    
    for (var i = 11; i >= 0; i--) {
      final data = DateTime(now.year, now.month - i, 1);
      final chave = DateFormat('MMM/yy').format(data);
      mesesPesos[chave] = [];
    }

    for (var p in _pesagens) {
      final chave = DateFormat('MMM/yy').format(p.data);
      if (mesesPesos.containsKey(chave)) {
        mesesPesos[chave]!.add(p.pesoKg);
      }
    }

    return mesesPesos.entries.map((e) {
      if (e.value.isEmpty) return _DadoMensal(label: e.key, valor: 0);
      final media = e.value.reduce((a, b) => a + b) / e.value.length;
      return _DadoMensal(label: e.key, valor: media);
    }).toList();
  }

  List<_DadoMensal> _gerarDadosContagem() {
    final meses = <String, int>{};
    final now = DateTime.now();
    
    for (var i = 11; i >= 0; i--) {
      final data = DateTime(now.year, now.month - i, 1);
      final chave = DateFormat('MMM/yy').format(data);
      meses[chave] = 0;
    }

    for (var p in _pesagens) {
      final chave = DateFormat('MMM/yy').format(p.data);
      if (meses.containsKey(chave)) {
        meses[chave] = meses[chave]! + 1;
      }
    }

    return meses.entries.map((e) {
      return _DadoMensal(label: e.key, valor: e.value.toDouble());
    }).toList();
  }

  double get _pesoMedioGeral {
    if (_pesagens.isEmpty) return 0;
    return _pesagens.fold(0.0, (sum, p) => sum + p.pesoKg) / _pesagens.length;
  }

  double get _maiorPeso {
    if (_pesagens.isEmpty) return 0;
    return _pesagens.map((p) => p.pesoKg).reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corAppBarBg = _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final corElementos = _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final paddingTitulo = _isCollapsed ? const EdgeInsets.only(left: 60, bottom: 16) : const EdgeInsets.only(left: 16, bottom: 16);

    final dadosMedia = _gerarDadosPesoMedio();
    final dadosContagem = _gerarDadosContagem();

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
              title: Text(
                'Pesagens',
                style: TextStyle(color: corElementos, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                color: theme.colorScheme.surface,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_carregando)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: _CardKPI(
                          titulo: 'Peso Médio',
                          valor: '${_pesoMedioGeral.toStringAsFixed(1)} kg',
                          icone: Icons.monitor_weight,
                          cor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CardKPI(
                          titulo: 'Maior Peso',
                          valor: '${_maiorPeso.toStringAsFixed(1)} kg',
                          icone: Icons.arrow_upward,
                          cor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CardGrafico(
                    titulo: 'Peso Médio Mensal (kg)',
                    dado: dadosMedia,
                    cor: Colors.green,
                    descricao: 'Média de peso dos animais por mês',
                  ),
                  const SizedBox(height: 16),
                  _CardGrafico(
                    titulo: 'Quantidade de Pesagens',
                    dado: dadosContagem,
                    cor: Colors.orange,
                    descricao: 'Número de pesagens realizadas por mês',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Últimas Pesagens',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _ListaPesagens(pesagens: _pesagens, animais: _animais),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _DadoMensal {
  final String label;
  final double valor;
  _DadoMensal({required this.label, required this.valor});
}

class _CardKPI extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;

  const _CardKPI({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: cor, size: 20),
              const SizedBox(width: 8),
              Text(titulo, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ],
          ),
          const SizedBox(height: 8),
          Text(valor, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: cor)),
        ],
      ),
    );
  }
}

class _CardGrafico extends StatelessWidget {
  final String titulo;
  final List<_DadoMensal> dado;
  final Color cor;
  final String descricao;

  const _CardGrafico({
    required this.titulo,
    required this.dado,
    required this.cor,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dadosValidos = dado.where((d) => d.valor > 0).toList();
    final maxValor = dado.map((d) => d.valor).fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(descricao, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          if (dadosValidos.isEmpty)
            Container(
              height: 150,
              alignment: Alignment.center,
              child: Text('Sem dados', style: TextStyle(color: theme.colorScheme.outline)),
            )
          else
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValor * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.primaryContainer,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toStringAsFixed(1),
                          TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < dado.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(dado[index].label, style: TextStyle(fontSize: 9, color: theme.colorScheme.outline)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: dado.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.valor,
                          color: cor,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

class _ListaPesagens extends StatelessWidget {
  final List<Pesagem> pesagens;
  final List<Animal> animais;

  const _ListaPesagens({required this.pesagens, required this.animais});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pesagensOrdenadas = List<Pesagem>.from(pesagens)..sort((a, b) => b.data.compareTo(a.data));

    if (pesagensOrdenadas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Nenhuma pesagem registrada', style: TextStyle(color: theme.colorScheme.outline)),
      );
    }

    return Column(
      children: pesagensOrdenadas.take(15).map((p) {
        final animal = animais.where((a) => a.id == p.animalId).firstOrNull;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.monitor_weight, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(animal?.brinco ?? 'Animal', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (p.etapa != null && p.etapa!.isNotEmpty)
                      Text(p.etapa!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
              Text(
                '${p.pesoKg.toStringAsFixed(1)} kg',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(width: 8),
              Text(DateFormat('dd/MM').format(p.data), style: theme.textTheme.bodySmall),
            ],
          ),
        );
      }).toList(),
    );
  }
}
