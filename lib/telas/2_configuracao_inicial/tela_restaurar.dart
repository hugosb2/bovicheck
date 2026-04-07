import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../estilos/icones.dart';
import '../../servicos/banco_dados_servico.dart';
import '../../provedores/provedor_fazenda.dart';
import '../4_dashboard/tela_dashboard.dart';

class TelaRestaurar extends StatefulWidget {
  const TelaRestaurar({super.key});

  @override
  State<TelaRestaurar> createState() => _TelaRestaurarState();
}

class _TelaRestaurarState extends State<TelaRestaurar> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;
  bool _restaurando = false;
  String? _caminhoArquivo;
  String _nomeFazenda = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _carregarNomeFazenda();
  }

  Future<void> _carregarNomeFazenda() async {
    final provedor = context.read<ProvedorFazenda>();
    if (provedor.propriedadeAtiva != null) {
      setState(() {
        _nomeFazenda = provedor.propriedadeAtiva!.nomeFazenda;
      });
    }
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

  Future<void> _selecionarArquivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final pathLower = path.toLowerCase();
        
        if (!pathLower.endsWith('.bvk') && !pathLower.endsWith('.db')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Formato inválido. Selecione um arquivo .bvk ou .db'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _caminhoArquivo = path;
        });
      }
    } catch (e) {
      debugPrint('Erro ao selecionar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir o seletor de arquivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmarRestauracao() async {
    if (_caminhoArquivo == null) return;

    setState(() => _restaurando = true);

    try {
      await BancoDadosServico.instancia.restaurarBancoDados(_caminhoArquivo!);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TelaDashboard()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Backup restaurado com sucesso!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao restaurar: $e'),
              backgroundColor: Colors.red),
        );
        setState(() => _restaurando = false);
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
                child: const Text('Restaurar Backup'),
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
                const SizedBox(height: 20),
                
                Icon(IconesApp.restaurar,
                    size: 80, color: theme.colorScheme.primary)
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                Text(
                  'Restaurar backup para $_nomeFazenda',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Os dados atuais desta fazenda serão substituídos pelos dados do backup.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                InkWell(
                  onTap: _restaurando ? null : _selecionarArquivo,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _caminhoArquivo == null
                              ? Icons.folder_open
                              : Icons.check_circle,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _caminhoArquivo != null
                              ? 'Arquivo selecionado:\n${_caminhoArquivo!.split(Platform.pathSeparator).last}'
                              : 'Toque para selecionar arquivo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().scale(delay: 200.ms),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: (_caminhoArquivo == null || _restaurando)
                        ? null
                        : _confirmarRestauracao,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: _restaurando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('CONFIRMAR RESTAURAÇÃO'),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 16),
                
                if (_caminhoArquivo != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Atenção: Isso substituirá todos os dados atuais.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
