import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CardDadosInsuficientes extends StatelessWidget {
  final String mensagem;
  final String? botaoTexto;
  final VoidCallback? onBotao;

  const CardDadosInsuficientes({
    super.key,
    required this.mensagem,
    this.botaoTexto,
    this.onBotao,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            mensagem,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (botaoTexto != null && onBotao != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onBotao,
              icon: const Icon(Icons.add),
              label: Text(botaoTexto!),
            ),
          ],
        ],
      ),
    ).animate().fadeIn();
  }
}

class WidgetDadosIndisponivel extends StatelessWidget {
  final String titulo;
  final String dadosNecessarios;
  final String acaoNecesaria;

  const WidgetDadosIndisponivel({
    super.key,
    required this.titulo,
    required this.dadosNecessarios,
    required this.acaoNecesaria,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
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
            Icons.bar_chart,
            size: 40,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dados necessários: $dadosNecessarios',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ação: $acaoNecesaria',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
