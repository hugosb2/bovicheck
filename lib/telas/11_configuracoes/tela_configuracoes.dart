import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import 'subtelas/tela_config_aparencia.dart';
import 'subtelas/tela_config_dados.dart';
import 'subtelas/tela_config_sistema.dart';
import 'subtelas/tela_detalhes_fazenda.dart'; // Import da nova tela de detalhes

import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../provedores/provedor_fazenda.dart';
import '../../servicos/banco_dados_servico.dart';

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
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
    if (_scrollController.hasClients &&
        _scrollController.offset > (140 - kToolbarHeight)) {
      if (!_isCollapsed) setState(() => _isCollapsed = true);
    } else {
      if (_isCollapsed) setState(() => _isCollapsed = false);
    }
  }
  Future<void> _exportarFazenda(BuildContext context) async {
    final provedor = context.read<ProvedorFazenda>();
    final fazenda = provedor.propriedadeAtiva;
    if (fazenda == null) return;

    try {
      final jsonStr = await BancoDadosServico.instancia.exportarFazendaJson(fazenda.id);
      final bytes = utf8.encode(jsonStr);
      final dataStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final nomeArquivo = 'BoviCheck_Fazenda_${fazenda.nomeFazenda}_$dataStr.fbvk';

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$nomeArquivo');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        final xFile = XFile(file.path);
        await Share.shareXFiles(
          [xFile],
          text: 'Backup da fazenda ${fazenda.nomeFazenda}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar fazenda: $e'), backgroundColor: Colors.red),
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
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: corAppBarBg,
            iconTheme: IconThemeData(color: corElementos),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: paddingTitulo,
              expandedTitleScale: 1.6,
              title: Text(
                'Configurações',
                style: TextStyle(
                  color: corElementos,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
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
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _cabecalho(theme, 'Geral'),

                // NOVO CARD: Dados da Propriedade
                _CardMenu(
                  titulo: 'Dados da Propriedade',
                  descricao: 'Visualizar e editar dados da fazenda.',
                  icone: IconesApp.fazenda,
                  corIcone: Colors.green,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TelaDetalhesFazenda())),
                  delay: 0,
                ),

                _CardMenu(
                  titulo: 'Aparência & Estilo',
                  descricao: 'Tema claro/escuro e cores personalizadas.',
                  icone: IconesApp.tema,
                  corIcone: Colors.purple,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TelaConfigAparencia())),
                  delay: 50,
                ),

                _CardMenu(
                  titulo: 'Backup da Fazenda',
                  descricao: 'Exportar os dados apenas desta propriedade.',
                  icone: Icons.save_alt,
                  corIcone: Colors.blue,
                  onTap: () => _exportarFazenda(context),
                  delay: 100,
                ),
                _cabecalho(theme, 'Aplicativo'),

                _CardMenu(
                  titulo: 'Sistema & Sobre',
                  descricao: 'Versão, desenvolvedor e reset de fábrica.',
                  icone: IconesApp.sobre,
                  corIcone: Colors.orange,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TelaConfigSistema())),
                  delay: 200,
                ),

                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho(ThemeData theme, String texto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Text(
        texto.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CardMenu extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final Color corIcone;
  final VoidCallback onTap;
  final int delay;

  const _CardMenu({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.corIcone,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: corIcone.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icone, color: corIcone, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}
