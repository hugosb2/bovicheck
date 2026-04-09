import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/eventos/evento_reprodutivo.dart';
import '../../servicos/banco_dados_servico.dart';
import 'widgets/dados_insuficientes.dart';
import '../10_formularios/form_reprodutivo.dart';

class TelaHistoricoIEP extends StatefulWidget {
  const TelaHistoricoIEP({super.key});

  @override
  State<TelaHistoricoIEP> createState() => _TelaHistoricoIEPState();
}

class _TelaHistoricoIEPState extends State<TelaHistoricoIEP> {
  bool _carregando = true;
  List<EventoReprodutivo> _eventosReprodutivos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDados());
  }

  Future<void> _carregarDados() async {
    final provedor = context.read<ProvedorFazenda>();
    if (provedor.propriedadeAtiva == null) return;

    setState(() => _carregando = true);
    final db = BancoDadosServico.instancia;

    final animais = provedor.animais;
    List<EventoReprodutivo> reprodutivos = [];
    for (var animal in animais) {
      reprodutivos.addAll(await db.getEventosReprodutivosPorAnimal(animal.id));
    }

    if (mounted) {
      setState(() {
        _eventosReprodutivos = reprodutivos;
        _carregando = false;
      });
    }
  }

  List<_DadoMensal> _gerarDadosIEP() {
    Map<String, List<DateTime>> partosPorVaca = {};
    for (var evento in _eventosReprodutivos) {
      if (evento.tipo == 'Parto') {
        if (!partosPorVaca.containsKey(evento.animalId)) {
          partosPorVaca[evento.animalId] = [];
        }
        partosPorVaca[evento.animalId]!.add(evento.data);
      }
    }

    final meses = <String, List<double>>{};
    partosPorVaca.forEach((id, datas) {
      if (datas.length >= 2) {
        datas.sort();
        for (int i = 0; i < datas.length - 1; i++) {
          final diff = datas[i + 1].difference(datas[i]).inDays;
          if (diff > 250) {
            final iepMeses = diff / 30.44;
            final chave = DateFormat('MMM/yy').format(datas[i + 1]);
            if (!meses.containsKey(chave)) meses[chave] = [];
            meses[chave]!.add(iepMeses);
          }
        }
      }
    });

    return meses.entries.map((e) {
      final media = e.value.reduce((a, b) => a + b) / e.value.length;
      return _DadoMensal(label: e.key, valor: media);
    }).toList();
  }

  double get _iepMedio {
    Map<String, List<DateTime>> partosPorVaca = {};
    for (var evento in _eventosReprodutivos) {
      if (evento.tipo == 'Parto') {
        if (!partosPorVaca.containsKey(evento.animalId)) {
          partosPorVaca[evento.animalId] = [];
        }
        partosPorVaca[evento.animalId]!.add(evento.data);
      }
    }

    List<int> intervalosDias = [];
    partosPorVaca.forEach((id, datas) {
      if (datas.length >= 2) {
        datas.sort();
        for (int i = 0; i < datas.length - 1; i++) {
          final diff = datas[i + 1].difference(datas[i]).inDays;
          if (diff > 250) intervalosDias.add(diff);
        }
      }
    });

    if (intervalosDias.isEmpty) return 0;
    return (intervalosDias.reduce((a, b) => a + b) / intervalosDias.length) / 30.44;
  }

  bool _temDadosSuficientes() {
    Map<String, List<DateTime>> partosPorVaca = {};
    for (var evento in _eventosReprodutivos) {
      if (evento.tipo == 'Parto') {
        if (!partosPorVaca.containsKey(evento.animalId)) {
          partosPorVaca[evento.animalId] = [];
        }
        partosPorVaca[evento.animalId]!.add(evento.data);
      }
    }
    return partosPorVaca.values.any((datas) => datas.length >= 2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dados = _gerarDadosIEP();
    final temDadosSuficientes = _temDadosSuficientes();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Intervalo Entre Partos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : !temDadosSuficientes
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CardDadosInsuficientes(
                        mensagem: 'Para calcular o IEP (Intervalo Entre Partos), você precisa ter:\n\n'
                            '• Pelo menos 2 partos registrados\n'
                            '• Do mesmo animal em datas diferentes.',
                        botaoTexto: 'Registrar Reprodução',
                        onBotao: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormReprodutivo())),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.purple.withValues(alpha: 0.1), theme.colorScheme.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.favorite, color: Colors.purple, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('IEP Médio', style: theme.textTheme.titleMedium), Text('Média do Rebanho', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))])),
                          Text('${_iepMedio.toStringAsFixed(1)} meses', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.purple)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Evolução Mensal (meses)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _CardGrafico(dado: dados, cor: Colors.purple),
                    const SizedBox(height: 40),
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

class _CardGrafico extends StatelessWidget {
  final List<_DadoMensal> dado;
  final Color cor;

  const _CardGrafico({required this.dado, required this.cor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dadosValidos = dado.toList();

    if (dadosValidos.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text('Sem dados suficientes para exibir o gráfico', style: TextStyle(color: theme.colorScheme.outline)),
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
