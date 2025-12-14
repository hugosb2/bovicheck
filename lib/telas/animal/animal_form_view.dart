import 'package:bovicheck/modelos/area_pastagem.dart';
import 'package:bovicheck/modelos/lote.dart';
import 'package:bovicheck/estilos/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../modelos/animal/animal.dart';
import '../../servicos/database_service.dart';

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
  late Future<List<AreaPastagem>> _availableAreasPastagemFuture;
  String? _selectedLoteId;
  String? _selectedAreaPastagemId;

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
    _availableAreasPastagemFuture =
        DatabaseService.instance.getAllAreaPastagens();

    if (animal != null) {
      // Editando
      _sexo = animal.sexo;
      _dataNascimento = animal.dataNascimento;
      _dataNascimentoController.text =
          DateFormat('dd/MM/yyyy').format(_dataNascimento!);
      _status = animal.status;
      _dataSaida = animal.dataSaida;
      _isDesmamado = animal.isDesmamado;
      _dataDesmame = animal.dataDesmame;
      _selectedLoteId = animal.loteId;
      // Buscar área de pastagem que contém este animal
      _availableAreasPastagemFuture.then((areas) {
        for (var area in areas) {
          if (area.animaisIds.contains(animal.id)) {
            setState(() {
              _selectedAreaPastagemId = area.id;
            });
            break;
          }
        }
      });
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

      // Verifica se o brinco já existe (exceto o animal atual se estiver editando)
      final brincoExists = await DatabaseService.instance.brincoExists(
        _brincoController.text.trim(),
        excludeAnimalId: widget.animal?.id,
      );

      if (brincoExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Este brinco já está cadastrado. Use um brinco diferente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final newOrUpdatedAnimal = Animal(
        dbId: widget.animal?.dbId ?? const Uuid().v4(),
        brinco: _brincoController.text.trim(),
        nome: _nomeController.text.isNotEmpty ? _nomeController.text : null,
        dataNascimento: _dataNascimento!,
        sexo: _sexo,
        raca: _racaController.text.isNotEmpty ? _racaController.text : null,
        loteId: _selectedLoteId, // Opcional agora
        status: _status,
        dataSaida: _status != AnimalStatus.ativo ? _dataSaida : null,
        motivoSaida:
            _status != AnimalStatus.ativo ? _motivoSaidaController.text : null,
        isDesmamado: _isDesmamado,
        dataDesmame: _isDesmamado ? _dataDesmame : null,
      );

      try {
        await DatabaseService.instance.addOrUpdateAnimal(newOrUpdatedAnimal);

        // Se uma área de pastagem foi selecionada, adicionar o animal à área
        if (_selectedAreaPastagemId != null) {
          final areas = await _availableAreasPastagemFuture;
          final area = areas.firstWhere((a) => a.id == _selectedAreaPastagemId);
          if (!area.animaisIds.contains(newOrUpdatedAnimal.id)) {
            area.animaisIds = [...area.animaisIds, newOrUpdatedAnimal.id];
            await DatabaseService.instance.addOrUpdateAreaPastagem(area);
          }
        } else if (widget.animal != null) {
          // Se estava em uma área e foi removido, remover da área
          final areas = await _availableAreasPastagemFuture;
          for (var area in areas) {
            if (area.animaisIds.contains(widget.animal!.id)) {
              area.animaisIds = area.animaisIds
                  .where((id) => id != widget.animal!.id)
                  .toList();
              await DatabaseService.instance.addOrUpdateAreaPastagem(area);
            }
          }
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          counterText: maxLength != null ? null : "",
          suffixIcon: suffixIcon,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<T>(
        initialValue: value,
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

  // Lista de raças comuns de gado bovino
  static const List<String> _racasComuns = [
    'Nelore',
    'Angus',
    'Brahman',
    'Hereford',
    'Simmental',
    'Limousin',
    'Charolais',
    'Canchim',
    'Tabapuã',
    'Guzerá',
    'Gir',
    'Girolando',
    'Holandesa',
    'Jersey',
    'Pardo Suíço',
    'Simental',
    'Brangus',
    'Senepol',
    'Caracu',
    'Mocho Nacional',
    'Crioula',
    'Indubrasil',
    'Maine Anjou',
    'Red Angus',
    'Santa Gertrudis',
    'Sindi',
    'Guzolando',
    'Nelore Mocho',
  ];

  Widget _buildRacaAutocomplete() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Autocomplete<String>(
        initialValue: TextEditingValue(text: _racaController.text),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return _racasComuns;
          }
          return _racasComuns.where((raca) =>
              raca.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        },
        onSelected: (String selection) {
          _racaController.text = selection;
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted,
        ) {
          // Sincroniza o controller do autocomplete com o controller do formulário na inicialização
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (fieldTextEditingController.text != _racaController.text) {
              fieldTextEditingController.text = _racaController.text;
            }
          });

          // Atualiza o controller do formulário quando o texto muda
          fieldTextEditingController.addListener(() {
            if (_racaController.text != fieldTextEditingController.text) {
              _racaController.text = fieldTextEditingController.text;
            }
          });

          return TextFormField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              labelText: 'Raça (Opcional)',
              hintText: 'Digite ou selecione uma raça',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
            onFieldSubmitted: (String value) {
              onFieldSubmitted();
            },
          );
        },
        optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
        ) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(12.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          option,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Animal' : 'Novo Animal'),
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
                _buildRacaAutocomplete(),
                _buildSectionTitle(context, 'Localização'),
                FutureBuilder<List<AreaPastagem>>(
                  future: _availableAreasPastagemFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: LinearProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Erro ao carregar áreas: ${snapshot.error}');
                    } else {
                      final areas = snapshot.data ?? [];
                      return _buildDropdownField<String?>(
                        label: 'Área de Pastagem (Opcional)',
                        value: _selectedAreaPastagemId,
                        items: [
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('Nenhuma')),
                          ...areas.map((area) => DropdownMenuItem(
                                value: area.id,
                                child: Text(area.nome),
                              )),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedAreaPastagemId = v),
                        validator: (v) => null,
                      );
                    }
                  },
                ),
                FutureBuilder<List<Lote>>(
                  future: _availableLotesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: LinearProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Erro ao carregar lotes: ${snapshot.error}');
                    } else {
                      final lotes = snapshot.data ?? [];
                      return _buildDropdownField<String?>(
                        label: 'Lote (Opcional)',
                        value: _selectedLoteId,
                        items: [
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('Nenhum')),
                          ...lotes.map((lote) => DropdownMenuItem(
                                value: lote.id,
                                child: Text(lote.nome),
                              )),
                        ],
                        onChanged: (v) => setState(() => _selectedLoteId = v),
                        validator: (v) => null,
                      );
                    }
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
                      activeThumbColor: Theme.of(context).colorScheme.primary,
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
