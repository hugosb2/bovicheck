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
  late ScrollController _scrollController;

  // Estado para controlar a aparência
  bool _isCollapsed = false;
  String _filtroTexto = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _buscaController.addListener(() {
      setState(() {
        _filtroTexto = _buscaController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // CORREÇÃO CRÍTICA: Ajuste do ponto de gatilho.
    // ExpandedHeight é 140. kToolbarHeight é 56.
    // Se o usuário rolar mais que 90px, mudamos o estado.
    if (_scrollController.hasClients) {
      bool deveColapsar = _scrollController.offset > 90;
      if (deveColapsar != _isCollapsed) {
        setState(() {
          _isCollapsed = deveColapsar;
        });
      }
    }
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

    // LÓGICA DE CORES
    // Colapsado (Pequeno): Fundo Verde, Ícones Brancos
    // Expandido (Grande): Fundo Branco, Ícones Verdes
    final Color corAppBarBg =
        _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final Color corElementos =
        _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;

    // LÓGICA DE PADDING (Correção de Sobreposição)
    // Quando colapsado, empurra 72px para a direita para fugir da seta
    final EdgeInsets paddingTitulo = _isCollapsed
        ? const EdgeInsets.only(left: 72, bottom: 16)
        : const EdgeInsets.only(left: 16, bottom: 16);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        // CORREÇÃO: Força o scroll funcionar mesmo com poucos itens para a animação rodar
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,

            // Cores
            backgroundColor: corAppBarBg,
            foregroundColor:
                corElementos, // Controla a cor da seta automaticamente
            iconTheme: IconThemeData(color: corElementos),

            surfaceTintColor:
                Colors.transparent, // Evita mistura de cores do Material 3

            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false, // Força alinhamento a esquerda
              titlePadding: paddingTitulo, // Aplica o padding dinâmico
              expandedTitleScale: 1.6,

              title: AnimatedDefaultTextStyle(
                // Animação suave na troca de cor do texto
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: corElementos,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Roboto', // Garante a fonte correta
                ),
                child: const Text('Rebanho'),
              ),

              background: Container(
                color: theme.colorScheme.surface,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Busca Fixa
          SliverToBoxAdapter(
            child: Padding(
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
          ),

          if (animaisFiltrados.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(IconesApp.rebanho,
                        size: 64,
                        color:
                            theme.colorScheme.outline.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      _filtroTexto.isEmpty
                          ? 'Nenhum animal cadastrado.'
                          : 'Nenhum animal encontrado.',
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
                        trailing: Icon(IconesApp.setaDireita,
                            color: theme.colorScheme.outline),
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
                  childCount: animaisFiltrados.length,
                ),
              ),
            ),

          // Espaço extra no final para garantir que o último item não fique escondido pelo FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
