import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../modelos/lote.dart';
import '../../provedores/provedor_fazenda.dart';
import 'tela_detalhes_animal.dart';
import 'form_animal.dart';
import '../9_lotes/form_lote.dart';

class TelaListaAnimais extends StatefulWidget {
  const TelaListaAnimais({super.key});

  @override
  State<TelaListaAnimais> createState() => _TelaListaAnimaisState();
}

class _TelaListaAnimaisState extends State<TelaListaAnimais> {
  final TextEditingController _buscaController = TextEditingController();
  String _filtroTexto = '';

  @override
  void initState() {
    super.initState();

    _buscaController.addListener(() {
      setState(() {
        _filtroTexto = _buscaController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _navegarParaNovoAnimal(BuildContext context) {
    final provedor = context.read<ProvedorFazenda>();
    if (provedor.lotes.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Atenção'),
          content: const Text(
            'Você precisa criar pelo menos um Lote (pasto ou curral) antes de cadastrar animais.\n\nDeseja criar um lote agora?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FormLote()));
              },
              child: const Text('CRIAR LOTE'),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const FormAnimal()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();

    final animaisFiltrados = provedor.animais.where((animal) {
      final matchBrinco = animal.brinco.toLowerCase().contains(_filtroTexto);
      final matchNome =
          animal.nome?.toLowerCase().contains(_filtroTexto) ?? false;
      return matchBrinco || matchNome;
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Rebanho',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Busca Fixa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar por brinco ou nome...',
                prefixIcon: const Icon(IconesApp.buscar),
                suffixIcon: _filtroTexto.isNotEmpty
                    ? IconButton(
                        icon: const Icon(IconesApp.fechar),
                        onPressed: () => _buscaController.clear())
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),

          Expanded(
            child: animaisFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(IconesApp.rebanho,
                            size: 64,
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          _filtroTexto.isEmpty
                              ? 'Nenhum animal cadastrado.'
                              : 'Nenhum animal encontrado.',
                          style: TextStyle(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: animaisFiltrados.length,
                    itemBuilder: (context, index) {
                      final animal = animaisFiltrados[index];
                      final loteObj = provedor.lotes.cast<Lote?>().firstWhere(
                          (l) => l?.id == animal.loteId,
                          orElse: () => null);
                      final nomeLote = loteObj?.nome ?? 'Lote não encontrado';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.4)),
                        ),
                        color: theme.colorScheme.surfaceContainerLow,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: animal.sexo == 'M'
                                ? Colors.blue.shade100
                                : Colors.pink.shade100,
                            child: Text(
                              animal.brinco.length > 3
                                  ? animal.brinco.substring(0, 3)
                                  : animal.brinco,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: animal.sexo == 'M'
                                    ? Colors.blue.shade800
                                    : Colors.pink.shade800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text("Brinco ${animal.brinco}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              "${animal.nome ?? 'Sem nome'} • $nomeLote\n${animal.calcularIdadeMeses()} meses",
                              style: theme.textTheme.bodySmall),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        TelaDetalhesAnimal(animal: animal)));
                          },
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (index * 30).ms)
                          .slideX();
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navegarParaNovoAnimal(context),
        icon: const Icon(IconesApp.adicionar),
        label: const Text('NOVO ANIMAL'),
      ),
    );
  }
}
