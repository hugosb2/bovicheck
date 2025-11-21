import 'package:bovicheck/services/ai_evaluation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

    final markdownStyle = MarkdownStyleSheet(
      p: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        height: 1.6,
      ),
      strong: const TextStyle(fontWeight: FontWeight.bold),
    );

    return Card(
      elevation: 2,
      shadowColor: iconColor.withOpacity(0.2),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: iconColor.withAlpha(180), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor,
              cardColor.withOpacity(0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Análise de IA',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MarkdownBody(
              data: analysis.summary,
              styleSheet: markdownStyle,
              selectable: true,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Powered by Gemini',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}
