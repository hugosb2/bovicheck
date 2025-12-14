import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../provedores/theme_provider.dart';

class TelaConfiguracaoCores extends StatelessWidget {
  const TelaConfiguracaoCores({super.key});

  final List<Color> colorOptions = const [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isManualColorSelectionEnabled = !themeProvider.useDynamicColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cores'),
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
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: SwitchListTile(
              title: const Text('Cores Dinâmicas'),
              subtitle:
                  const Text('Usa as cores do papel de parede (Android 12+)'),
              value: themeProvider.useDynamicColors,
              onChanged: (value) => themeProvider.setUseDynamicColors(value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          Opacity(
            opacity: isManualColorSelectionEnabled ? 1.0 : 0.5,
            child: AbsorbPointer(
              absorbing: !isManualColorSelectionEnabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cor Principal Manual',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: colorOptions.asMap().entries.map((entry) {
                      return _buildColorOption(
                        context,
                        color: entry.value,
                        themeProvider: themeProvider,
                      )
                          .animate()
                          .fadeIn(duration: 200.ms, delay: (entry.key * 50).ms)
                          .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1, 1));
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context, {
    required Color color,
    required ThemeProvider themeProvider,
  }) {
    final theme = Theme.of(context);
    final bool isSelected = themeProvider.selectedColor == color;
    return GestureDetector(
      onTap: () => themeProvider.setSelectedColor(color),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
          border: isSelected
              ? Border.all(
                  color: Colors.white,
                  width: 3.0,
                )
              : Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 2,
                ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: ThemeData.estimateBrightnessForColor(color) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black,
                size: 28,
              )
            : null,
      ),
    );
  }
}

class ColorSettingsView extends TelaConfiguracaoCores {
  const ColorSettingsView({super.key}) : super();
}
