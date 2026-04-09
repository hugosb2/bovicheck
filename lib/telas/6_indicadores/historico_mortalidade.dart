import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../modelos/animal.dart';
import '../../estilos/tema.dart';
import 'widgets/dados_insuficientes.dart';
import '../8_rebanho/form_animal.dart';

class TelaHistoricoMortalidade extends StatefulWidget {
  const TelaHistoricoMortalidade({super.key});

  @override
  State<TelaHistoricoMortalidade> createState() => _TelaHistoricoMortalidadeState();
}

class _TelaHistoricoMortalidadeState extends State<TelaHistoricoMortalidade> {
  bool _carregando = false;
  List<Animal> _animais = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDados());
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
    final dados = _gerarDadosMortalidade();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Taxa de Mortalidade'),
      body: !_temDadosSuficientes()
          ? SingleChildScrollView(
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
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
                Column(
                  children: dados.map((d) {
                    final cor = d.valor <= 3 ? Colors.green : (d.valor <= 5 ? Colors.orange : Colors.red);
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
                              Text(d.ano, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('${d.obitos} óbitos de ${d.total}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                            ],
                          ),
                          Text(
                            '${d.valor.toStringAsFixed(1)}%',
                            style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
