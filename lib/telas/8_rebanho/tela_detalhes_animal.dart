import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../modelos/animal.dart';
import '../../provedores/provedor_fazenda.dart';
import 'form_animal.dart';

class TelaDetalhesAnimal extends StatelessWidget {
  final Animal animal;

  const TelaDetalhesAnimal({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final animalAtual = provedor.animais
        .firstWhere((a) => a.id == animal.id, orElse: () => animal);
    final lote = provedor.lotes.firstWhere((l) => l.id == animalAtual.loteId,
        orElse: () => provedor.lotes.first);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FormAnimal(animalExistente: animalAtual)),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Brinco ${animalAtual.brinco}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                        child: SvgPicture.asset(
                          IconesApp.iconAnimalSvg,
                          width: 50,
                          height: 50,
                          colorFilter: ColorFilter.mode(
                              theme.colorScheme.onPrimary, BlendMode.srcIn),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 12),
                      Text(
                        animalAtual.nome ?? 'Sem Nome',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
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
                            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                
                _secaoTitulo('Informações Gerais', theme),
                const SizedBox(height: 12),
                
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _linhaDetalhe('Brinco', animalAtual.brinco, theme),
                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        _linhaDetalhe('Lote', lote.nome, theme),
                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        _linhaDetalhe('Raça', animalAtual.raca, theme),
                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        _linhaDetalhe('Sexo', animalAtual.sexo == 'M' ? 'Macho' : 'Fêmea', theme),
                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        _linhaDetalhe('Categoria', animalAtual.categoria, theme),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 24),
                _secaoTitulo('Dados de Peso', theme),
                const SizedBox(height: 12),
                
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _linhaDetalhe('Peso Atual', '${animalAtual.pesoAtualKg} kg', theme),
                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        _linhaDetalhe(
                          'Nascimento',
                          DateFormat('dd/MM/yyyy').format(animalAtual.dataNascimento),
                          theme,
                        ),
                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        _linhaDetalhe('Idade', '${animalAtual.idadeMeses} meses', theme),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secaoTitulo(String texto, ThemeData theme) {
    return Text(
      texto.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _linhaDetalhe(String label, String valor, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            valor,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
