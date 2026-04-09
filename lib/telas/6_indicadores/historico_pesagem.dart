import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/tema.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/eventos/pesagem.dart';
import '../../modelos/animal.dart';
import '../../servicos/banco_dados_servico.dart';
import 'widgets/dados_insuficientes.dart';
import '../10_formularios/form_pesagem.dart';

class TelaHistoricoPesagem extends StatefulWidget {
  const TelaHistoricoPesagem({super.key});

  @override
  State<TelaHistoricoPesagem> createState() => _TelaHistoricoPesagemState();
}

class _TelaHistoricoPesagemState extends State<TelaHistoricoPesagem> {
  bool _carregando = true;
  List<Pesagem> _pesagens = [];
  List<Animal> _animais = [];

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

  double get _pesoMedio {
    if (_animais.isEmpty) return 0;
    final animaisAtivos = _animais.where((a) => a.isAtivo).toList();
    if (animaisAtivos.isEmpty) return 0;
    return animaisAtivos.fold(0.0, (sum, item) => sum + item.pesoAtualKg) / animaisAtivos.length;
  }

  bool _temDadosSuficientes() {
    return _pesagens.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final temDadosSuficientes = _temDadosSuficientes();

    // Ordena as pesagens por data (mais recente primeiro)
    final pesagensOrd = List<Pesagem>.from(_pesagens)..sort((a, b) => b.data.compareTo(a.data));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Histórico de Pesagens'),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : !temDadosSuficientes
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CardDadosInsuficientes(
                        mensagem: 'Nenhuma pesagem registrada no sistema.',
                        botaoTexto: 'Registrar Peso',
                        onBotao: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormPesagem())),
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
                        gradient: LinearGradient(colors: [Colors.indigo.withValues(alpha: 0.1), theme.colorScheme.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.monitor_weight, color: Colors.indigo, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Peso Médio Atual', style: theme.textTheme.titleMedium), Text('Média dos animais ativos', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))])),
                          Text('${_pesoMedio.toStringAsFixed(1)} kg', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.indigo)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Últimas Pesagens', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...pesagensOrd.take(50).map((p) {
                      final animal = _animais.firstWhere((a) => a.id == p.animalId, orElse: () => Animal(id: '', brinco: '?', raca: '?', sexo: '?', categoria: '?', dataNascimento: DateTime.now(), pesoAtualKg: 0, fazendaId: '', loteId: ''));
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Brinco ${animal.brinco}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(DateFormat('dd/MM/yyyy').format(p.data), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${p.pesoKg.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                                Text(p.etapa, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 40),
                  ],
                ),
    );
  }
}
