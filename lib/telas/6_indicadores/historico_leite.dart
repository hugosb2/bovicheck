import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/tema.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/eventos/producao_leite.dart';
import '../../servicos/banco_dados_servico.dart';
import 'widgets/dados_insuficientes.dart';
import '../10_formularios/form_leite.dart';

class TelaHistoricoLeite extends StatefulWidget {
  const TelaHistoricoLeite({super.key});

  @override
  State<TelaHistoricoLeite> createState() => _TelaHistoricoLeiteState();
}

class _TelaHistoricoLeiteState extends State<TelaHistoricoLeite> {
  bool _carregando = true;
  List<ProducaoLeite> _producaoLeite = [];

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
    List<ProducaoLeite> leite = [];
    for (var animal in animais) {
      leite.addAll(await db.getProducaoLeitePorAnimal(animal.id));
    }

    if (mounted) {
      setState(() {
        _producaoLeite = leite;
        _carregando = false;
      });
    }
  }

  List<_DadoMensal> _gerarDadosLeite() {
    final meses = <String, List<double>>{};
    final leiteOrd = List<ProducaoLeite>.from(_producaoLeite)..sort((a, b) => a.data.compareTo(b.data));

    for (var l in leiteOrd) {
      final chave = DateFormat('MMM/yy').format(l.data);
      if (!meses.containsKey(chave)) {
        meses[chave] = [];
      }
      meses[chave]!.add(l.litros);
    }

    return meses.entries.map((e) {
      final total = e.value.reduce((a, b) => a + b);
      return _DadoMensal(label: e.key, valor: total, media: total / e.value.length);
    }).toList();
  }

  double get _mediaGeral {
    if (_producaoLeite.isEmpty) return 0;
    return _producaoLeite.fold(0.0, (sum, item) => sum + item.litros) / _producaoLeite.length;
  }

  bool _temDadosSuficientes() {
    return _producaoLeite.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dados = _gerarDadosLeite();
    final temDadosSuficientes = _temDadosSuficientes();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Produção de Leite'),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : !temDadosSuficientes
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CardDadosInsuficientes(
                        mensagem: 'Para acompanhar o histórico de leite, você precisa registrar as produções diárias das vacas em lactação.',
                        botaoTexto: 'Registrar Leite',
                        onBotao: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormLeite())),
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
                        gradient: LinearGradient(colors: [Colors.blue.withValues(alpha: 0.1), theme.colorScheme.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.water_drop, color: Colors.blue, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Média Geral', style: theme.textTheme.titleMedium), Text('Litros por ordenha/animal', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))])),
                          Text('${_mediaGeral.toStringAsFixed(1)} L', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Produção Mensal (Total L)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _CardGrafico(dado: dados, cor: Colors.blue),
                    const SizedBox(height: 40),
                  ],
                ),
    );
  }
}

class _DadoMensal {
  final String label;
  final double valor;
  final double media;
  _DadoMensal({required this.label, required this.valor, required this.media});
}

class _CardGrafico extends StatelessWidget {
  final List<_DadoMensal> dado;
  final Color cor;

  const _CardGrafico({required this.dado, required this.cor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: dado.reversed.map((d) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Média: ${d.media.toStringAsFixed(1)} L', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
              Text(
                '${d.valor.toStringAsFixed(0)} L',
                style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
