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
import '../../2_configuracao_inicial/tela_decisao.dart';

class GavetaMenu extends StatelessWidget {
  const GavetaMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final fazenda = provedor.propriedadeAtiva;

    final String inicial = (fazenda?.nomeFazenda.isNotEmpty ?? false)
        ? fazenda!.nomeFazenda[0].toUpperCase()
        : 'F';

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      inicial,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 16),
                Text(
                  fazenda?.nomeFazenda ?? 'Fazenda não selecionada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  fazenda != null
                      ? '${fazenda.cidade} - ${fazenda.estado}'
                      : 'Toque para configurar',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _ItemMenu(
                  iconeWidget: Icon(IconesApp.dashboard,
                      color: theme.colorScheme.primary),
                  titulo: 'Dashboard',
                  onTap: () => _navegar(context, const TelaDashboard()),
                  delay: 0,
                ),
                _ItemMenu(
                  iconeWidget: SvgPicture.asset(
                    IconesApp.iconAnimalSvg,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary, BlendMode.srcIn),
                  ),
                  titulo: 'Rebanho',
                  onTap: () => _navegar(context, const TelaListaAnimais()),
                  delay: 50,
                ),
                _ItemMenu(
                  iconeWidget: Icon(IconesApp.lote,
                      color: theme.colorScheme.primary),
                  titulo: 'Lotes e Pastos',
                  onTap: () => _navegar(context, const TelaListaLotes()),
                  delay: 100,
                ),
                _ItemMenu(
                  iconeWidget: Icon(IconesApp.indicadores,
                      color: theme.colorScheme.primary),
                  titulo: 'Indicadores',
                  onTap: () => _navegar(context, const TelaIndicadores()),
                  delay: 150,
                ),
                _ItemMenu(
                  iconeWidget: Icon(IconesApp.iaConsultor,
                      color: theme.colorScheme.primary),
                  titulo: 'Consultor IA',
                  onTap: () => _navegar(context, const TelaIAConsultor()),
                  delay: 200,
                ),
                const SizedBox(height: 8),
                Divider(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 8),
                _ItemMenu(
                  iconeWidget: Icon(IconesApp.configuracoes,
                      color: theme.colorScheme.onSurfaceVariant),
                  titulo: 'Configurações',
                  onTap: () => _navegar(context, const TelaConfiguracoes()),
                  delay: 250,
                ),
                _ItemMenu(
                  iconeWidget: Icon(Icons.swap_horiz,
                      color: theme.colorScheme.onSurfaceVariant),
                  titulo: 'Trocar Fazenda',
                  onTap: () => _navegar(context, const TelaDecisao()),
                  delay: 300,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: theme.colorScheme.outline),
                const SizedBox(width: 8),
                Text(
                  'BoviCheck v1.0.7',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => tela),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final Widget iconeWidget;
  final String titulo;
  final VoidCallback onTap;
  final int delay;

  const _ItemMenu({
    required this.iconeWidget,
    required this.titulo,
    required this.onTap,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: iconeWidget),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    titulo,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}
