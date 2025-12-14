import 'package:bovicheck/modelos/propriedade.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TelaFormularioPropriedade extends StatefulWidget {
  final Propriedade? propriedade;
  const TelaFormularioPropriedade({super.key, this.propriedade});

  @override
  State<TelaFormularioPropriedade> createState() =>
      _TelaFormularioPropriedadeState();
}

class _TelaFormularioPropriedadeState extends State<TelaFormularioPropriedade> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _proprietarioController;
  late TextEditingController _municipioController;
  late TextEditingController _areaTotalController;
  String? _selectedEstado;

  static const List<String> _estados = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO'
  ];

  bool get _isEditing => widget.propriedade != null;

  @override
  void initState() {
    super.initState();
    final prop = widget.propriedade;
    _nomeController = TextEditingController(text: prop?.nome ?? '');
    _proprietarioController =
        TextEditingController(text: prop?.proprietario ?? '');
    _municipioController = TextEditingController(text: prop?.municipio ?? '');
    _areaTotalController = TextEditingController(
        text:
            prop?.areaTotal != null ? prop!.areaTotal.toStringAsFixed(2) : '');
    _selectedEstado = prop?.estado.isNotEmpty == true ? prop!.estado : null;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _proprietarioController.dispose();
    _municipioController.dispose();
    _areaTotalController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final areaTotal =
          double.tryParse(_areaTotalController.text.replaceAll(',', '.')) ??
              0.0;

      final newOrUpdatedProp = Propriedade(
        dbId: widget.propriedade?.dbId ?? const Uuid().v4(),
        identificador: widget.propriedade?.identificador ?? const Uuid().v4(),
        nome: _nomeController.text.trim(),
        proprietario: _proprietarioController.text.trim(),
        municipio: _municipioController.text.trim(),
        estado: _selectedEstado ?? '',
        areaTotal: areaTotal,
      );

      await DatabaseService.instance.addOrUpdatePropriedade(newOrUpdatedProp);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
          counterText: maxLength != null ? null : "",
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLength: maxLength,
      ),
    );
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

  Widget _buildEstadoDropdown() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedEstado,
        decoration: InputDecoration(
          labelText: 'Estado',
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
        items: _estados.map((estado) {
          return DropdownMenuItem<String>(
            value: estado,
            child: Text(estado),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedEstado = value;
          });
        },
        validator: (value) => value == null ? 'Obrigatório' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Propriedade' : 'Nova Propriedade'),
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
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle(context, 'Dados da Propriedade'),
                _buildTextField(
                  controller: _nomeController,
                  label: 'Nome da Propriedade',
                  validator: (v) => v!.trim().isEmpty ? 'Obrigatório' : null,
                ),
                _buildTextField(
                  controller: _proprietarioController,
                  label: 'Nome do Proprietário',
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                _buildSectionTitle(context, 'Localização'),
                _buildTextField(
                  controller: _municipioController,
                  label: 'Município',
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                _buildEstadoDropdown(),
                _buildSectionTitle(context, 'Área'),
                _buildTextField(
                  controller: _areaTotalController,
                  label: 'Área Total (hectares)',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Obrigatório';
                    }
                    final area = double.tryParse(v.replaceAll(',', '.'));
                    if (area == null || area < 0) {
                      return 'Digite um valor válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: _saveForm,
                  child: const Text('Salvar Propriedade'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PropriedadeFormView extends TelaFormularioPropriedade {
  const PropriedadeFormView({super.key, super.propriedade}) : super();
}
