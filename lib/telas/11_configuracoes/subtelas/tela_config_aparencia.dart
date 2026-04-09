import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../estilos/cores.dart';
import '../../../estilos/tema.dart';
import '../../../provedores/provedor_tema.dart';

class TelaConfigAparencia extends StatefulWidget {
  const TelaConfigAparencia({super.key});

  @override
  State<TelaConfigAparencia> createState() => _TelaConfigAparenciaState();
}

class _TelaConfigAparenciaState extends State<TelaConfigAparencia> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provedorTema = context.watch<ProvedorTema>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const AppBarPadrao(titulo: 'Aparência'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SecaoTitulo(texto: 'Modo de Exibição'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Automático (Sistema)'),
                  subtitle:
                      const Text('Segue as configurações do seu celular'),
                  value: ThemeMode.system,
                  groupValue: provedorTema.modoTema,
                  onChanged: (v) => provedorTema.alterarModoTema(v!),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Modo Claro'),
                  value: ThemeMode.light,
                  groupValue: provedorTema.modoTema,
                  onChanged: (v) => provedorTema.alterarModoTema(v!),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Modo Escuro'),
                  value: ThemeMode.dark,
                  groupValue: provedorTema.modoTema,
                  onChanged: (v) => provedorTema.alterarModoTema(v!),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(),
          const SizedBox(height: 32),
          _SecaoTitulo(texto: 'Paleta de Cores'),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cor de Destaque',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                      'Esta cor será usada em botões, ícones e destaques.'),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: CoresApp.opcoesTema.map((cor) {
                      final isSelected =
                          provedorTema.corSemente.value == cor.value;
                      return GestureDetector(
                        onTap: () => provedorTema.alterarCorSemente(cor),
                        child: AnimatedContainer(
                          duration: 300.ms,
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: cor,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: theme.colorScheme.onSurface,
                                    width: 3)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: cor.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String texto;
  const _SecaoTitulo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
