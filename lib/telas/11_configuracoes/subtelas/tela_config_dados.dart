import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../estilos/icones.dart';
import '../../../servicos/banco_dados_servico.dart';
import '../../2_configuracao_inicial/tela_restaurar.dart';

class TelaConfigDados extends StatefulWidget {
  const TelaConfigDados({super.key});

  @override
  State<TelaConfigDados> createState() => _TelaConfigDadosState();
}

class _TelaConfigDadosState extends State<TelaConfigDados> {
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
      bool deveColapsar = _scrollController.offset > 90;
      if (deveColapsar != _isCollapsed) {
        setState(() => _isCollapsed = deveColapsar);
      }
    }
  }

  Future<void> _realizarBackup(BuildContext context) async {
    try {
      final bytes = await BancoDadosServico.instancia.exportarBancoDados();
      final dataStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final nomeArquivo = 'BoviCheck_Backup_$dataStr.db';

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$nomeArquivo');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        final xFile = XFile(file.path);
        await Share.shareXFiles([xFile],
            text: 'Backup do BoviCheck realizado em $dataStr');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao criar backup: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lógica de Cores
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
                child: const Text('Dados & Backup'),
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
                // Banner Informativo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Mantenha seus dados seguros. Faça backups regularmente e salve o arquivo fora do celular.',
                          style: TextStyle(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: 32),

                // Card Exportar
                _CardAcaoDados(
                  titulo: 'Criar Backup',
                  descricao: 'Exportar todos os dados para um arquivo .db',
                  icone: IconesApp.backup,
                  cor: Colors.blue,
                  textoBotao: 'GERAR ARQUIVO',
                  onTap: () => _realizarBackup(context),
                ),

                const SizedBox(height: 24),

                // Card Importar
                _CardAcaoDados(
                  titulo: 'Restaurar Dados',
                  descricao: 'Substituir dados atuais por um backup antigo.',
                  icone: IconesApp.restaurar,
                  cor: Colors.orange,
                  textoBotao: 'SELECIONAR ARQUIVO',
                  isOutlined: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaRestaurar()),
                    );
                  },
                ),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardAcaoDados extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final Color cor;
  final String textoBotao;
  final VoidCallback onTap;
  final bool isOutlined;

  const _CardAcaoDados({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.cor,
    required this.textoBotao,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 40, color: cor),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: isOutlined
                  ? OutlinedButton(onPressed: onTap, child: Text(textoBotao))
                  : FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(backgroundColor: cor),
                      child: Text(textoBotao)),
            ),
          ],
        ),
      ),
    ).animate().scale();
  }
}
