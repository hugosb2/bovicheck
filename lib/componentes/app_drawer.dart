import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../servicos/user_activity_service.dart';

import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RodapeVersaoApp extends StatefulWidget {
  const RodapeVersaoApp({super.key});

  @override
  State<RodapeVersaoApp> createState() => _RodapeVersaoAppState();
}

class _RodapeVersaoAppState extends State<RodapeVersaoApp> {
  String _buildSignature = '';

  @override
  void initState() {
    super.initState();
    _initBuildSignature();
  }

  Future<void> _initBuildSignature() async {
    final info = await PackageInfo.fromPlatform();
    final formattedDate = DateFormat('yyyyMMdd').format(DateTime.now());

    if (mounted) {
      setState(() {
        _buildSignature = 'v${info.version}_$formattedDate';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildSignature.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              _buildSignature,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          );
  }
}

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
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
              child: DrawerHeader(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                theme.colorScheme.shadow.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                          Image.asset('assets/icon.png', width: 48, height: 48),
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'BoviCheck',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Gestão Pecuária',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
              onTap: () {
                UserActivityService.instance.logAction('navigate:Dashboard');
                Navigator.pop(context);
                if (ModalRoute.of(context)?.settings.name != '/') {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              index: 0,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.tag_outlined,
              title: 'Meu Rebanho',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/animals');
              },
              index: 1,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.cottage_outlined,
              title: 'Propriedades',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings/propriedades');
              },
              index: 2,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.grid_view_outlined,
              title: 'Lotes',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/lotes');
              },
              index: 3,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.analytics_outlined,
              title: 'Indicadores do Rebanho',
              onTap: () {
                UserActivityService.instance
                    .logAction('navigate:HerdIndicators');
                Navigator.pop(context);
                Navigator.pushNamed(context, '/herd-indicators');
              },
              index: 4,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Configurações',
              onTap: () {
                UserActivityService.instance.logAction('navigate:Settings');
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
              index: 5,
            ),
            const Divider(height: 32),
            _buildDrawerItem(
              context,
              icon: Icons.exit_to_app_outlined,
              title: 'Sair',
              onTap: () => SystemNavigator.pop(),
              index: 6,
              isDestructive: true,
            ),
            const RodapeVersaoApp(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int index,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    final iconColor =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms, delay: (index * 30).ms)
        .slideX(begin: -0.1, end: 0);
  }
}

class AppDrawer extends MenuLateral {
  const AppDrawer({super.key}) : super();
}
