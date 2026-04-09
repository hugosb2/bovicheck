import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/eventos/pesagem.dart';
import '../../modelos/animal.dart';
import '../../servicos/banco_dados_servico.dart';
import 'widgets/dados_insuficientes.dart';
import '../10_formularios/form_pesagem.dart';

class TelaHistoricoGMD extends StatefulWidget {
  const TelaHistoricoGMD({super.key});

  @override
  State<TelaHistoricoGMD> createState() => _TelaHistoricoGMDState();
}

class _TelaHistoricoGMDState extends State<TelaHistoricoGMD> {
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

  List<_DadoMensal> _gerarDadosGMD() {
    final meses = <String, List<double>>{};

    Map<String, Map<String, Pesagem>> mapaPesos = {};
    final pesagensOrd = List<Pesagem>.from(_pesagens)..sort((a, b) => a.data.compareTo(b.data));

    for (var p in pesagensOrd) {
      if (p.etapa == 'Nascimento' || p.etapa == 'Desmame') {
        if (!mapaPesos.containsKey(p.animalId)) mapaPesos[p.animalId] = {};
        mapaPesos[p.animalId]![p.etapa] = p;
      }
    }

    for (var entry in mapaPesos.entries) {
      final etapas = entry.value;
      if (etapas.containsKey('Nascimento') && etapas.containsKey('Desmame')) {
        final nasc = etapas['Nascimento']!;
        final desm = etapas['Desmame']!;
        final dias = desm.data.difference(nasc.data).inDays;
        final ganho = desm.pesoKg - nasc.pesoKg;
        if (dias > 60 && ganho > 0) {
          final gmd = ganho / dias;
          final chave = DateFormat('MMM/yy').format(desm.data);
          if (!meses.containsKey(chave)) {
            meses[chave] = [];
          }
          meses[chave]!.add(gmd);
        }
      }
    }

    return meses.entries.map((e) {
      if (e.value.isEmpty) return _DadoMensal(label: e.key, valor: 0, sortKey: e.key);
      final media = e.value.reduce((a, b) => a + b) / e.value.length;
      return _DadoMensal(label: e.key, valor: media * 1000, sortKey: e.key);
    }).toList();
  }

  double get _gmdMedio {
    Map<String, Map<String, Pesagem>> mapaPesos = {};
    for (var p in _pesagens) {
      if (p.etapa == 'Nascimento' || p.etapa == 'Desmame') {
        if (!mapaPesos.containsKey(p.animalId)) mapaPesos[p.animalId] = {};
        mapaPesos[p.animalId]![p.etapa] = p;
      }
    }

    List<double> gmds = [];
    for (var entry in mapaPesos.entries) {
      final etapas = entry.value;
      if (etapas.containsKey('Nascimento') && etapas.containsKey('Desmame')) {
        final nasc = etapas['Nascimento']!;
        final desm = etapas['Desmame']!;
        final dias = desm.data.difference(nasc.data).inDays;
        final ganho = desm.pesoKg - nasc.pesoKg;
        if (dias > 60 && ganho > 0) gmds.add(ganho / dias);
      }
    }

    if (gmds.isEmpty) return 0;
    return gmds.reduce((a, b) => a + b) / gmds.length;
  }

  bool _temDadosSuficientes() {
    Map<String, Map<String, Pesagem>> mapaPesos = {};
    for (var p in _pesagens) {
      if (p.etapa == 'Nascimento' || p.etapa == 'Desmame') {
        if (!mapaPesos.containsKey(p.animalId)) mapaPesos[p.animalId] = {};
        mapaPesos[p.animalId]![p.etapa] = p;
      }
    }
    return mapaPesos.values.any((etapas) => etapas.containsKey('Nascimento') && etapas.containsKey('Desmame'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corAppBarBg = _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final corElementos = _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final paddingTitulo = _isCollapsed ? const EdgeInsets.only(left: 60, bottom: 16) : const EdgeInsets.only(left: 16, bottom: 16);

    final dados = _gerarDadosGMD();
    final temDadosSuficientes = _temDadosSuficientes();

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
                'Ganho Médio Diário',
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
          else if (!temDadosSuficientes)
            SliverFillRemaining(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CardDadosInsuficientes(
                      mensagem: 'Para calcular o GMD (Ganho Médio Diário), você precisa ter pesagens de:\n\n'
                          '• Peso ao Nascimento\n'
                          '• Peso ao Desmama\n\n'
                          'Do mesmo animal em momentos diferentes.',
                      botaoTexto: 'Cadastrar Pesagem',
                      onBotao: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormPesagem())),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Como funciona:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('O GMD = (Peso Desmama - Peso Nascimento) ÷ Dias entre pesagens', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          Text('Você precisa de pelo menos 2 pesagens (Nascimento e Desmama) do mesmo animal.', style: theme.textTheme.bodySmall),
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.withValues(alpha: 0.1), theme.colorScheme.surface],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.trending_up, color: Colors.orange, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GMD Médio', style: theme.textTheme.titleMedium),
                              Text('Nascimento → Desmama', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                            ],
                          ),
                        ),
                        Text(
                          '${(_gmdMedio * 1000).toStringAsFixed(1)} g/dia',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Evolução Mensal (g/dia)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _CardGrafico(dado: dados, cor: Colors.orange),
                  const SizedBox(height: 40),
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
  final List<_DadoMensal> dado;
  final Color cor;

  const _CardGrafico({required this.dado, required this.cor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dadosValidos = dado.where((d) => d.valor > 0).toList();

    if (dadosValidos.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text('Sem dados suficientes para calcular GMD', style: TextStyle(color: theme.colorScheme.outline)),
      );
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
                '${d.valor.toStringAsFixed(0)} g/dia',
                style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
