// lib/widgets/ai_analysis_card.dart

import 'package:bovicheck/services/ai_evaluation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // 1. IMPORTE O PACOTE

class AiAnalysisCard extends StatelessWidget {
  final AIAnalysisResult analysis;
  const AiAnalysisCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color cardColor;
    final Color iconColor;
    final IconData icon;

    switch (analysis.status) {
      case AIStatus.good:
        cardColor = Colors.green.shade50;
        iconColor = Colors.green.shade800;
        icon = Icons.check_circle_outline;
        break;
      case AIStatus.average:
        cardColor = Colors.amber.shade50;
        iconColor = Colors.amber.shade800;
        icon = Icons.warning_amber_outlined;
        break;
      case AIStatus.bad:
        cardColor = theme.colorScheme.errorContainer;
        iconColor = theme.colorScheme.error;
        icon = Icons.dangerous_outlined;
        break;
      case AIStatus.neutral:
        cardColor = theme.colorScheme.surfaceContainer;
        iconColor = theme.colorScheme.onSurfaceVariant;
        icon = Icons.info_outline;
        break;
    }

    // 3. ADICIONE O ESTILO para o Markdown aqui
    // Isso garante que o texto normal (p) e o negrito (strong) fiquem com a aparência correta.
    final markdownStyle = MarkdownStyleSheet(
      p: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      strong: const TextStyle(fontWeight: FontWeight.bold),
    );

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: iconColor.withAlpha(128)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Text(
                  'Análise de IA',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 2. SUBSTITUA O WIDGET Text POR MarkdownBody
            MarkdownBody(
              data: analysis.summary,
              styleSheet: markdownStyle,
              selectable:
                  true, // Permite que o usuário copie o texto da análise
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Powered by Gemini',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
