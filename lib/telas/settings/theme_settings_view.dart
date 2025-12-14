import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bovicheck/provedores/theme_provider.dart';

class TelaConfiguracaoTema extends StatelessWidget {
  const TelaConfiguracaoTema({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema do Aplicativo'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeOption(
            context,
            title: 'Claro',
            icon: Icons.light_mode_outlined,
            value: ThemeMode.light,
            selectedValue: themeProvider.themeMode,
            onChanged: (value) => themeProvider.setThemeMode(value),
            index: 0,
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            context,
            title: 'Escuro',
            icon: Icons.dark_mode_outlined,
            value: ThemeMode.dark,
            selectedValue: themeProvider.themeMode,
            onChanged: (value) => themeProvider.setThemeMode(value),
            index: 1,
          ),
          const SizedBox(height: 12),
          _buildThemeOption(
            context,
            title: 'Padrão do Sistema',
            icon: Icons.brightness_auto_outlined,
            value: ThemeMode.system,
            selectedValue: themeProvider.themeMode,
            onChanged: (value) => themeProvider.setThemeMode(value),
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode selectedValue,
    required ValueChanged<ThemeMode> onChanged,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedValue == value;

    return Card(
      elevation: isSelected ? 2 : 1,
      shadowColor: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.3)
          : theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged(value),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 100).ms)
        .slideX(begin: 0.1, end: 0);
  }
}

class ThemeSettingsView extends TelaConfiguracaoTema {
  const ThemeSettingsView({super.key}) : super();
}
