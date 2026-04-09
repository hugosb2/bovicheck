import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'tema.dart';

class TelaPadrao extends StatefulWidget {
  final String titulo;
  final Widget corpo;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool usaScrollAnimado;

  const TelaPadrao({
    super.key,
    required this.titulo,
    required this.corpo,
    this.floatingActionButton,
    this.actions,
    this.usaScrollAnimado = true,
  });

  @override
  State<TelaPadrao> createState() => _TelaPadraoState();
}

class _TelaPadraoState extends State<TelaPadrao> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBarPadrao(
        titulo: widget.titulo,
        actions: widget.actions,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: widget.corpo,
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

// NOTE: Os componentes reutilizáveis agora devem ser acessados via tema.dart.
// CampoFormulario, BotaoPrimario, ItemLista, etc., foram movidos para lá 
// ou substituídos por versões mais modernas.

class CampoFormulario extends StatelessWidget {
  final String label;
  final IconData? icone;
  final Widget child;

  const CampoFormulario({
    super.key,
    required this.label,
    required this.icone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class ItemLista extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ItemLista({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CartaoPadrao(
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 16)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
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
        ...filhos.map(
          (filho) => Padding(
            padding: padding ?? const EdgeInsets.only(bottom: 12),
            child: filho,
          ),
        ),
      ],
    );
  }
}
