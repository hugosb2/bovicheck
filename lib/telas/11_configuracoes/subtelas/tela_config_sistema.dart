import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Não é mais necessário se usar PNG
import '../../../estilos/icones.dart';
import '../../../servicos/banco_dados_servico.dart';
import '../../2_configuracao_inicial/tela_decisao.dart';

class TelaConfigSistema extends StatefulWidget {
  const TelaConfigSistema({super.key});

  @override
  State<TelaConfigSistema> createState() => _TelaConfigSistemaState();
}

class _TelaConfigSistemaState extends State<TelaConfigSistema> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      bool deveColapsar = _scrollController.offset > 80;
      if (deveColapsar != _isCollapsed) {
        setState(() => _isCollapsed = deveColapsar);
      }
    }
  }

  Future<void> _abrirLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmarResetGeral(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetar Aplicativo?'),
        content: const Text(
          'Isso apagará TODAS as fazendas, animais e históricos deste dispositivo permanentemente.\n\nEssa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('SIM, APAGAR TUDO'),
          ),
        ],
      ),
    );

    if (confirmou == true && context.mounted) {
      await BancoDadosServico.instancia.limparTudo();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TelaDecisao()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color corAppBarBg =
        _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final Color corElementos =
        _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final EdgeInsets paddingTitulo = _isCollapsed
        ? const EdgeInsets.only(left: 72, bottom: 16)
        : const EdgeInsets.only(left: 16, bottom: 16);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: corAppBarBg,
            foregroundColor: corElementos,
            iconTheme: IconThemeData(color: corElementos),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: paddingTitulo,
              expandedTitleScale: 1.6,
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: corElementos,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                ),
                child: const Text('Sistema'),
              ),
              background: Container(
                color: theme.colorScheme.surface,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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
                        // CORREÇÃO: Usando Image.asset com a constante correta (PNG)
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
                      // CORREÇÃO: Adicionado 'const' onde solicitado pelo linter
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

                const SizedBox(height: 40),

                const Text('Zona de Perigo',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 8),

                Card(
                  elevation: 0,
                  color:
                      theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: theme.colorScheme.error.withValues(alpha: 0.5)),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.delete_forever,
                        color: theme.colorScheme.error),
                    title: const Text('Resetar Fábrica'),
                    subtitle: const Text('Apagar todos os dados do app'),
                    onTap: () => _confirmarResetGeral(context),
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),
                const Center(
                    child: Text(
                        '© 2026 BoviCheck. Todos os direitos reservados.',
                        style: TextStyle(fontSize: 12, color: Colors.grey))),

                SizedBox(height: MediaQuery.of(context).size.height * 0.4),
              ]),
            ),
          ),
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
