import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/cores.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/eventos/evento_reprodutivo.dart';
import '../../modelos/animal.dart';
import '../../servicos/banco_dados_servico.dart';

class TelaHistoricoReproducao extends StatefulWidget {
  const TelaHistoricoReproducao({super.key});

  @override
  State<TelaHistoricoReproducao> createState() => _TelaHistoricoReproducaoState();
}

class _TelaHistoricoReproducaoState extends State<TelaHistoricoReproducao> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;
  bool _carregando = true;
  List<EventoReprodutivo> _eventos = [];
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
    List<EventoReprodutivo> eventos = [];
    for (var animal in animais) {
      eventos.addAll(await db.getEventosReprodutivosPorAnimal(animal.id));
    }

    if (mounted) {
      setState(() {
        _animais = animais;
        _eventos = eventos;
        _carregando = false;
      });
    }
  }

  List<_DadoMensal> _gerarDadosNatalidade() {
    final meses = <String, int>{};

    final totalFemeas = _animais.where((a) => a.sexo == 'F' && a.calcularIdadeMeses() >= 24).length;

    final eventosOrd = List<EventoReprodutivo>.from(_eventos)..sort((a, b) => a.data.compareTo(b.data));

    for (var evento in eventosOrd) {
      if (evento.tipo == 'Parto') {
        final chave = DateFormat('MMM/yy').format(evento.data);
        if (!meses.containsKey(chave)) {
          meses[chave] = 0;
        }
        meses[chave] = meses[chave]! + 1;
      }
    }

    return meses.entries.map((e) {
      final valor = totalFemeas > 0 ? (e.value / totalFemeas * 100).clamp(0.0, 100.0) : 0.0;
      return _DadoMensal(label: e.key, valor: valor, sortKey: e.key);
    }).toList();
  }

  List<_DadoMensal> _gerarDadosPrenhez() {
    final meses = <String, int>{};
    final mesesTotal = <String, int>{};

    final eventosOrd = List<EventoReprodutivo>.from(_eventos)..sort((a, b) => a.data.compareTo(b.data));

    for (var evento in eventosOrd) {
      if (evento.tipo.contains('Diagnóstico')) {
        final chave = DateFormat('MMM/yy').format(evento.data);
        if (!meses.containsKey(chave)) {
          meses[chave] = 0;
          mesesTotal[chave] = 0;
        }
        mesesTotal[chave] = mesesTotal[chave]! + 1;
        if ((evento.resultado?.toLowerCase().contains('prenhe') ?? false) ||
            (evento.resultado?.toLowerCase().contains('positivo') ?? false)) {
          meses[chave] = meses[chave]! + 1;
        }
      }
    }

    return meses.entries.map((e) {
      final total = mesesTotal[e.key] ?? 1;
      final valor = total > 0 ? (e.value / total * 100).clamp(0.0, 100.0) : 0.0;
      return _DadoMensal(label: e.key, valor: valor, sortKey: e.key);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corAppBarBg = _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final corElementos = _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final paddingTitulo = _isCollapsed ? const EdgeInsets.only(left: 60, bottom: 16) : const EdgeInsets.only(left: 16, bottom: 16);

    final dadosNatalidade = _gerarDadosNatalidade();
    final dadosPrenhez = _gerarDadosPrenhez();

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
                'Reprodução',
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
                  _CardGrafico(
                    titulo: 'Taxa de Natalidade (%)',
                    dado: dadosNatalidade,
                    cor: Colors.pink,
                    descricao: 'Nascimentos por fêmea apta',
                  ),
                  const SizedBox(height: 16),
                  _CardGrafico(
                    titulo: 'Taxa de Prenhez (%)',
                    dado: dadosPrenhez,
                    cor: Colors.purple,
                    descricao: 'Diagnósticos positivos',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Histórico de Eventos Reprodutivos',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _ListaEventos(eventos: _eventos),
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
                    d.valor == d.valor.toInt() ? '${d.valor.toInt().toString()}%' : '${d.valor.toStringAsFixed(1)}%',
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

class _ListaEventos extends StatelessWidget {
  final List<EventoReprodutivo> eventos;

  const _ListaEventos({required this.eventos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventosOrdenados = List<EventoReprodutivo>.from(eventos)..sort((a, b) => b.data.compareTo(a.data));

    if (eventosOrdenados.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('Nenhum evento reprodutivo registrado', style: TextStyle(color: theme.colorScheme.outline)),
      );
    }

    return Column(
      children: eventosOrdenados.take(20).map((e) {
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
                  color: _getCorTipo(e.tipo).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getIconeTipo(e.tipo), color: _getCorTipo(e.tipo), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.tipo, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (e.resultado != null && e.resultado!.isNotEmpty)
                      Text(e.resultado!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
              Text(DateFormat('dd/MM/yy').format(e.data), style: theme.textTheme.bodySmall),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconeTipo(String tipo) {
    if (tipo.contains('Parto')) return Icons.child_care;
    if (tipo.contains('Diagnóstico')) return Icons.search;
    if (tipo.contains('Inseminação') || tipo.contains('IA')) return Icons.science;
    if (tipo.contains('Cobertura')) return Icons.favorite;
    return Icons.event;
  }

  Color _getCorTipo(String tipo) {
    if (tipo.contains('Parto')) return Colors.green;
    if (tipo.contains('Diagnóstico')) return Colors.purple;
    if (tipo.contains('Inseminação') || tipo.contains('IA')) return Colors.blue;
    if (tipo.contains('Cobertura')) return Colors.pink;
    return Colors.grey;
  }
}
