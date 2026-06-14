import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TemaApp {
  static const double _raioBorda = 16.0;

  static const double _tamanhoMinimoToque = 48.0;
  static const double _alturaBotao = 56.0;
  static const double _paddingFormulario = 18.0;

  /// Cria um [TextTheme] com todas as fontes 2dp maiores que o padrão M3,
  /// preservando pesos e tracking originais.
  static TextTheme _textThemeComFontesMaiores() {
    final base = ThemeData.light().textTheme;
    TextStyle maior(TextStyle? style, double padrao) {
      final s = style ?? TextStyle(fontSize: padrao);
      return s.copyWith(fontSize: (s.fontSize ?? padrao) + 2);
    }
    return TextTheme(
      displayLarge: maior(base.displayLarge, 57),
      displayMedium: maior(base.displayMedium, 45),
      displaySmall: maior(base.displaySmall, 36),
      headlineLarge: maior(base.headlineLarge, 32),
      headlineMedium: maior(base.headlineMedium, 28),
      headlineSmall: maior(base.headlineSmall, 24),
      titleLarge: maior(base.titleLarge, 22),
      titleMedium: maior(base.titleMedium, 16),
      titleSmall: maior(base.titleSmall, 14),
      bodyLarge: maior(base.bodyLarge, 16),
      bodyMedium: maior(base.bodyMedium, 14),
      bodySmall: maior(base.bodySmall, 12),
      labelLarge: maior(base.labelLarge, 14),
      labelMedium: maior(base.labelMedium, 12),
      labelSmall: maior(base.labelSmall, 11),
    );
  }

  static ThemeData _construirTemaBase(ColorScheme esquemaCores) {
    final Color corPrimariaPura = esquemaCores.primary;
    final Color corFonteNoPrimario = corPrimariaPura.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    final base = ThemeData(
      colorScheme: esquemaCores.copyWith(
        primary: corPrimariaPura,
        onPrimary: corFonteNoPrimario,
        secondary: corPrimariaPura,
        onSecondary: corFonteNoPrimario,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      brightness: esquemaCores.brightness,
      textTheme: _textThemeComFontesMaiores(),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: corPrimariaPura,
        foregroundColor: corFonteNoPrimario,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: corFonteNoPrimario, size: 26),
        titleTextStyle: TextStyle(
          color: corFonteNoPrimario,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      scaffoldBackgroundColor: esquemaCores.surface,

      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        color: esquemaCores.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquemaCores.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: _paddingFormulario),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide(
            color: esquemaCores.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide(
            color: esquemaCores.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide(
            color: esquemaCores.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide(
            color: esquemaCores.error,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: esquemaCores.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: esquemaCores.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 16,
        ),
        prefixIconColor: esquemaCores.onSurfaceVariant,
        suffixIconColor: esquemaCores.onSurfaceVariant,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: corPrimariaPura.withValues(alpha: 0.3),
          backgroundColor: corPrimariaPura,
          foregroundColor: corFonteNoPrimario,
          minimumSize: const Size(double.infinity, _alturaBotao),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 2,
          shadowColor: corPrimariaPura.withValues(alpha: 0.3),
          backgroundColor: corPrimariaPura,
          foregroundColor: corFonteNoPrimario,
          minimumSize: const Size(double.infinity, _alturaBotao),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: corPrimariaPura,
          side: BorderSide(color: corPrimariaPura),
          minimumSize: const Size(double.infinity, _alturaBotao),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: corPrimariaPura,
          minimumSize: const Size(_tamanhoMinimoToque, _tamanhoMinimoToque),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: corPrimariaPura,
        foregroundColor: corFonteNoPrimario,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
        ),
      ),

      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        minVerticalPadding: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: esquemaCores.onSurfaceVariant,
        textColor: esquemaCores.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: esquemaCores.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: esquemaCores.onSurfaceVariant,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: esquemaCores.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          color: esquemaCores.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: esquemaCores.onSurfaceVariant,
          fontSize: 16,
          height: 1.4,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: esquemaCores.inverseSurface,
        contentTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: esquemaCores.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return corPrimariaPura;
          }
          return esquemaCores.onSurfaceVariant;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return corPrimariaPura;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(corFonteNoPrimario),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: corPrimariaPura,
        linearTrackColor: esquemaCores.primaryContainer,
        circularTrackColor: esquemaCores.primaryContainer,
        linearMinHeight: 6,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: corPrimariaPura,
        unselectedLabelColor: esquemaCores.onSurfaceVariant,
        indicatorColor: corPrimariaPura,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: esquemaCores.surface,
        selectedItemColor: corPrimariaPura,
        unselectedItemColor: esquemaCores.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: esquemaCores.surface,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
      ),
    );
  }

  static ThemeData criarTemaClaro(Color corSemente) {
    final esquema = ColorScheme.fromSeed(
      seedColor: corSemente,
      brightness: Brightness.light,
    ).copyWith(
      primary: corSemente,
      secondary: corSemente,
      onPrimary: corSemente.computeLuminance() > 0.5 ? Colors.black : Colors.white,
    );
    return _construirTemaBase(esquema);
  }

  static ThemeData criarTemaEscuro(Color corSemente) {
    final esquema = ColorScheme.fromSeed(
      seedColor: corSemente,
      brightness: Brightness.dark,
    ).copyWith(
      primary: corSemente,
      secondary: corSemente,
      onPrimary: corSemente.computeLuminance() > 0.5 ? Colors.black : Colors.white,
    );
    return _construirTemaBase(esquema);
  }
}

// ============ COMPONENTES REUTILIZÁVEIS ============

class AppBarPadrao extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centralizar;

  const AppBarPadrao({
    super.key,
    required this.titulo,
    this.actions,
    this.leading,
    this.centralizar = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      actions: actions,
      centerTitle: centralizar,
      title: Text(
        titulo,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class CampoFormularioPadrao extends StatelessWidget {
  final String label;
  final IconData? icone;
  final String? svgIcone;
  final TextEditingController? controller;
  final String? Function(String?)? validador;
  final TextInputType? tipoTeclado;
  final int? maxLinhas;
  final bool soLeitura;
  final Widget? child;
  final void Function(String)? onChanged;
  final void Function()? onTap;

  const CampoFormularioPadrao({
    super.key,
    required this.label,
    this.icone,
    this.svgIcone,
    this.controller,
    this.validador,
    this.tipoTeclado,
    this.maxLinhas = 1,
    this.soLeitura = false,
    this.child,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (child != null) {
      return child!;
    }

    return TextFormField(
      controller: controller,
      validator: validador,
      keyboardType: tipoTeclado,
      maxLines: maxLinhas,
      readOnly: soLeitura,
      onChanged: onChanged,
      onTap: onTap,
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: svgIcone != null
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: SvgPicture.asset(
                  svgIcone!,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
                ),
              )
            : (icone != null ? Icon(icone, size: 22) : null),
      ),
    );
  }
}
class DropdownPadrao<T> extends StatelessWidget {
  final String label;
  final T? valorSelecionado;
  final List<DropdownMenuItem<T>> itens;
  final void Function(T?) onChanged;
  final String? Function(T?)? validador;
  final IconData? icone;
  final String? svgIcone;

  const DropdownPadrao({
    super.key,
    required this.label,
    required this.valorSelecionado,
    required this.itens,
    required this.onChanged,
    this.validador,
    this.icone,
    this.svgIcone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final corTexto = theme.colorScheme.onSurface;
    final corFundoMenu = theme.colorScheme.surfaceContainerHigh;

    return DropdownButtonFormField<T>(
      initialValue: valorSelecionado,
      items: itens,
      onChanged: onChanged,
      validator: validador,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: svgIcone != null
            ? Padding(
                padding: const EdgeInsets.all(14),
                child: SvgPicture.asset(
                  svgIcone!,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
                ),
              )
            : (icone != null ? Icon(icone, size: 22) : null),
      ),
      isExpanded: true,
      style: TextStyle(fontSize: 17, color: corTexto),
      dropdownColor: corFundoMenu,
      menuMaxHeight: 300,
    );
  }
}

class BotaoPadrao extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool carregando;
  final IconData? icone;
  final bool expandido;
  final Color? corFundo;
  final bool outlined;

  const BotaoPadrao({
    super.key,
    required this.label,
    this.onPressed,
    this.carregando = false,
    this.icone,
    this.expandido = false,
    this.corFundo,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget conteudo() {
      if (carregando) {
        return SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: outlined ? theme.colorScheme.primary : Colors.white,
          ),
        );
      }

      if (icone != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 22),
            const SizedBox(width: 10),
            Text(label),
          ],
        );
      }

      return Text(label);
    }

    final botao = outlined
        ? OutlinedButton(
            onPressed: carregando ? null : onPressed,
            child: conteudo(),
          )
        : FilledButton(
            onPressed: carregando ? null : onPressed,
            style: corFundo != null
                ? FilledButton.styleFrom(backgroundColor: corFundo)
                : null,
            child: conteudo(),
          );

    return expandido
        ? SizedBox(width: double.infinity, child: botao)
        : botao;
  }
}

class CartaoPadrao extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? corFundo;

  const CartaoPadrao({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.corFundo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: corFundo ?? theme.colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}

class SecaoTitulo extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final String? svgIcone;

  const SecaoTitulo({
    super.key,
    required this.texto,
    this.icone,
    this.svgIcone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      child: Row(
        children: [
          if (svgIcone != null) ...[
            SvgPicture.asset(
              svgIcone!,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
            ),
            const SizedBox(width: 10),
          ] else if (icone != null) ...[
            Icon(icone, size: 22, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
          ],
          Text(
            texto.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class EstadoVazioPadrao extends StatelessWidget {
  final IconData? icone;
  final String? svgIcone;
  final String titulo;
  final String? mensagem;
  final String? textoBotao;
  final VoidCallback? onPressedBotao;

  const EstadoVazioPadrao({
    super.key,
    this.icone,
    this.svgIcone,
    required this.titulo,
    this.mensagem,
    this.textoBotao,
    this.onPressedBotao,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: svgIcone != null
                  ? SvgPicture.asset(
                      svgIcone!,
                      width: 72,
                      height: 72,
                      colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
                    )
                  : Icon(
                      icone ?? Icons.help_outline,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
            ),
            const SizedBox(height: 32),
            Text(
              titulo,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (mensagem != null) ...[
              const SizedBox(height: 12),
              Text(
                mensagem!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (textoBotao != null && onPressedBotao != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: 260,
                child: FilledButton.icon(
                  onPressed: onPressedBotao,
                  icon: const Icon(Icons.add, size: 22),
                  label: Text(textoBotao!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// NOVO COMPONENTE: Botão Flutuante com Seta Animada
class BotaoFlutuanteBovi extends StatelessWidget {
  final String label;
  final IconData icone;
  final VoidCallback onPressed;
  final bool comSeta;

  const BotaoFlutuanteBovi({
    super.key,
    required this.label,
    required this.icone,
    required this.onPressed,
    this.comSeta = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (comSeta)
          Padding(
            padding: const EdgeInsets.only(right: 24, bottom: 8),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            )
            .animate(onPlay: (controller) => controller.repeat())
            .moveY(begin: -10, end: 0, duration: 800.ms, curve: Curves.easeInOut)
            .fadeIn(),
          ),
        FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 6,
          icon: Icon(icone),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
      ],
    );
  }
}
