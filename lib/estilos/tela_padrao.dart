import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TelaPadrao extends StatefulWidget {
  final String titulo;
  final Widget corpo;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool usaScrollAnimado;
  final Color? corPrimariaPersonalizada;

  const TelaPadrao({
    super.key,
    required this.titulo,
    required this.corpo,
    this.floatingActionButton,
    this.actions,
    this.usaScrollAnimado = true,
    this.corPrimariaPersonalizada,
  });

  @override
  State<TelaPadrao> createState() => _TelaPadraoState();
}

class _TelaPadraoState extends State<TelaPadrao> {
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
    if (widget.usaScrollAnimado && _scrollController.hasClients) {
      bool deveColapsar = _scrollController.offset > 90;
      if (deveColapsar != _isCollapsed) {
        setState(() => _isCollapsed = deveColapsar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corPrimaria = widget.corPrimariaPersonalizada ?? theme.colorScheme.primary;

    final Color corAppBarBg = _isCollapsed ? corPrimaria : theme.colorScheme.surface;
    final Color corElementos = _isCollapsed ? theme.colorScheme.onPrimary : corPrimaria;
    
    final EdgeInsets paddingTitulo = _isCollapsed
        ? const EdgeInsets.only(left: 72, bottom: 16)
        : const EdgeInsets.only(left: 16, bottom: 16);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: widget.usaScrollAnimado
          ? CustomScrollView(
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
                  actions: widget.actions,
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
                      child: Text(widget.titulo),
                    ),
                    background: Container(
                      color: theme.colorScheme.surface,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(child: widget.corpo),
                ),
                if (widget.floatingActionButton != null)
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            )
          : widget.corpo,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

class CartaoPadrao extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? corFundo;
  final VoidCallback? onTap;

  const CartaoPadrao({
    super.key,
    required this.child,
    this.padding,
    this.corFundo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: corFundo ?? theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class SecaoTitulo extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final Color? cor;

  const SecaoTitulo({
    super.key,
    required this.texto,
    this.icone,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corSecao = cor ?? theme.colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, top: 8),
      child: Row(
        children: [
          if (icone != null) ...[
            Icon(icone, size: 18, color: corSecao),
            const SizedBox(width: 8),
          ],
          Text(
            texto.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: corSecao,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }
}

class CampoFormulario extends StatelessWidget {
  final String label;
  final IconData? icone;
  final Widget child;
  final bool expands;

  const CampoFormulario({
    super.key,
    required this.label,
    required this.icone,
    required this.child,
    this.expands = false,
  });

  @override
  Widget build(BuildContext context) {
    if (expands) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class BotaoPrimario extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool carregando;
  final IconData? icone;
  final bool expandido;

  const BotaoPrimario({
    super.key,
    required this.label,
    this.onPressed,
    this.carregando = false,
    this.icone,
    this.expandido = false,
  });

  @override
  Widget build(BuildContext context) {
    final botao = SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: carregando ? null : onPressed,
        child: carregando
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );

    return expandido ? SizedBox(width: double.infinity, child: botao) : botao;
  }
}

class ItemLista extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? corDestaque;

  const ItemLista({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.leading,
    this.trailing,
    this.onTap,
    this.corDestaque,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CartaoPadrao(
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ],
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
                if (subtitulo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitulo!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class IconeDestaque extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final double tamanho;
  final double tamanhoContainer;

  const IconeDestaque({
    super.key,
    required this.icone,
    required this.cor,
    this.tamanho = 24,
    this.tamanhoContainer = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanhoContainer,
      height: tamanhoContainer,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icone, color: cor, size: tamanho),
    );
  }
}

class BadgeContador extends StatelessWidget {
  final String texto;
  final Color? corFundo;
  final Color? corTexto;

  const BadgeContador({
    super.key,
    required this.texto,
    this.corFundo,
    this.corTexto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: corFundo ?? theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: corTexto ?? theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? mensagem;
  final Widget? botao;

  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    this.mensagem,
    this.botao,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              size: 80,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              titulo,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (mensagem != null) ...[
              const SizedBox(height: 8),
              Text(
                mensagem!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (botao != null) ...[
              const SizedBox(height: 24),
              botao!,
            ],
          ],
        ),
      ),
    );
  }
}

class SecaoCard extends StatelessWidget {
  final String titulo;
  final List<Widget> filhos;
  final EdgeInsets? padding;

  const SecaoCard({
    super.key,
    required this.titulo,
    required this.filhos,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecaoTitulo(texto: titulo),
        const SizedBox(height: 8),
        ...filhos.map((filho) => Padding(
          padding: padding ?? const EdgeInsets.only(bottom: 12),
          child: filho,
        )),
      ],
    );
  }
}
