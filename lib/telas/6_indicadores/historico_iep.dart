import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/eventos/evento_reprodutivo.dart';
import '../../modelos/animal.dart';
import '../../servicos/banco_dados_servico.dart';
import 'widgets/dados_insuficientes.dart';
import '../10_formularios/form_reprodutivo.dart';

class TelaHistoricoIEP extends StatefulWidget {
  const TelaHistoricoIEP({super.key});

  @override
  State<TelaHistoricoIEP> createState() => _TelaHistoricoIEPState();
}

class _TelaHistoricoIEPState extends State<TelaHistoricoIEP> {
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

  double get _iepMedio {
    Map<String, List<DateTime>> partosPorVaca = {};
    for (var evento in _eventos) {
      if (evento.tipo == 'Parto') {
        if (!partosPorVaca.containsKey(evento.animalId)) partosPorVaca[evento.animalId] = [];
        partosPorVaca[evento.animalId]!.add(evento.data);
      }
    }

    List<int> intervalos = [];
    for (var entry in partosPorVaca.entries) {
      final datas = entry.value;
      if (datas.length >= 2) {
        for (var i = 0; i < datas.length - 1; i++) {
          final diff = datas[i + 1].difference(datas[i]).inDays;
          if (diff > 250) intervalos.add(diff);
        }
      }
    }

    if (intervalos.isEmpty) return 0;
    return intervalos.reduce((a, b) => a + b) / intervalos.length / 30.44;
  }

  List<_DadoMensal> _gerarDadosIEP() {
    Map<String, List<int>> intervalosPorAno = {};

    Map<String, List<DateTime>> partosPorVaca = {};
    final eventosOrd = List<EventoReprodutivo>.from(_eventos)..sort((a, b) => a.data.compareTo(b.data));

    for (var evento in eventosOrd) {
      if (evento.tipo == 'Parto') {
        if (!partosPorVaca.containsKey(evento.animalId)) partosPorVaca[evento.animalId] = [];
        partosPorVaca[evento.animalId]!.add(evento.data);
      }
    }

    for (var entry in partosPorVaca.entries) {
      final datas = entry.value;
      if (datas.length >= 2) {
        for (var i = 0; i < datas.length - 1; i++) {
          final intervaloDias = datas[i + 1].difference(datas[i]).inDays;
          if (intervaloDias > 250 && intervaloDias < 600) {
            final ano = datas[i + 1].year.toString();
            if (!intervalosPorAno.containsKey(ano)) {
              intervalosPorAno[ano] = [];
            }
            intervalosPorAno[ano]!.add(intervaloDias);
          }
        }
      }
    }

    return intervalosPorAno.entries.map((e) {
      if (e.value.isEmpty) return _DadoMensal(label: e.key, valor: 0, sortKey: e.key);
      final media = e.value.reduce((a, b) => a + b) / e.value.length / 30.44;
      return _DadoMensal(label: e.key, valor: media, sortKey: e.key);
    }).toList();
  }

  bool _temDadosSuficientes() {
    Map<String, List<DateTime>> partosPorVaca = {};
    for (var evento in _eventos) {
      if (evento.tipo == 'Parto') {
        if (!partosPorVaca.containsKey(evento.animalId)) partosPorVaca[evento.animalId] = [];
        partosPorVaca[evento.animalId]!.add(evento.data);
      }
    }
    return partosPorVaca.values.any((datas) => datas.length >= 2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corAppBarBg = _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final corElementos = _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final paddingTitulo = _isCollapsed ? const EdgeInsets.only(left: 60, bottom: 16) : const EdgeInsets.only(left: 16, bottom: 16);

    final dados = _gerarDadosIEP();

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
              title: Text('Intervalo Entre Partos', style: TextStyle(color: corElementos, fontWeight: FontWeight.bold, fontSize: 18)),
              background: Container(color: theme.colorScheme.surface, child: Align(alignment: Alignment.bottomCenter, child: Container(height: 20, decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)))))),
            ),
          ),
          if (_carregando)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (!_temDadosSuficientes())
            SliverFillRemaining(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CardDadosInsuficientes(
                      mensagem: 'Para calcular o IEP (Intervalo Entre Partos), você precisa ter:\n\n'
                          '• Pelo menos 2 partos registrados\n\n'
                          'Da mesma fêmea em momentos diferentes.',
                      botaoTexto: 'Cadastrar Evento Reprodutivo',
                      onBotao: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormReprodutivo())),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Como funciona:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('O IEP é calculado pela média de dias entre partos consecutivos da mesma vaca.', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Text('Meta: < 12 meses (365 dias)', style: theme.textTheme.bodySmall),
                        ],
                      ),
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
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.indigo.withValues(alpha: 0.1), theme.colorScheme.surface], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.indigo.withValues(alpha: 0.3))),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.calendar_month, color: Colors.indigo, size: 32)),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('IEP Médio', style: theme.textTheme.titleMedium), Text('Média entre partos', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))])),
                        Text('${_iepMedio.toStringAsFixed(1)} meses', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Evolução Anual (meses)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _CardGrafico(dado: dados, cor: Colors.indigo),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Metas', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _LinhaMeta('Ideal', '< 12 meses', Colors.green),
                      _LinhaMeta('Atenção', '12 - 14 meses', Colors.orange),
                      _LinhaMeta('Ruim', '> 14 meses', Colors.red),
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

class _DadoMensal { final String label; final double valor; final String sortKey; _DadoMensal({required this.label, required this.valor, this.sortKey = ''}); }

class _LinhaMeta extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;
  const _LinhaMeta(this.label, this.valor, this.cor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Icon(Icons.circle, size: 8, color: cor), const SizedBox(width: 8), Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)), Text(valor)]),
    );
  }
}

class _CardGrafico extends StatelessWidget {
  final List<_DadoMensal> dado;
  final Color cor;
  const _CardGrafico({required this.dado, required this.cor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dadosValidos = dado.where((d) => d.valor > 0).toList();

    if (dadosValidos.isEmpty) {
      return Container(height: 100, alignment: Alignment.center, decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16)), child: Text('Sem dados de IEP', style: TextStyle(color: theme.colorScheme.outline)));
    }

    return Column(
      children: dadosValidos.reversed.map((d) {
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
                '${d.valor.toStringAsFixed(1)} meses',
                style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
