import 'package:bovicheck/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema'),
            subtitle: const Text('Defina o modo claro, escuro ou do sistema.'),
            onTap: () {
              Navigator.pushNamed(context, '/settings/theme');
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Cores'),
            subtitle:
                const Text('Ajuste as cores dinâmicas e a paleta do app.'),
            onTap: () {
              Navigator.pushNamed(context, '/settings/colors');
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Dados'),
            subtitle: const Text('Gerencie os dados salvos e backups.'),
            onTap: () {
              Navigator.pushNamed(context, '/settings/data');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore_outlined),
            title: const Text('Redefinir Preferências'),
            subtitle: const Text(
                'Restaura as configurações de tema e cor para o padrão.'),
            onTap: () => _showResetPreferencesConfirmationDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o BoviCheck'),
            subtitle: const Text('Informações sobre o aplicativo.'),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
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
