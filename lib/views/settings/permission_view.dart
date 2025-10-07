import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionView extends StatelessWidget {
  const PermissionView({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    final status = await Permission.storage.request();

    if (!context.mounted) return;

    if (status.isGranted) {
      // Se a permissão for concedida, substitui a tela atual pela de backup
      Navigator.pushReplacementNamed(context, '/settings/backup');
    } else if (status.isPermanentlyDenied) {
      // Se for negada permanentemente, mostra um diálogo para abrir as configurações
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Permissão Negada'),
          content: const Text(
            'A permissão de armazenamento foi negada permanentemente. '
            'Você precisa ativá-la manualmente nas configurações do aplicativo para usar esta função.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FilledButton(
              child: const Text('Abrir Configurações'),
              onPressed: () {
                openAppSettings();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      );
    } else {
      // Se for apenas negada, informa o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissão negada. A função de backup não pode ser utilizada.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissão Necessária'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Acesso ao Armazenamento',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Para salvar e restaurar seus backups, o BoviCheck precisa de permissão para acessar o armazenamento do seu dispositivo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Conceder Permissão'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => _requestPermission(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}