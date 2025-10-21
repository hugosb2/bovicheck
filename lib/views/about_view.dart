import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  String _version = '...';
  String _buildNumber = '...';
  String _buildSignature = '...';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    final formattedDate = DateFormat('yyyyMMdd').format(DateTime.now());

    if (mounted) {
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
        _buildSignature = 'v${info.version}_$formattedDate';
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o BoviCheck'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                Image.asset('assets/icon.png', width: 80, height: 80),
                const SizedBox(height: 16),
                const Text('BoviCheck',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildInfoCard(
            context,
            icon: Icons.info_outline,
            title: 'Versão',
            subtitle: '$_version ($_buildNumber)',
          ),
          _buildInfoCard(
            context,
            icon: Icons.fingerprint,
            title: 'Assinatura da Build',
            subtitle: _buildSignature,
          ),
          _buildInfoCard(
            context,
            icon: Icons.person_outline,
            title: 'Desenvolvedor',
            subtitle: 'Hugo Barros',
          ),
          _buildInfoCard(
            context,
            icon: Icons.code_outlined,
            title: 'GitHub',
            subtitle: 'Perfil do desenvolvedor',
            isButton: true,
            onTap: () => _launchURL('https://github.com/hugosb2'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isButton = false,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isButton ? const Icon(Icons.open_in_new) : null,
        onTap: onTap,
      ),
    );
  }
}
