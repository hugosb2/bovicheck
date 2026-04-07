import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../estilos/cores.dart';
import '../../estilos/icones.dart';
import '../../estilos/tema.dart';

class TelaSobre extends StatefulWidget {
  const TelaSobre({super.key});

  @override
  State<TelaSobre> createState() => _TelaSobreState();
}

class _TelaSobreState extends State<TelaSobre> {
  String _versao = '';
  String _buildNumber = '';
  String _appName = 'BoviCheck';

  @override
  void initState() {
    super.initState();
    _carregarInfo();
  }

  Future<void> _carregarInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _versao = info.version;
      _buildNumber = info.buildNumber;
      _appName = info.appName;
    });
  }

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
      appBar: const AppBarPadrao(titulo: 'Sobre'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: AssetImage('assets/icon.png'),
                    fit: BoxFit.scaleDown,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),

              const SizedBox(height: 24),

              Text(
                _appName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 8),

              Text(
                'Versão $_versao (Build $_buildNumber)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 48),

              // Cards de Informação
              _CardCredito(
                icone: Icons.person_outline,
                titulo: 'Desenvolvedor',
                valor: 'BoviCheck Team',
              ),
              _CardCredito(
                icone: Icons.email_outlined,
                titulo: 'Contato',
                valor: 'suporte@bovicheck.com',
                onTap: () => _abrirLink('mailto:suporte@bovicheck.com'),
              ),
              _CardCredito(
                icone: Icons.policy_outlined,
                titulo: 'Política de Privacidade',
                valor: 'Ler documentos',
                onTap: () => _abrirLink('https://bovicheck.com/privacy'),
              ),

              const SizedBox(height: 48),

              Text(
                '© ${DateTime.now().year} BoviCheck. Todos os direitos reservados.',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardCredito extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;
  final VoidCallback? onTap;

  const _CardCredito({
    required this.icone,
    required this.titulo,
    required this.valor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icone, color: Theme.of(context).colorScheme.primary),
        title: Text(titulo, style: const TextStyle(fontSize: 12)),
        subtitle: Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: onTap != null
            ? const Icon(Icons.open_in_new, size: 16)
            : null,
        onTap: onTap,
      ),
    ).animate().slideX(begin: 0.2, end: 0, duration: 400.ms);
  }
}
