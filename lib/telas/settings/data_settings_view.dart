import 'package:bovicheck/servicos/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controladores/dashboard_controller.dart';

// Removed unused imports related to JSON export

class TelaConfiguracaoDados extends StatefulWidget {
  const TelaConfiguracaoDados({super.key});

  @override
  State<TelaConfiguracaoDados> createState() => _TelaConfiguracaoDadosState();
}

class _TelaConfiguracaoDadosState extends State<TelaConfiguracaoDados> {
  // JSON export removed per request.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Variável de tema adicionada

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados do Aplicativo'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDataOption(
            context,
            icon: Icons.security_update_good_outlined,
            title: 'Backup e Restauração',
            subtitle: 'Crie ou restaure um backup local dos seus dados.',
            onTap: () => Navigator.pushNamed(context, '/settings/backup'),
            index: 0,
          ),
          const SizedBox(height: 12),
          _buildDataOption(
            context,
            icon: Icons.description_outlined,
            title: 'Exportar Dados para Planilha',
            subtitle: 'Escolha quais dados exportar em um arquivo .xlsx.',
            onTap: () =>
                Navigator.pushNamed(context, '/settings/spreadsheet-export'),
            index: 1,
          ),
          const SizedBox(height: 12),
          _buildDataOption(
            context,
            icon: Icons.picture_as_pdf_outlined,
            title: 'Exportar Relatório em PDF',
            subtitle: 'Escolha quais dados exportar em um arquivo PDF.',
            onTap: () => Navigator.pushNamed(context, '/settings/pdf-export'),
            index: 2,
          ),
          const SizedBox(height: 24),
          _buildDataOption(
            context,
            icon: Icons.delete_forever_outlined,
            title: 'Apagar Todos os Dados',
            subtitle:
                'Inclui animais, lotes e configurações. Esta ação não pode ser desfeita.',
            onTap: () => _showClearDataConfirmationDialog(context),
            isDestructive: true,
            index: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Opções de Desenvolvedor',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _showClearDataConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão Total'),
          content: const Text(
              'Você tem certeza que deseja apagar permanentemente TODOS os dados do aplicativo?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
              child: const Text('Apagar Tudo'),
              onPressed: () async {
                await DatabaseService.instance.clearAllData();
                if (dialogContext.mounted) {
                  Provider.of<DashboardController>(dialogContext, listen: false)
                      .fetchDashboardData();
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos os dados foram apagados.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required int index,
    bool isLoading = false,
    bool isDestructive = false,
    bool isSecondary = false,
  }) {
    final theme = Theme.of(context);
    final iconColor = isDestructive
        ? theme.colorScheme.error
        : (isSecondary
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.primary);

    return Card(
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: iconColor,
                          ),
                        )
                      : Icon(
                          icon,
                          color: iconColor,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSecondary
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideX(begin: 0.1, end: 0);
  }
}

class DataSettingsView extends TelaConfiguracaoDados {
  const DataSettingsView({super.key}) : super();
}
