import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ColorSettingsView extends StatelessWidget {
  const ColorSettingsView({super.key});

  final List<Color> colorOptions = const [
    Colors.green, Colors.blue, Colors.red, Colors.purple,
    Colors.orange, Colors.teal, Colors.pink, Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isManualColorSelectionEnabled = !themeProvider.useDynamicColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cores'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          SwitchListTile(
            title: const Text('Cores Dinâmicas'),
            subtitle: const Text('Usa as cores do papel de parede (Android 12+)'),
            value: themeProvider.useDynamicColors,
            onChanged: (value) => themeProvider.setUseDynamicColors(value),
          ),
          const Divider(),
          Opacity(
            opacity: isManualColorSelectionEnabled ? 1.0 : 0.5,
            child: AbsorbPointer(
              absorbing: !isManualColorSelectionEnabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Text(
                      'Cor Principal Manual',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: colorOptions.map((color) => _buildColorOption(context, color, themeProvider)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, Color color, ThemeProvider themeProvider) {
    final bool isSelected = themeProvider.selectedColor == color;
    return GestureDetector(
      onTap: () => themeProvider.setSelectedColor(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3.0) : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              )
            : null,
      ),
    );
  }
}