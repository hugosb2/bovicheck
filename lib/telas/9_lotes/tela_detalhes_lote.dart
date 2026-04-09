import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../estilos/tema.dart';
import '../../modelos/lote.dart';
import '../../provedores/provedor_fazenda.dart';
import 'form_lote.dart';

class TelaDetalhesLote extends StatefulWidget {
  final Lote lote;

  const TelaDetalhesLote({super.key, required this.lote});

  @override
  State<TelaDetalhesLote> createState() => _TelaDetalhesLoteState();
}

class _TelaDetalhesLoteState extends State<TelaDetalhesLote> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final loteAtual = provedor.lotes.firstWhere(
      (l) => l.id == widget.lote.id,
      orElse: () => widget.lote,
    );
    final animaisDoLote = provedor.animais.where((a) => a.loteId == loteAtual.id).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(
        titulo: 'Detalhes do Lote',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconesApp.lote,
                    size: 40,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  loteAtual.nome,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    loteAtual.tipo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (loteAtual.descricao.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    loteAtual.descricao,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ).animate().fadeIn().scale(),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _cartaoEstatistica(
                  theme: theme,
                  titulo: 'Total',
                  valor: '${animaisDoLote.length}',
                  icone: IconesApp.animal,
                  cor: theme.colorScheme.primary,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _cartaoEstatistica(
                  theme: theme,
                  titulo: 'Machos',
                  valor: '${animaisDoLote.where((a) => a.sexo == 'M').length}',
                  icone: Icons.male,
                  cor: Colors.blue,
                ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1, end: 0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _cartaoEstatistica(
                  theme: theme,
                  titulo: 'Fêmeas',
                  valor: '${animaisDoLote.where((a) => a.sexo == 'F').length}',
                  icone: Icons.female,
                  cor: Colors.pink,
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'ANIMAIS NO LOTE',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 12),

          if (animaisDoLote.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.pets_outlined,
                    size: 56,
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum animal neste lote',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione animais a este lote para vê-los aqui',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms)
          else
            ...animaisDoLote.asMap().entries.map((entry) {
              final index = entry.key;
              final animal = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _itemAnimal(theme, animal.brinco, animal.nome ?? '', animal.sexo, animal.raca)
                    .animate().fadeIn(delay: (300 + index * 50).ms).slideX(begin: 0.1, end: 0),
              );
            }),

          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FormLote(loteExistente: loteAtual)),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('EDITAR'),
      ),
    );
  }

  Widget _cartaoEstatistica({
    required ThemeData theme,
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
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
      child: Column(
        children: [
          Icon(icone, color: cor, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            titulo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemAnimal(ThemeData theme, String brinco, String nome, String sexo, String raca) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
            child: Icon(
              IconesApp.animal,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brinco,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (nome.isNotEmpty)
                  Text(
                    nome,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  raca,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (sexo == 'M' ? Colors.blue : Colors.pink).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  sexo == 'M' ? Icons.male : Icons.female,
                  size: 16,
                  color: sexo == 'M' ? Colors.blue : Colors.pink,
                ),
                const SizedBox(width: 4),
                Text(
                  sexo == 'M' ? 'M' : 'F',
                  style: TextStyle(
                    color: sexo == 'M' ? Colors.blue : Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
