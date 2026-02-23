import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../estilos/icones.dart';
import '../../../modelos/propriedade.dart';
import '../../../provedores/provedor_fazenda.dart';
import '../../../servicos/banco_dados_servico.dart';

// Importando o arquivo original do formulário
import '../../2_configuracao_inicial/form_dados_fazenda.dart';

class TelaDetalhesFazenda extends StatefulWidget {
  const TelaDetalhesFazenda({super.key});

  @override
  State<TelaDetalhesFazenda> createState() => _TelaDetalhesFazendaState();
}

class _TelaDetalhesFazendaState extends State<TelaDetalhesFazenda> {
  late ScrollController _scrollController;

  // Variável de estado para controlar a aparência
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
      // Gatilho: Quando passar de 90px de rolagem (ExpandedHeight 140 - Toolbar 56 ~= 84)
      bool deveColapsar = _scrollController.offset > 90;
      if (deveColapsar != _isCollapsed) {
        setState(() => _isCollapsed = deveColapsar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();
    final fazenda = provedor.propriedadeAtiva;

    // --- LÓGICA DE CORES E POSIÇÃO ---

    // 1. Cor do Fundo da Barra (Verde quando pequena, Branco quando grande)
    final Color corAppBarBg =
        _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;

    // 2. Cor dos Elementos (Texto/Ícones: Branco quando pequena, Verde quando grande)
    final Color corElementos =
        _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;

    // 3. Posição do Título (Padding Esquerdo)
    // Quando colapsado (_isCollapsed = true): Padding de 72 para fugir da seta de voltar.
    // Quando expandido (_isCollapsed = false): Padding de 16 para alinhar com a margem.
    final EdgeInsets paddingTitulo = _isCollapsed
        ? const EdgeInsets.only(left: 72, bottom: 16)
        : const EdgeInsets.only(left: 16, bottom: 16);

    if (fazenda == null) {
      return const Scaffold(
          body: Center(child: Text("Nenhuma fazenda selecionada.")));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        // Garante que role mesmo se o conteúdo for pequeno
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,

            // Aplica a cor de fundo dinâmica (Verde ao recolher)
            backgroundColor: corAppBarBg,

            // Aplica a cor nos ícones (Seta de voltar)
            iconTheme: IconThemeData(color: corElementos),

            surfaceTintColor: Colors.transparent,

            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false, // Importante para o padding funcionar
              titlePadding: paddingTitulo, // Aplica o padding dinâmico
              expandedTitleScale: 1.6,

              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: corElementos, // Cor do texto muda suavemente
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                ),
                child: const Text('Propriedade'),
              ),

              background: Container(
                color:
                    theme.colorScheme.surface, // Fundo branco quando expandido
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
                // Ícone Grande com a Inicial
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        fazenda.nomeFazenda.isNotEmpty
                            ? fazenda.nomeFazenda[0].toUpperCase()
                            : 'F',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(),

                const SizedBox(height: 32),

                // Dados da Fazenda
                _InfoCard(
                  label: "Nome da Fazenda",
                  valor: fazenda.nomeFazenda,
                  icon: IconesApp.fazenda,
                ),

                const SizedBox(height: 16),

                _InfoCard(
                  label: "Proprietário",
                  valor: fazenda.nomeProprietario,
                  icon: Icons.person,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: "Cidade",
                        valor: fazenda.cidade,
                        icon: Icons.location_city,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _InfoCard(
                        label: "UF",
                        valor: fazenda.estado,
                        icon: Icons.map,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: "Sistema",
                        valor: fazenda.sistemaProducao,
                        icon: Icons.settings_input_component,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _InfoCard(
                        label: "Área (ha)",
                        valor: fazenda.areaTotalHectares
                            .toString()
                            .replaceAll('.', ','),
                        icon: Icons.aspect_ratio,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Center(
                  child: SelectableText(
                    "ID: ${fazenda.id}",
                    style: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.5),
                        fontSize: 12),
                  ),
                ),

                const SizedBox(height: 24),

                _botaoDanger(theme, fazenda),

                // Espaço extra grande para garantir rolagem em telas altas
                SizedBox(height: MediaQuery.of(context).size.height * 0.4),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Usa o formulário original para editar
              builder: (_) => FormDadosFazenda(propriedadeExistente: fazenda),
            ),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text("EDITAR DADOS"),
      ),
    );
  }

  Widget _botaoDanger(ThemeData theme, Propriedade fazenda) {
    return Card(
      elevation: 0,
      color: Colors.red.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () => _confirmarDelecao(context, fazenda),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELETAR FAZENDA',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remover esta fazenda e todos os dados',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.red),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  void _confirmarDelecao(BuildContext context, Propriedade fazenda) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deletar fazenda?'),
        content: Text(
          'Tem certeza que deseja deletar "${fazenda.nomeFazenda}"? '
          'Todos os dados serão perdidos permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETAR'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    await BancoDadosServico.instancia.deletePropriedade(fazenda.id);
    
    if (!mounted) return;
    
    final provedor = context.read<ProvedorFazenda>();
    await provedor.carregarPropriedades();
    
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${fazenda.nomeFazenda}" deletada')),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icon;

  const _InfoCard(
      {required this.label, required this.valor, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              valor,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
