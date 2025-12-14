import 'package:bovicheck/modelos/lote.dart';
import 'package:bovicheck/modelos/propriedade.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class LoteFormView extends StatefulWidget {
  final Lote? lote;
  const LoteFormView({super.key, this.lote});

  @override
  State<LoteFormView> createState() => _LoteFormViewState();
}

class _LoteFormViewState extends State<LoteFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  String? _selectedPropriedadeId;
  List<Propriedade> _propriedades = [];
  late Future<List<Propriedade>> _propriedadesFuture;

  bool get _isEditing => widget.lote != null;

  @override
  void initState() {
    super.initState();
    final lote = widget.lote;
    _nomeController = TextEditingController(text: lote?.nome ?? '');
    _descricaoController = TextEditingController(text: lote?.descricao ?? '');
    _propriedadesFuture = DatabaseService.instance.getAllPropriedades();
    _loadPropriedades().then((_) {
      // If editing, select the propriedade that this lote belongs to
      if (lote != null && _propriedades.isNotEmpty) {
        final matchingProp = _propriedades.firstWhere(
          (p) => p.id == lote.propriedadeId,
          orElse: () => _propriedades.first,
        );
        if (mounted) {
          setState(() {
            _selectedPropriedadeId = matchingProp.id;
          });
        }
      } else if (_propriedades.isNotEmpty) {
        setState(() {
          _selectedPropriedadeId = _propriedades.first.id;
        });
      }
    });
  }

  Future<void> _loadPropriedades() async {
    final props = await _propriedadesFuture;
    if (mounted) {
      setState(() {
        _propriedades = props;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_selectedPropriedadeId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione uma propriedade'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final newOrUpdatedLote = Lote(
        dbId: widget.lote?.dbId ?? const Uuid().v4(),
        identificador: widget.lote?.identificador ?? const Uuid().v4(),
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim().isNotEmpty
            ? _descricaoController.text.trim()
            : null,
        propriedadeId: _selectedPropriedadeId!,
      );

      await DatabaseService.instance.addOrUpdateLote(newOrUpdatedLote);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines,
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
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
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
        title: Text(_isEditing ? 'Editar Lote' : 'Novo Lote'),
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
                _buildSectionTitle(context, 'Vínculo com Propriedade'),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String?>(
                    initialValue: _selectedPropriedadeId,
                    decoration: InputDecoration(
                      labelText: 'Propriedade *',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
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
                    items: _propriedades.map((prop) {
                      return DropdownMenuItem<String?>(
                        value: prop.id,
                        child: Text(prop.nome),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPropriedadeId = value;
                      });
                    },
                    validator: (v) => v == null ? 'Obrigatório' : null,
                  ),
                ),
                _buildSectionTitle(context, 'Dados do Lote'),
                _buildTextField(
                  controller: _nomeController,
                  label: 'Nome do Lote',
                  validator: (v) => v!.trim().isEmpty ? 'Obrigatório' : null,
                ),
                _buildTextField(
                  controller: _descricaoController,
                  label: 'Descrição (Opcional)',
                  maxLines: 3,
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
                  child:
                      Text(_isEditing ? 'Salvar Alterações' : 'Adicionar Lote'),
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
