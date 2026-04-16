import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../estilos/tema.dart';
import '../../modelos/lote.dart';
import '../../modelos/animal.dart';
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
      setState(() { _filtroTexto = _buscaController.text.toLowerCase(); });
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
      _mostrarAvisoSemLote(context);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FormAnimal()));
    }
  }

  void _mostrarAvisoSemLote(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Lote Necessário'),
        content: const Text('Para cadastrar animais, você precisa de pelo menos um lote ou pasto ativo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('VOLTAR')),
          FilledButton(
            onPressed: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const FormLote())); },
            child: const Text('CRIAR LOTE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();

    final animaisFiltrados = provedor.animais.where((animal) {
      final matchBrinco = animal.brinco.toLowerCase().contains(_filtroTexto);
      final matchNome = animal.nome?.toLowerCase().contains(_filtroTexto) ?? false;
      return matchBrinco || matchNome;
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Meu Rebanho', centralizar: true),
      body: Column(
        children: [
          // 1. Barra de Busca Moderna
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar brinco ou nome...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),

          // 2. Lista de Animais
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => await provedor.carregarAnimais(provedor.propriedadeAtiva!.id),
              child: animaisFiltrados.isEmpty
                  ? _EstadoVazioBusca(filtro: _filtroTexto, theme: theme)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: animaisFiltrados.length,
                      itemBuilder: (context, index) {
                        final animal = animaisFiltrados[index];
                        final lote = provedor.lotes.cast<Lote?>().firstWhere((l) => l?.id == animal.loteId, orElse: () => null);
                        return _CardAnimalModerno(animal: animal, loteNome: lote?.nome ?? 'Sem lote', index: index);
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: BotaoFlutuanteBovi(
        onPressed: () => _navegarParaNovoAnimal(context),
        icone: Icons.add_rounded,
        label: 'NOVO ANIMAL',
      ),
    );
  }
}

class _CardAnimalModerno extends StatelessWidget {
  final Animal animal;
  final String loteNome;
  final int index;

  const _CardAnimalModerno({required this.animal, required this.loteNome, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isMacho = animal.sexo == 'M';
    final Color corSexo = isMacho ? Colors.blue.shade600 : Colors.pink.shade600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaDetalhesAnimal(animal: animal))),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              // Avatar com Brinco
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: corSexo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    animal.brinco,
                    style: TextStyle(color: corSexo, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(animal.nome ?? 'Sem Nome', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(width: 6),
                        Icon(isMacho ? Icons.male : Icons.female, size: 14, color: corSexo),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('$loteNome • ${animal.raca}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _BadgeAnimal(label: '${animal.pesoAtualKg.toStringAsFixed(1)} kg', icon: IconesApp.peso, cor: Colors.teal),
                        const SizedBox(width: 8),
                        _BadgeAnimal(label: '${animal.calcularIdadeMeses()} meses', icon: Icons.calendar_today_rounded, cor: Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05, end: 0),
    );
  }
}

class _BadgeAnimal extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color cor;

  const _BadgeAnimal({required this.label, required this.icon, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: cor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(icon, size: 10, color: cor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cor)),
        ],
      ),
    );
  }
}

class _EstadoVazioBusca extends StatelessWidget {
  final String filtro;
  final ThemeData theme;
  const _EstadoVazioBusca({required this.filtro, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            filtro.isEmpty ? 'Nenhum animal cadastrado' : 'Nenhum animal encontrado para "$filtro"',
            style: TextStyle(color: theme.colorScheme.outline, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
