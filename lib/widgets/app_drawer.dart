import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/user_activity_service.dart';
import './app_version_footer.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon.png', width: 64, height: 64),
                const SizedBox(height: 8),
                Text(
                  'BoviCheck',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              UserActivityService.instance.logAction('navigate:Dashboard');
              Navigator.pop(context);
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.fence_outlined), // ÍCONE ALTERADO
            title: const Text('Meu Rebanho'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/animals');
            },
          ),
          ListTile(
            leading: const Icon(Icons.landscape_outlined), // ÍCONE ALTERADO
            title: const Text('Propriedades'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings/propriedades');
            },
          ),
          ListTile(
            leading: const Icon(Icons.grid_view_outlined),
            title: const Text('Lotes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/lotes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Indicadores do Rebanho'),
            onTap: () {
              UserActivityService.instance.logAction('navigate:HerdIndicators');
              Navigator.pop(context);
              Navigator.pushNamed(context, '/herd-indicators');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            onTap: () {
              UserActivityService.instance.logAction('navigate:Settings');
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app_outlined),
            title: const Text('Sair'),
            onTap: () => SystemNavigator.pop(),
          ),
          const AppVersionFooter(),
        ],
      ),
    );
  }
}
