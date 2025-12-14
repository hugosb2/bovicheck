import 'package:bovicheck/modelos/herd_indicator.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class HerdIndicatorFormView extends StatefulWidget {
  const HerdIndicatorFormView({super.key});

  @override
  State<HerdIndicatorFormView> createState() => _HerdIndicatorFormViewState();
}

class _HerdIndicatorFormViewState extends State<HerdIndicatorFormView> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedIndicator;
  bool _applyToLote = false;
  bool _applyToProperty = false;
  late Future<List<dynamic>> _dataFuture;
  bool _hasProperties = false;

  // Lista de índices disponíveis
  final List<Map<String, String>> _availableIndicators = [
    {'key': 'birthRate', 'title': 'Taxa de Natalidade', 'unit': '%'},
    {
      'key': 'averageCalvingInterval',
      'title': 'Intervalo Partos',
      'unit': ' dias'
    },
    {
      'key': 'averageAgeAtFirstCalving',
      'title': 'Idade 1º Parto',
      'unit': ' meses'
    },
    {'key': 'mortalityRate', 'title': 'Taxa de Mortalidade', 'unit': '%'},
    {
      'key': 'averageAdgBirthToWeaning',
      'title': 'GMD Nasc.-Desmame',
      'unit': ' kg/dia'
    },
    {
      'key': 'averageDailyMilkProduction',
      'title': 'Média de Leite',
      'unit': ' L/dia'
    },
  ];

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<List<dynamic>> _loadData() async {
    final propriedades = await DatabaseService.instance.getAllPropriedades();
    final lotes = await DatabaseService.instance.getAllLotes();
    final hasProps = propriedades.isNotEmpty;
    final hasLotes = lotes.isNotEmpty;
    if (mounted) {
      setState(() {
        _hasProperties = hasProps;
      });
    }
    return [hasProps, hasLotes];
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validação: deve escolher um índice
      if (_selectedIndicator == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione um índice.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Validação: deve escolher pelo menos uma opção de aplicação
      if (!_applyToLote && !_applyToProperty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione pelo menos uma opção de aplicação.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Validação: se escolheu propriedade, deve ter propriedade cadastrada
      if (_applyToProperty && !_hasProperties) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'É necessário cadastrar pelo menos uma propriedade para aplicar índices a propriedades.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Busca os detalhes do índice selecionado
      final indicatorDetails = _availableIndicators.firstWhere(
        (ind) => ind['key'] == _selectedIndicator,
      );

      // Cria e salva o índice
      final newIndicator = HerdIndicator(
        id: const Uuid().v4(),
        indicatorKey: _selectedIndicator!,
        indicatorTitle: indicatorDetails['title']!,
        indicatorUnit: indicatorDetails['unit']!,
        applyToLote: _applyToLote,
        applyToProperty: _applyToProperty,
        createdAt: DateTime.now(),
      );

      await DatabaseService.instance.addOrUpdateHerdIndicator(newIndicator);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Índice adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Índice'),
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
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle(context, 'Seleção do Índice'),
                    if (!_hasProperties)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                theme.colorScheme.error.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: theme.colorScheme.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cadastre pelo menos uma propriedade ou lote para poder adicionar índices.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DropdownButtonFormField<String?>(
                          initialValue: _selectedIndicator,
                          decoration: InputDecoration(
                            labelText: 'Índice *',
                            filled: true,
                            fillColor:
                                theme.colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          items: _availableIndicators.map((indicator) {
                            return DropdownMenuItem<String?>(
                              value: indicator['key'],
                              child: Text(
                                  '${indicator['title']} (${indicator['unit']})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedIndicator = value;
                            });
                          },
                          validator: (v) => v == null ? 'Obrigatório' : null,
                        ),
                      ),
                    _buildSectionTitle(context, 'Onde Aplicar'),
                    CheckboxListTile(
                      title: const Text('Lote'),
                      value: _applyToLote,
                      onChanged: (value) {
                        setState(() {
                          _applyToLote = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Propriedade (como um todo)'),
                      subtitle: !_hasProperties
                          ? const Text(
                              'Cadastre pelo menos uma propriedade primeiro',
                              style: TextStyle(color: Colors.red),
                            )
                          : null,
                      value: _applyToProperty,
                      onChanged: _hasProperties
                          ? (value) {
                              setState(() {
                                _applyToProperty = value ?? false;
                              });
                            }
                          : null,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: !_hasProperties ? null : _saveForm,
                      child: const Text('Adicionar Índice'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
