import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../estilos/icones.dart';
import '../../../estilos/tema.dart';
class TelaConfigSistema extends StatefulWidget {
  const TelaConfigSistema({super.key});

  @override
  State<TelaConfigSistema> createState() => _TelaConfigSistemaState();
}

class _TelaConfigSistemaState extends State<TelaConfigSistema> {
  Future<void> _abrirLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Sistema'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // LOGO APP (PNG)
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    IconesApp.logoApp,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'BoviCheck',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Gestão Pecuária Simples',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(),

          const SizedBox(height: 40),

          const Text('Informações Técnicas',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const _InfoTile(
                    icon: Icons.info_outline,
                    label: 'Versão',
                    value: '1.0.7'),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const _InfoTile(
                    icon: Icons.build_circle_outlined,
                    label: 'Build',
                    value: 'v1.0.7_20260203'),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const _InfoTile(
                    icon: Icons.person_outline,
                    label: 'Desenvolvedor',
                    value: 'Hugo Barros'),
                const Divider(height: 1, indent: 16, endIndent: 16),

                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Suporte'),
                  subtitle: const Text('hugobs4987@gmail.com'),
                  onTap: () => _abrirLink('mailto:hugobs4987@gmail.com'),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),
          const Center(
              child: Text(
                  '© 2026 BoviCheck. Todos os direitos reservados.',
                  style: TextStyle(fontSize: 12, color: Colors.grey))),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
