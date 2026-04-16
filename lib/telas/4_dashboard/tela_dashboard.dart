import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../estilos/icones.dart';
import '../../../estilos/tema.dart';
import '../../../provedores/provedor_fazenda.dart';

// --- IMPORTS DOS FORMULÁRIOS ---
import '../10_formularios/form_pesagem.dart';
import '../10_formularios/form_sanitario.dart';
import '../10_formularios/form_reprodutivo.dart';
import '../10_formularios/form_leite.dart';
import '../8_rebanho/form_animal.dart';
import '../8_rebanho/tela_lista_animais.dart';
import '../9_lotes/form_lote.dart';
import '../9_lotes/tela_lista_lotes.dart';
import '../5_ia_consultor/tela_ia_consultor.dart';

// Widgets locais
import 'widgets/gaveta_menu.dart';

class TelaDashboard extends StatefulWidget {
  const TelaDashboard({super.key});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> {
  final ScrollController _scrollController = ScrollController();
  bool _exibirTitulo = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProvedorFazenda>().carregarPropriedades();
    });
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      // Ativa o título um pouco antes de terminar de recolher a barra (140 é o expandedHeight)
      final bool novoExibir = _scrollController.offset > 60;
      if (novoExibir != _exibirTitulo) {
        setState(() {
          _exibirTitulo = novoExibir;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();

    final bool temFazenda = provedor.propriedadeAtiva != null;
    final bool isLoading = provedor.isLoading;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    if (!temFazenda) {
      return const Scaffold(
        body: Center(
          child: Text("Nenhuma fazenda selecionada. Vá em Menu > Trocar Fazenda."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const GavetaMenu(),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. App Bar Moderna com Saudação
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            title: AnimatedOpacity(
              opacity: _exibirTitulo ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: const Text(
                "Painel",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOpacity(
                        opacity: _exibirTitulo ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          "Olá, ${provedor.propriedadeAtiva!.nomeProprietario.split(' ').first}!",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: theme.colorScheme.onPrimary.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            provedor.propriedadeAtiva!.nomeFazenda,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {},
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ),

          // 2. Conteúdo do Dashboard
          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: () async => await provedor.carregarPropriedades(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- BENTO GRID KPIs ---
                    _SecaoTitulo(titulo: "Resumo Estratégico"),
                    const SizedBox(height: 12),
                    
                    // Layout Bento
                    Row(
                      children: [
                        // Card Grande: Total Animais
                        Expanded(
                          flex: 2,
                          child: _CardKPIBento(
                            titulo: "Total Rebanho",
                            valor: provedor.totalAnimais.toString(),
                            cor: Colors.blue.shade700,
                            iconWidget: SvgPicture.asset(
                              IconesApp.iconAnimalSvg,
                              width: 32,
                              height: 32,
                              colorFilter: ColorFilter.mode(Colors.blue.shade700, BlendMode.srcIn),
                            ),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaListaAnimais())),
                            isDestaque: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Coluna de 2 cards menores
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _CardKPIBento(
                                titulo: "Lotes",
                                valor: provedor.totalLotes.toString(),
                                cor: Colors.orange.shade800,
                                icon: IconesApp.lote,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaListaLotes())),
                              ),
                              const SizedBox(height: 12),
                              _CardKPIBento(
                                titulo: "Alertas",
                                valor: provedor.totalAnimaisDoentes.toString(),
                                cor: provedor.totalAnimaisDoentes > 0 ? Colors.red : Colors.green,
                                icon: IconesApp.iaAtencao,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _CardKPIBento(
                            titulo: "Leite (Mês)",
                            valor: "${provedor.totalLeiteMes.toStringAsFixed(0)}L",
                            cor: Colors.cyan.shade700,
                            icon: IconesApp.leite,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CardKPIBento(
                            titulo: "GMD Médio",
                            valor: "${provedor.mediaGMD.toStringAsFixed(2)}kg",
                            cor: Colors.teal.shade700,
                            icon: IconesApp.peso,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- CARD DE SUGESTÃO IA ---
                    _CardSugestaoIA(
                      sugestao: provedor.totalAnimaisDoentes > 0 
                        ? "Atenção: Você tem ${provedor.totalAnimaisDoentes} animais com alertas de saúde. Recomenda-se vistoria no lote."
                        : "Seu rebanho está saudável! O GMD médio subiu 0.2kg esta semana. Continue assim.",
                      carregando: false,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaIAConsultor())),
                    ),

                    const SizedBox(height: 32),

                    // --- AÇÕES RÁPIDAS ---
                    _SecaoTitulo(titulo: "Ações do Dia"),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _BotaoAcaoCircular(
                          label: "Pesar",
                          icon: IconesApp.peso,
                          cor: Colors.indigo,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormPesagem())),
                        ),
                        _BotaoAcaoCircular(
                          label: "Saúde",
                          icon: IconesApp.vacina,
                          cor: Colors.red,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormSanitario())),
                        ),
                        _BotaoAcaoCircular(
                          label: "Cio/Prenhez",
                          icon: IconesApp.reproducao,
                          cor: Colors.pink,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormReprodutivo())),
                        ),
                        _BotaoAcaoCircular(
                          label: "Leite",
                          icon: IconesApp.leite,
                          cor: Colors.blue,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormLeite())),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // --- ÚLTIMAS ATIVIDADES ---
                    _SecaoTitulo(titulo: "Linha do Tempo"),
                    const SizedBox(height: 12),
                    _CardAtividade(
                      titulo: "Novo registro de pesagem",
                      subtitulo: "Lote: Engorda I",
                      data: "Há 15 min",
                      icon: IconesApp.peso,
                      cor: Colors.indigo,
                    ),
                    _CardAtividade(
                      titulo: "Vacinação concluída",
                      subtitulo: "12 animais imunizados",
                      data: "Hoje, 08:30",
                      icon: IconesApp.vacina,
                      cor: Colors.red,
                    ),
                    
                    const SizedBox(height: 100), // Espaço para não bater no fundo
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: BotaoFlutuanteBovi(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FormAnimal())),
        label: "Novo Animal",
        icone: Icons.add_rounded,
      ),
    );
  }
}

// --- WIDGETS AUXILIARES REFORMULADOS ---

class _SecaoTitulo extends StatelessWidget {
  final String titulo;
  const _SecaoTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _CardKPIBento extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData? icon;
  final Widget? iconWidget;
  final Color cor;
  final VoidCallback? onTap;
  final bool isDestaque;

  const _CardKPIBento({
    required this.titulo,
    required this.valor,
    this.icon,
    this.iconWidget,
    required this.cor,
    this.onTap,
    this.isDestaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool clicavel = onTap != null;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: isDestaque ? 160 : 74,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: clicavel 
              ? cor.withValues(alpha: 0.3) 
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: clicavel ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: clicavel ? cor.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            if (clicavel)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.arrow_outward_rounded, size: 14, color: cor.withValues(alpha: 0.5)),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: isDestaque ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                if (isDestaque) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: iconWidget ?? Icon(icon, color: cor, size: 24),
                  ),
                  const Spacer(),
                  Text(valor, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, color: cor)),
                  Text(titulo, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant)),
                ] else ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: cor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(valor, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                            ),
                            Text(titulo, 
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 10), 
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _CardSugestaoIA extends StatelessWidget {
  final String sugestao;
  final bool carregando;
  final VoidCallback onTap;

  const _CardSugestaoIA({required this.sugestao, required this.carregando, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: carregando ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
              theme.colorScheme.surfaceContainerHighest,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: carregando 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Insight da IA",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (carregando)
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds)
                  else
                    Text(
                      sugestao,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
            if (!carregando) Icon(Icons.chevron_right_rounded, color: theme.colorScheme.primary),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _BotaoAcaoCircular extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color cor;
  final VoidCallback onTap;

  const _BotaoAcaoCircular({required this.label, required this.icon, required this.cor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: cor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().scale(delay: 200.ms);
  }
}

class _CardAtividade extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String data;
  final IconData icon;
  final Color cor;

  const _CardAtividade({required this.titulo, required this.subtitulo, required this.data, required this.icon, required this.cor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitulo, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(data, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
