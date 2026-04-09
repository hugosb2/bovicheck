import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import para o SVG
import '../../../estilos/icones.dart';
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

// Widgets locais
import 'widgets/gaveta_menu.dart';
// Se o card_ia.dart não existir, remova esta linha e o uso do CardIA abaixo
// import 'widgets/card_ia.dart';

class TelaDashboard extends StatefulWidget {
  const TelaDashboard({super.key});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // Garante atualização dos dados ao abrir o Dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProvedorFazenda>().carregarPropriedades();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // 140 é a altura expandida definida abaixo.
    if (_scrollController.hasClients &&
        _scrollController.offset > (140 - kToolbarHeight)) {
      if (!_isCollapsed) setState(() => _isCollapsed = true);
    } else {
      if (_isCollapsed) setState(() => _isCollapsed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedor = context.watch<ProvedorFazenda>();

    // Estados para controle de UI
    final bool temFazenda = provedor.propriedadeAtiva != null;
    final bool temLotes = provedor.lotes.isNotEmpty;
    final bool temAnimais = provedor.animais.isNotEmpty;
    final bool isLoading = provedor.isLoading;

    if (isLoading) {
      return Scaffold(
          body: Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.primary)));
    }

    if (!temFazenda) {
      return const Scaffold(
          body: Center(
              child: Text(
                  "Nenhuma fazenda selecionada. Vá em Menu > Trocar Fazenda.")));
    }

    // Cores da AppBar
    final Color corAppBarBg =
        _isCollapsed ? theme.colorScheme.primary : theme.colorScheme.surface;
    final Color corElementos =
        _isCollapsed ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final EdgeInsets paddingTitulo = _isCollapsed
        ? const EdgeInsets.only(left: 60, bottom: 16)
        : const EdgeInsets.only(left: 16, bottom: 16);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const GavetaMenu(),
      body: RefreshIndicator(
        onRefresh: () async {
          await provedor.carregarPropriedades();
        },
        child: CustomScrollView(
          controller: _scrollController,
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
                title: Text(
                  'Dashboard',
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
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Saudação
                  Text(
                    "Olá, ${provedor.propriedadeAtiva!.nomeProprietario.split(' ').first}",
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn(),

                  Text(
                    provedor.propriedadeAtiva!.nomeFazenda,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),

                  // 2. Card Inteligente (Onboarding ou Info)
                  if (!temAnimais)
                    _CardPrimeirosPassos(temLotes: temLotes)
                  else
                    // Placeholder se você não tiver o arquivo card_ia.dart ainda
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(IconesApp.iaConsultor,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          const Expanded(
                              child: Text(
                                  "Seu rebanho está crescendo! Acompanhe os indicadores abaixo.")),
                        ],
                      ),
                    ).animate().fadeIn(),

                  const SizedBox(height: 24),

                  // 3. KPIs (Indicadores)
                  Text(
                    "Resumo do Rebanho",
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      // KPI: Total Animais (COM SVG)
                      _CardKPI(
                        titulo: "Total Animais",
                        valor: provedor.totalAnimais.toString(),
                        // Passamos o widget SVG aqui
                        customIcon: SvgPicture.asset(
                          IconesApp.iconAnimalSvg,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                              Colors.blue, BlendMode.srcIn),
                        ),
                        cor: Colors.blue,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TelaListaAnimais())),
                      ),

                      // KPI: Lotes
                      _CardKPI(
                        titulo: "Lotes",
                        valor: provedor.totalLotes.toString(),
                        iconData: IconesApp.lote,
                        cor: Colors.orange,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TelaListaLotes())),
                      ),

                      // KPI: Produção Leite (Mês)
                      _CardKPI(
                        titulo: "Leite (Mês)",
                        valor: "${provedor.totalLeiteMes.toStringAsFixed(0)}L",
                        iconData: IconesApp.leite,
                        cor: Colors.blueAccent,
                      ),

                      // KPI: GMD Médio
                      _CardKPI(
                        titulo: "GMD Médio",
                        valor: "${provedor.mediaGMD.toStringAsFixed(2)}kg",
                        iconData: IconesApp.peso,
                        cor: Colors.teal,
                      ),

                      // KPI: Alertas
                      _CardKPI(
                        titulo: "Alertas",
                        valor: provedor.totalAnimaisDoentes.toString(),
                        iconData: IconesApp.iaAtencao,
                        cor: provedor.totalAnimaisDoentes > 0
                            ? Colors.red
                            : Colors.green,
                        isAlerta: provedor.totalAnimaisDoentes > 0,
                      ),

                      // KPI: Nascimentos
                      _CardKPI(
                        titulo: "Nascimentos",
                        valor: provedor.totalNascimentos.toString(),
                        iconData: IconesApp.reproducao,
                        cor: Colors.purple,
                      ),

                      // KPI: Mortalidade
                      _CardKPI(
                        titulo: "Mortalidade",
                        valor: "${provedor.taxaMortalidade.toStringAsFixed(1)}%",
                        iconData: Icons.warning_amber_rounded,
                        cor: provedor.taxaMortalidade > 5 ? Colors.red : Colors.grey,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 4. Ações Rápidas (Aparecem se tiver animais)
                  if (temAnimais) ...[
                    Text(
                      "Ações Rápidas",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _BotaoAcaoRapida(
                            label: "Pesar",
                            icon: IconesApp.peso,
                            color: Colors.indigo,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const FormPesagem())),
                          ),
                          _BotaoAcaoRapida(
                            label: "Sanitário",
                            icon: IconesApp.vacina,
                            color: Colors.red,
                            // Abre sem animal selecionado (Dashboard mode)
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const FormSanitario())),
                          ),
                          _BotaoAcaoRapida(
                            label: "Reprodução",
                            icon: IconesApp.reproducao,
                            color: Colors.pink,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const FormReprodutivo())),
                          ),
                          _BotaoAcaoRapida(
                            label: "Leite",
                            icon: IconesApp.leite,
                            color: Colors.blue,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const FormLeite())),
                          ),
                          _BotaoAcaoRapida(
                            label: "Novo Animal",
                            icon: Icons.add,
                            color: Colors.green,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const FormAnimal())),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 5. Últimas Atividades (Placeholder)
                  Text(
                    "Últimas Atividades",
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.history, color: Colors.white),
                      ),
                      title: Text("Sistema Iniciado"),
                      subtitle: Text("Bem-vindo ao novo BoviCheck!"),
                      trailing: Text("Hoje"),
                    ),
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ADAPTADOS ---

// 1. Card de Onboarding
class _CardPrimeirosPassos extends StatelessWidget {
  final bool temLotes;

  const _CardPrimeirosPassos({required this.temLotes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool etapa1Concluida = temLotes;

    return Card(
      elevation: 2,
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Text(
                  "Comece por aqui",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Para usar o sistema completo, siga os passos abaixo:",
              style: TextStyle(
                fontSize: 14,
                color:
                    theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),

            // Passo 1
            _ItemPasso(
              titulo: "1. Criar Lote ou Pasto",
              descricao: "Defina onde os animais ficarão.",
              concluido: etapa1Concluida,
              onTap: etapa1Concluida
                  ? null
                  : () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FormLote())),
            ),

            Divider(
                color: theme.colorScheme.onPrimaryContainer
                    .withValues(alpha: 0.2)),

            // Passo 2
            _ItemPasso(
              titulo: "2. Cadastrar Primeiro Animal",
              descricao: "Adicione bovinos ao lote criado.",
              concluido: false,
              bloqueado: !etapa1Concluida,
              onTap: !etapa1Concluida
                  ? null
                  : () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FormAnimal())),
            ),
          ],
        ),
      ),
    ).animate().scale().shimmer(
        duration: 2.seconds,
        delay: 1.seconds,
        color: theme.colorScheme.primary.withValues(alpha: 0.3));
  }
}

class _ItemPasso extends StatelessWidget {
  final String titulo;
  final String descricao;
  final bool concluido;
  final bool bloqueado;
  final VoidCallback? onTap;

  const _ItemPasso(
      {required this.titulo,
      required this.descricao,
      required this.concluido,
      this.bloqueado = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color corBase = concluido
        ? Colors.green
        : (bloqueado
            ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.4)
            : theme.colorScheme.primary);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: corBase.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(
          concluido
              ? Icons.check
              : (bloqueado ? Icons.lock : Icons.arrow_forward),
          color: corBase,
          size: 20,
        ),
      ),
      title: Text(
        titulo,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: bloqueado
              ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.onPrimaryContainer,
          decoration: concluido ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(descricao,
          style: TextStyle(
              color:
                  theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7))),
      trailing: (onTap != null)
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary),
              child: const Text("Criar"),
            )
          : null,
    );
  }
}

// 2. Card de KPI (Adaptado para aceitar Widget ou IconData)
class _CardKPI extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData? iconData; // Opção 1
  final Widget? customIcon; // Opção 2 (Para o SVG)
  final Color cor;
  final bool isAlerta;
  final VoidCallback? onTap;

  const _CardKPI({
    required this.titulo,
    required this.valor,
    this.iconData,
    this.customIcon,
    required this.cor,
    this.isAlerta = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Lógica para exibir SVG ou Ícone Padrão
                customIcon ?? Icon(iconData, color: cor, size: 24),
                if (isAlerta)
                  Icon(Icons.circle, color: theme.colorScheme.error, size: 8),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(valor,
                    style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface)),
                Text(titulo,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            )
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms);
  }
}

// 3. Botão de Ação Rápida
class _BotaoAcaoRapida extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BotaoAcaoRapida(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
