import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../modelos/animal.dart';
import '../../provedores/provedor_fazenda.dart';
import 'form_animal.dart';

class TelaDetalhesAnimal extends StatefulWidget {
  final Animal animal;

  const TelaDetalhesAnimal({super.key, required this.animal});

  @override
  State<TelaDetalhesAnimal> createState() => _TelaDetalhesAnimalState();
}

class _TelaDetalhesAnimalState extends State<TelaDetalhesAnimal> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      bool deveColapsar = _scrollController.offset > 120;
      if (deveColapsar != _isCollapsed) {
        setState(() => _isCollapsed = deveColapsar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final animalAtual = provedor.animais
        .firstWhere((a) => a.id == widget.animal.id, orElse: () => widget.animal);
    final lote = provedor.lotes.firstWhere(
      (l) => l.id == animalAtual.loteId,
      orElse: () => provedor.lotes.first,
    );

    final Color corAppBarBg =
        _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final Color corElementos =
        _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final EdgeInsets paddingTitulo = _isCollapsed
        ? const EdgeInsets.only(left: 72, bottom: 16)
        : const EdgeInsets.only(left: 16, bottom: 16);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: corAppBarBg,
            foregroundColor: corElementos,
            iconTheme: IconThemeData(color: corElementos),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: paddingTitulo,
              expandedTitleScale: 1.6,
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: corElementos,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                child: Text('Brinco ${animalAtual.brinco}'),
              ),
              background: Container(
                color: theme.colorScheme.surface,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          IconesApp.iconAnimalSvg,
                          width: 40,
                          height: 40,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (animalAtual.nome != null && animalAtual.nome!.isNotEmpty)
                            Text(
                              animalAtual.nome!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _badge(
                                animalAtual.sexo == 'M' ? 'Macho' : 'Fêmea',
                                animalAtual.sexo == 'M' ? Colors.blue : Colors.pink,
                                theme,
                              ),
                              const SizedBox(width: 8),
                              _badge(animalAtual.categoria, theme.colorScheme.secondary, theme),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!animalAtual.isAtivo)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Este animal está inativo/morto.',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                _cartaoInfo(
                  theme: theme,
                  icon: Icons.fence_outlined,
                  titulo: 'Lote',
                  valor: lote.nome,
                  subtitulo: lote.tipo,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _cartaoInfo(
                        theme: theme,
                        icon: Icons.pets,
                        titulo: 'Raça',
                        valor: animalAtual.raca,
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _cartaoInfo(
                        theme: theme,
                        icon: Icons.cake_outlined,
                        titulo: 'Idade',
                        valor: '${animalAtual.calcularIdadeMeses()} meses',
                      ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.1, end: 0),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'PESO',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconesApp.peso,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Text(
                            '${animalAtual.pesoAtualKg}',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'kg',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

                const SizedBox(height: 24),

                Text(
                  'DATAS',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 12),

                _cartaoInfo(
                  theme: theme,
                  icon: Icons.calendar_today,
                  titulo: 'Data de Nascimento',
                  valor: DateFormat('dd/MM/yyyy').format(animalAtual.dataNascimento),
                ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: 12),

                _cartaoInfo(
                  theme: theme,
                  icon: Icons.numbers,
                  titulo: 'ID do Animal',
                  valor: animalAtual.id,
                  pequeno: true,
                ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormAnimal(animalExistente: animalAtual),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('EDITAR'),
      ),
    );
  }

  Widget _badge(String texto, Color cor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withValues(alpha: 0.5)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _cartaoInfo({
    required ThemeData theme,
    required IconData icon,
    required String titulo,
    required String valor,
    String? subtitulo,
    bool pequeno = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: pequeno
                      ? theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        )
                      : theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                ),
                if (subtitulo != null)
                  Text(
                    subtitulo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
