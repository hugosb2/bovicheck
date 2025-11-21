import 'package:bovicheck/models/propriedade.dart';
import 'package:bovicheck/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PropriedadeFormView extends StatefulWidget {
  final Propriedade? propriedade;
  const PropriedadeFormView({super.key, this.propriedade});

  @override
  State<PropriedadeFormView> createState() => _PropriedadeFormViewState();
}

class _PropriedadeFormViewState extends State<PropriedadeFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _proprietarioController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;

  bool get _isEditing => widget.propriedade != null;

  @override
  void initState() {
    super.initState();
    final prop = widget.propriedade;
    _nomeController = TextEditingController(text: prop?.nome ?? '');
    _proprietarioController =
        TextEditingController(text: prop?.proprietario ?? '');
    _latitudeController = TextEditingController(text: prop?.latitude ?? '');
    _longitudeController = TextEditingController(text: prop?.longitude ?? '');
    _cidadeController = TextEditingController(text: prop?.cidade ?? '');
    _estadoController = TextEditingController(text: prop?.estado ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _proprietarioController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newOrUpdatedProp = Propriedade(
        id: widget.propriedade?.id ?? const Uuid().v4(),
        nome: _nomeController.text,
        proprietario: _proprietarioController.text,
        latitude: _latitudeController.text,
        longitude: _longitudeController.text,
        cidade: _cidadeController.text,
        estado: _estadoController.text,
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
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
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
                theme.colorScheme.primary.withOpacity(0.8),
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
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                _buildTextField(
                  controller: _proprietarioController,
                  label: 'Nome do Proprietário',
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                _buildSectionTitle(context, 'Localização'),
                _buildTextField(
                  controller: _cidadeController,
                  label: 'Cidade',
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                _buildTextField(
                  controller: _estadoController,
                  label: 'Estado (ex: BA)',
                  maxLength: 2,
                  validator: (v) => v!.isEmpty
                      ? 'Obrigatório'
                      : (v.length != 2 ? 'Use 2 letras' : null),
                ),
                _buildTextField(
                  controller: _latitudeController,
                  label: 'Latitude',
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                _buildTextField(
                  controller: _longitudeController,
                  label: 'Longitude',
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
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
