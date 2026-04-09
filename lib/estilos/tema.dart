import 'package:flutter/material.dart';

class TemaApp {
  static const double _raioBorda = 16.0;
  static const double _raioBordaPequeno = 12.0;

  static ThemeData _construirTemaBase(ColorScheme esquemaCores) {
    // Forçamos a cor primária a ser a cor pura do esquema (vibrante)
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
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: corPrimariaPura,
        foregroundColor: corFonteNoPrimario,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: corFonteNoPrimario),
        titleTextStyle: TextStyle(
          color: corFonteNoPrimario,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),

      scaffoldBackgroundColor: esquemaCores.surface,

      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        color: esquemaCores.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          side: BorderSide(
            color: esquemaCores.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquemaCores.surfaceContainerHighest.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide(
            color: esquemaCores.outlineVariant.withValues(alpha: 0.4),
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
        ),
        hintStyle: TextStyle(
          color: esquemaCores.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        prefixIconColor: esquemaCores.onSurfaceVariant,
        suffixIconColor: esquemaCores.onSurfaceVariant,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: esquemaCores.primary.withValues(alpha: 0.3),
          backgroundColor: esquemaCores.primary,
          foregroundColor: esquemaCores.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 2,
          shadowColor: esquemaCores.primary.withValues(alpha: 0.3),
          backgroundColor: esquemaCores.primary,
          foregroundColor: esquemaCores.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: esquemaCores.primary,
          side: BorderSide(color: esquemaCores.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: esquemaCores.primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: esquemaCores.primaryContainer,
        foregroundColor: esquemaCores.onPrimaryContainer,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: esquemaCores.outlineVariant.withValues(alpha: 0.4),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_raioBordaPequeno),
        ),
        iconColor: esquemaCores.onSurfaceVariant,
        textColor: esquemaCores.onSurface,
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
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: esquemaCores.inverseSurface,
        contentTextStyle: TextStyle(color: esquemaCores.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: esquemaCores.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return esquemaCores.primary;
          }
          return esquemaCores.onSurfaceVariant;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return esquemaCores.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(esquemaCores.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: esquemaCores.primary,
        linearTrackColor: esquemaCores.primaryContainer,
        circularTrackColor: esquemaCores.primaryContainer,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: esquemaCores.primary,
        unselectedLabelColor: esquemaCores.onSurfaceVariant,
        indicatorColor: esquemaCores.primary,
        dividerColor: Colors.transparent,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: esquemaCores.surface,
        selectedItemColor: esquemaCores.primary,
        unselectedItemColor: esquemaCores.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: esquemaCores.surface,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
          fontSize: 18,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class CampoFormularioPadrao extends StatelessWidget {
  final String label;
  final IconData? icone;
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icone != null ? Icon(icone) : null,
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

  const DropdownPadrao({
    super.key,
    required this.label,
    required this.valorSelecionado,
    required this.itens,
    required this.onChanged,
    this.validador,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: valorSelecionado,
      items: itens,
      onChanged: onChanged,
      validator: validador,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icone != null ? Icon(icone) : null,
      ),
      isExpanded: true,
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
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: outlined ? theme.colorScheme.primary : Colors.white,
          ),
        );
      }

      if (icone != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 20),
            const SizedBox(width: 8),
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
        ? SizedBox(width: double.infinity, height: 56, child: botao) 
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

  const SecaoTitulo({
    super.key,
    required this.texto,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          if (icone != null) ...[
            Icon(icone, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(
            texto.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
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
  final IconData icone;
  final String titulo;
  final String? mensagem;
  final String? textoBotao;
  final VoidCallback? onPressedBotao;

  const EstadoVazioPadrao({
    super.key,
    required this.icone,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icone,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
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
            if (textoBotao != null && onPressedBotao != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onPressedBotao,
                icon: const Icon(Icons.add),
                label: Text(textoBotao!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
