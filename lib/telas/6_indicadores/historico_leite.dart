import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/cores.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/eventos/producao_leite.dart';
import '../../modelos/animal.dart';
import '../../servicos/banco_dados_servico.dart';

class TelaHistoricoLeite extends StatefulWidget {
  const TelaHistoricoLeite({super.key});

  @override
  State<TelaHistoricoLeite> createState() => _TelaHistoricoLeiteState();
}

class _TelaHistoricoLeiteState extends State<TelaHistoricoLeite> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;
  bool _carregando = true;
  List<ProducaoLeite> _producoes = [];
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
    List<ProducaoLeite> producoes = [];
    for (var animal in animais) {
      producoes.addAll(await db.getProducaoLeitePorAnimal(animal.id));
    }

    if (mounted) {
      setState(() {
        _animais = animais;
        _producoes = producoes;
        _carregando = false;
      });
    }
  }

  List<_DadoMensal> _gerarDadosLeite() {
    final mesesLitros = <String, double>{};
    final mesesContagem = <String, int>{};

    final producoes = List<ProducaoLeite>.from(_producoes)..sort((a, b) => a.data.compareTo(b.data));

    for (var p in producoes) {
      final chave = DateFormat('MMM/yy').format(p.data);
      if (!mesesLitros.containsKey(chave)) {
        mesesLitros[chave] = 0;
        mesesContagem[chave] = 0;
      }
      mesesLitros[chave] = mesesLitros[chave]! + p.litros;
      mesesContagem[chave] = mesesContagem[chave]! + 1;
    }

    return mesesLitros.entries.map((e) {
      final contagem = mesesContagem[e.key] ?? 1;
      final media = contagem > 0 ? e.value / contagem : 0.0;
      return _DadoMensal(label: e.key, valor: media, sortKey: e.key);
    }).toList();
  }

  List<_DadoMensal> _gerarDadosTotalLeite() {
    final meses = <String, double>{};

    final producoes = List<ProducaoLeite>.from(_producoes)..sort((a, b) => a.data.compareTo(b.data));

    for (var p in producoes) {
      final chave = DateFormat('MMM/yy').format(p.data);
      if (!meses.containsKey(chave)) {
        meses[chave] = 0;
      }
      meses[chave] = meses[chave]! + p.litros;
    }

    return meses.entries.map((e) {
      return _DadoMensal(label: e.key, valor: e.value, sortKey: e.key);
    }).toList();
  }

  double get _mediaGeral {
    if (_producoes.isEmpty) return 0;
    return _producoes.fold(0.0, (sum, p) => sum + p.litros) / _producoes.length;
  }

  double get _totalGeral {
    return _producoes.fold(0.0, (sum, p) => sum + p.litros);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corAppBarBg = _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final corElementos = _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final paddingTitulo = _isCollapsed ? const EdgeInsets.only(left: 60, bottom: 16) : const EdgeInsets.only(left: 16, bottom: 16);

    final dadosMedia = _gerarDadosLeite();
    final dadosTotal = _gerarDadosTotalLeite();

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
                'Produção de Leite',
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
                          titulo: 'Média Geral',
                          valor: '${_mediaGeral.toStringAsFixed(1)} L',
                          icone: Icons.water_drop,
                          cor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CardKPI(
                          titulo: 'Total Período',
                          valor: '${_totalGeral.toStringAsFixed(0)} L',
                          icone: Icons.inventory_2,
                          cor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CardGrafico(
                    titulo: 'Média por Ordenha (L)',
                    dado: dadosMedia,
                    cor: Colors.blue,
                    descricao: 'Média diária de produção',
                  ),
                  const SizedBox(height: 16),
                  _CardGrafico(
                    titulo: 'Total Mensal (L)',
                    dado: dadosTotal,
                    cor: Colors.green,
                    descricao: 'Volume total produzido por mês',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Últimas Ordenhas',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _ListaOrdenhas(producoes: _producoes),
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
  final String sortKey;
  _DadoMensal({required this.label, required this.valor, this.sortKey = ''});
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo.isNotEmpty) ...[
           Text(titulo, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
           const SizedBox(height: 2),
           Text(descricao, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
           const SizedBox(height: 16),
        ],
        if (dadosValidos.isEmpty)
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('Sem dados', style: TextStyle(color: theme.colorScheme.outline)),
          )
        else
          ...dadosValidos.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(d.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    d.valor == d.valor.toInt() ? d.valor.toInt().toString() : d.valor.toStringAsFixed(1),
                    style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            );
          }),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

class _ListaOrdenhas extends StatelessWidget {
  final List<ProducaoLeite> producoes;

  const _ListaOrdenhas({required this.producoes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordenhasOrdenadas = List<ProducaoLeite>.from(producoes)..sort((a, b) => b.data.compareTo(a.data));

    if (ordenhasOrdenadas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Nenhuma produção registrada', style: TextStyle(color: theme.colorScheme.outline)),
      );
    }

    return Column(
      children: ordenhasOrdenadas.take(15).map((p) {
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.water_drop, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ordenha', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(
                '${p.litros.toStringAsFixed(1)} L',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue),
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
