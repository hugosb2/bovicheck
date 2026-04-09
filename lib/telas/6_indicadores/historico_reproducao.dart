import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/tema.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/eventos/evento_reprodutivo.dart';
import '../../modelos/animal.dart';
import '../../servicos/banco_dados_servico.dart';
import 'widgets/dados_insuficientes.dart';
import '../10_formularios/form_reprodutivo.dart';

class TelaHistoricoReproducao extends StatefulWidget {
  const TelaHistoricoReproducao({super.key});

  @override
  State<TelaHistoricoReproducao> createState() => _TelaHistoricoReproducaoState();
}

class _TelaHistoricoReproducaoState extends State<TelaHistoricoReproducao> {
  bool _carregando = true;
  List<EventoReprodutivo> _eventosReprodutivos = [];
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
    List<EventoReprodutivo> reprodutivos = [];
    for (var animal in animais) {
      reprodutivos.addAll(await db.getEventosReprodutivosPorAnimal(animal.id));
    }

    if (mounted) {
      setState(() {
        _animais = animais;
        _eventosReprodutivos = reprodutivos;
        _carregando = false;
      });
    }
  }

  double get _taxaNatalidade {
    final nascimentos = _eventosReprodutivos.where((e) => e.tipo == 'Parto').length;
    final femeasAptas = _animais.where((a) => a.sexo == 'F' && a.calcularIdadeMeses() >= 24).length;
    if (femeasAptas == 0) return 0;
    return (nascimentos / femeasAptas) * 100;
  }

  bool _temDadosSuficientes() {
    return _eventosReprodutivos.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final temDadosSuficientes = _temDadosSuficientes();

    // Ordena por data (mais recente primeiro)
    final eventosOrd = List<EventoReprodutivo>.from(_eventosReprodutivos)..sort((a, b) => b.data.compareTo(a.data));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Histórico Reprodutivo'),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : !temDadosSuficientes
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CardDadosInsuficientes(
                        mensagem: 'Nenhum evento reprodutivo registrado.',
                        botaoTexto: 'Registrar Evento',
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
                        gradient: LinearGradient(colors: [Colors.pink.withValues(alpha: 0.1), theme.colorScheme.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.favorite, color: Colors.pink, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Natalidade Geral', style: theme.textTheme.titleMedium), Text('Baseado em fêmeas > 24m', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))])),
                          Text('${_taxaNatalidade.toStringAsFixed(1)}%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.pink)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Últimos Eventos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...eventosOrd.take(50).map((e) {
                      final animal = _animais.firstWhere((a) => a.id == e.animalId, orElse: () => Animal(id: '', brinco: '?', raca: '?', sexo: '?', categoria: '?', dataNascimento: DateTime.now(), pesoAtualKg: 0, fazendaId: '', loteId: ''));
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
                                Text(DateFormat('dd/MM/yyyy').format(e.data), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(e.tipo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.pink)),
                                if (e.resultado != null) Text(e.resultado!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
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
