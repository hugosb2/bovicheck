import 'package:bovicheck/models/lote.dart';
import 'package:bovicheck/styles/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/animal/animal.dart';
import '../../services/database_service.dart';

class AnimalFormView extends StatefulWidget {
  final Animal? animal;
  const AnimalFormView({super.key, this.animal});

  @override
  State<AnimalFormView> createState() => _AnimalFormViewState();
}

class _AnimalFormViewState extends State<AnimalFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brincoController;
  late TextEditingController _nomeController;
  late TextEditingController _dataNascimentoController;
  late TextEditingController _racaController;
  late TextEditingController _motivoSaidaController;
  late TextEditingController _dataSaidaController;
  late TextEditingController _dataDesmameController;

  String _sexo = 'Fêmea';
  DateTime? _dataNascimento;
  AnimalStatus _status = AnimalStatus.ativo;
  DateTime? _dataSaida;
  bool _isDesmamado = false;
  DateTime? _dataDesmame;

  late Future<List<Lote>> _availableLotesFuture;
  String? _selectedLoteId;

  bool get _isEditing => widget.animal != null;

  @override
  void initState() {
    super.initState();
    final animal = widget.animal;
    _brincoController = TextEditingController(text: animal?.brinco ?? '');
    _nomeController = TextEditingController(text: animal?.nome ?? '');
    _racaController = TextEditingController(text: animal?.raca ?? '');
    _dataNascimentoController = TextEditingController();

    _availableLotesFuture = DatabaseService.instance.getAllLotes();

    if (animal != null) {
      _sexo = animal.sexo;
      _dataNascimento = animal.dataNascimento;
      _dataNascimentoController.text =
          DateFormat('dd/MM/yyyy').format(_dataNascimento!);
      _status = animal.status;
      _dataSaida = animal.dataSaida;
      _isDesmamado = animal.isDesmamado;
      _dataDesmame = animal.dataDesmame;
      _selectedLoteId = animal.loteId;
    }

    _motivoSaidaController =
        TextEditingController(text: animal?.motivoSaida ?? '');
    _dataSaidaController = TextEditingController(
        text: _dataSaida != null
            ? DateFormat('dd/MM/yyyy').format(_dataSaida!)
            : '');
    _dataDesmameController = TextEditingController(
        text: _dataDesmame != null
            ? DateFormat('dd/MM/yyyy').format(_dataDesmame!)
            : '');
  }

  @override
  void dispose() {
    _brincoController.dispose();
    _nomeController.dispose();
    _dataNascimentoController.dispose();
    _racaController.dispose();
    _motivoSaidaController.dispose();
    _dataSaidaController.dispose();
    _dataDesmameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context,
      {required String field}) async {
    DateTime initialDate;
    if (field == 'nascimento') {
      initialDate = _dataNascimento ?? DateTime.now();
    } else if (field == 'saida') {
      initialDate = _dataSaida ?? DateTime.now();
    } else {
      initialDate = _dataDesmame ?? DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
        if (field == 'nascimento') {
          _dataNascimento = picked;
          _dataNascimentoController.text = formattedDate;
        } else if (field == 'saida') {
          _dataSaida = picked;
          _dataSaidaController.text = formattedDate;
        } else {
          _dataDesmame = picked;
          _dataDesmameController.text = formattedDate;
        }
      });
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newOrUpdatedAnimal = Animal(
        id: widget.animal?.id ?? const Uuid().v4(),
        brinco: _brincoController.text,
        nome: _nomeController.text.isNotEmpty ? _nomeController.text : null,
        dataNascimento: _dataNascimento!,
        sexo: _sexo,
        raca: _racaController.text.isNotEmpty ? _racaController.text : null,
        loteId: _selectedLoteId,
        status: _status,
        dataSaida: _status != AnimalStatus.ativo ? _dataSaida : null,
        motivoSaida:
            _status != AnimalStatus.ativo ? _motivoSaidaController.text : null,
        isDesmamado: _isDesmamado,
        dataDesmame: _isDesmamado ? _dataDesmame : null,
      );

      await DatabaseService.instance.addOrUpdateAnimal(newOrUpdatedAnimal);
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
    int? maxLength,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          counterText: maxLength != null ? null : "",
          suffixIcon: suffixIcon,
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLength: maxLength,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    required String? Function(T?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Animal' : 'Novo Animal'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle(context, 'Dados Básicos'),
                _buildTextField(
                  controller: _brincoController,
                  label: 'Brinco / Identificador',
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                _buildTextField(
                  controller: _nomeController,
                  label: 'Nome (Opcional)',
                ),
                _buildTextField(
                  controller: _dataNascimentoController,
                  label: 'Data de Nascimento',
                  readOnly: true,
                  onTap: () => _selectDate(context, field: 'nascimento'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                  suffixIcon: const Icon(AppIcons.dateRange),
                ),
                _buildDropdownField<String>(
                  label: 'Sexo',
                  value: _sexo,
                  items: ['Fêmea', 'Macho']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _sexo = v!),
                  validator: (v) => v == null ? 'Obrigatório' : null,
                ),
                _buildTextField(
                  controller: _racaController,
                  label: 'Raça (Opcional)',
                ),
                FutureBuilder<List<Lote>>(
                  future: _availableLotesFuture,
                  builder: (context, snapshot) {
                    Widget child;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      child = const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: LinearProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      child = Text('Erro ao carregar lotes: ${snapshot.error}');
                    } else {
                      final lotes = snapshot.data ?? [];
                      child = _buildDropdownField<String?>(
                        label: 'Lote (Opcional)',
                        value: _selectedLoteId,
                        items: [
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('Nenhum')),
                          ...lotes.map((lote) => DropdownMenuItem(
                              value: lote.id, child: Text(lote.nome))),
                        ],
                        onChanged: (v) => setState(() => _selectedLoteId = v),
                        validator: null,
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: child,
                    );
                  },
                ),
                if (_isEditing) ...[
                  _buildSectionTitle(context, 'Status e Eventos'),
                  _buildDropdownField<AnimalStatus>(
                    label: 'Status do Animal',
                    value: _status,
                    items: AnimalStatus.values
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v!),
                    validator: (v) => v == null ? 'Obrigatório' : null,
                  ),
                  if (_status != AnimalStatus.ativo) ...[
                    _buildTextField(
                      controller: _motivoSaidaController,
                      label: 'Motivo da Saída (${_status.name})',
                      validator: (v) =>
                          v!.isEmpty ? 'Motivo obrigatório' : null,
                    ),
                    _buildTextField(
                      controller: _dataSaidaController,
                      label: 'Data da Saída',
                      readOnly: true,
                      onTap: () => _selectDate(context, field: 'saida'),
                      validator: (v) => v!.isEmpty ? 'Data obrigatória' : null,
                      suffixIcon: const Icon(AppIcons.dateRange),
                    ),
                  ],
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: SwitchListTile(
                      title: const Text('Animal desmamado?'),
                      value: _isDesmamado,
                      onChanged: (v) => setState(() => _isDesmamado = v),
                      contentPadding: EdgeInsets.zero,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (_isDesmamado)
                    _buildTextField(
                      controller: _dataDesmameController,
                      label: 'Data do Desmame',
                      readOnly: true,
                      onTap: () => _selectDate(context, field: 'desmame'),
                      validator: (v) =>
                          v!.isEmpty ? 'Data obrigatória se desmamado' : null,
                      suffixIcon: const Icon(AppIcons.dateRange),
                    ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: _saveForm,
                  child: Text(
                      _isEditing ? 'Salvar Alterações' : 'Adicionar Animal'),
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
