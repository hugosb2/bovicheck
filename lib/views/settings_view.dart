import 'package:bovicheck/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/app_drawer.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
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
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSettingsSection(
            context,
            title: 'Aparência',
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.palette_outlined,
                title: 'Tema',
                subtitle: 'Defina o modo claro, escuro ou do sistema.',
                onTap: () => Navigator.pushNamed(context, '/settings/theme'),
                index: 0,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.color_lens_outlined,
                title: 'Cores',
                subtitle: 'Ajuste as cores dinâmicas e a paleta do app.',
                onTap: () => Navigator.pushNamed(context, '/settings/colors'),
                index: 1,
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            title: 'Dados',
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.storage_outlined,
                title: 'Gerenciar Dados',
                subtitle: 'Gerencie os dados salvos e backups.',
                onTap: () => Navigator.pushNamed(context, '/settings/data'),
                index: 2,
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            title: 'Geral',
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.settings_backup_restore_outlined,
                title: 'Redefinir Preferências',
                subtitle: 'Restaura as configurações para o padrão.',
                onTap: () => _showResetPreferencesConfirmationDialog(context),
                index: 3,
                isDestructive: true,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'Sobre o BoviCheck',
                subtitle: 'Informações sobre o aplicativo.',
                onTap: () => Navigator.pushNamed(context, '/about'),
                index: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int index,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;
    final iconColor = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
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
                          color: color,
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

  Future<void> _showResetPreferencesConfirmationDialog(
      BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Redefinir Preferências?'),
          content: const Text(
              'Tem certeza que deseja restaurar as configurações de aparência do aplicativo para o padrão?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FilledButton(
              child: const Text('Redefinir'),
              onPressed: () async {
                await Provider.of<ThemeProvider>(dialogContext, listen: false)
                    .resetToDefaults();

                if (dialogContext.mounted) Navigator.of(dialogContext).pop();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preferências redefinidas com sucesso.'),
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
}
