import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../estilos/icones.dart';
import '../../../provedores/provedor_fazenda.dart';
import '../tela_dashboard.dart';
import '../../6_indicadores/tela_indicadores.dart';
import '../../8_rebanho/tela_lista_animais.dart';
import '../../9_lotes/tela_lista_lotes.dart';
import '../../5_ia_consultor/tela_ia_consultor.dart';
import '../../11_configuracoes/tela_configuracoes.dart';
import '../../2_configuracao_inicial/tela_selecionar_fazenda.dart';

class GavetaMenu extends StatelessWidget {
  const GavetaMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final fazenda = provedor.propriedadeAtiva;

    final String inicial = (fazenda?.nomeFazenda.isNotEmpty ?? false)
        ? fazenda!.nomeFazenda[0].toUpperCase()
        : 'B';

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. Header Modernizado
          _HeaderGaveta(
            theme: theme,
            inicial: inicial,
            fazenda: fazenda,
            onGerenciar: () => _trocarFazenda(context),
          ),

          // 2. Lista de Navegação
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _LabelSecao(titulo: "Principal"),
                _ItemMenuModerno(
                  icon: IconesApp.dashboard,
                  titulo: 'Dashboard',
                  cor: theme.colorScheme.primary,
                  onTap: () => _navegar(context, const TelaDashboard()),
                  delay: 100,
                ),
                _ItemMenuModerno(
                  svgPath: IconesApp.iconAnimalSvg,
                  titulo: 'Meu Rebanho',
                  cor: Colors.blue.shade700,
                  onTap: () => _navegar(context, const TelaListaAnimais()),
                  delay: 150,
                ),
                _ItemMenuModerno(
                  icon: IconesApp.lote,
                  titulo: 'Lotes e Pastos',
                  cor: Colors.orange.shade800,
                  onTap: () => _navegar(context, const TelaListaLotes()),
                  delay: 200,
                ),

                const SizedBox(height: 24),
                _LabelSecao(titulo: "Análise e Inteligência"),
                _ItemMenuModerno(
                  icon: IconesApp.indicadores,
                  titulo: 'Indicadores GMD',
                  cor: Colors.teal.shade700,
                  onTap: () => _navegar(context, const TelaIndicadores()),
                  delay: 250,
                ),
                _ItemMenuModerno(
                  icon: IconesApp.iaConsultor,
                  titulo: 'Consultor IA',
                  cor: Colors.purple.shade700,
                  onTap: () => _navegar(context, const TelaIAConsultor()),
                  delay: 300,
                ),

                const SizedBox(height: 24),
                _LabelSecao(titulo: "Sistema"),
                _ItemMenuModerno(
                  icon: IconesApp.configuracoes,
                  titulo: 'Configurações',
                  cor: theme.colorScheme.onSurfaceVariant,
                  onTap: () => _navegar(context, const TelaConfiguracoes()),
                  delay: 350,
                ),
                _ItemMenuModerno(
                  icon: Icons.logout_rounded,
                  titulo: 'Sair / Trocar',
                  cor: theme.colorScheme.error,
                  onTap: () => _trocarFazenda(context),
                  delay: 400,
                ),
              ],
            ),
          ),

          // 3. Footer Discreto
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "PRO",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BoviCheck v1.1.0',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navegar(BuildContext context, Widget tela) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
  }

  void _trocarFazenda(BuildContext context) async {
    final provedor = context.read<ProvedorFazenda>();
    provedor.limparEstado();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TelaSelecionarFazenda()));
  }
}

// --- SUB-WIDGETS REFORMULADOS ---

class _HeaderGaveta extends StatelessWidget {
  final ThemeData theme;
  final String inicial;
  final dynamic fazenda;
  final VoidCallback onGerenciar;

  const _HeaderGaveta({
    required this.theme,
    required this.inicial,
    required this.fazenda,
    required this.onGerenciar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(32)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    inicial,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ).animate().scale(curve: Curves.elasticOut),
              IconButton(
                onPressed: onGerenciar,
                icon: const Icon(Icons.settings_input_component_outlined, color: Colors.white70, size: 20),
                tooltip: "Gerenciar Fazendas",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            fazenda?.nomeFazenda ?? 'Sem Fazenda',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            fazenda != null ? '${fazenda.cidade}, ${fazenda.estado}' : 'Configure sua conta',
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _LabelSecao extends StatelessWidget {
  final String titulo;
  const _LabelSecao({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        titulo.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ItemMenuModerno extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final String titulo;
  final Color cor;
  final VoidCallback onTap;
  final int delay;

  const _ItemMenuModerno({
    this.icon,
    this.svgPath,
    required this.titulo,
    required this.cor,
    required this.onTap,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: svgPath != null
                ? SvgPicture.asset(svgPath!, width: 20, height: 20, colorFilter: ColorFilter.mode(cor, BlendMode.srcIn))
                : Icon(icon, color: cor, size: 20),
          ),
        ),
        title: Text(
          titulo,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, size: 18, color: theme.colorScheme.outline.withValues(alpha: 0.4)),
      ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.05, end: 0),
    );
  }
}
