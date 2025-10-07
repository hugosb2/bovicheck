// lib/views/animal/animal_form_view.dart

import 'package:bovicheck/models/lote.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// CORRIGIDO: O ponto foi trocado por dois pontos no import.
import 'package:uuid/uuid.dart';
import '../../models/animal/animal.dart';
import '../../services/json_storage_service.dart';

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
  
  List<Lote> _availableLotes = [];
  String? _selectedLoteId;

  @override
  void initState() {
    super.initState();
    final animal = widget.animal;
    _brincoController = TextEditingController(text: animal?.brinco ?? '');
    _nomeController = TextEditingController(text: animal?.nome ?? '');
    _racaController = TextEditingController(text: animal?.raca ?? '');
    _dataNascimentoController = TextEditingController();

    _availableLotes = JsonStorageService.instance.getAllLotes();

    if (animal != null) {
      _sexo = animal.sexo;
      _dataNascimento = animal.dataNascimento;
      _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(_dataNascimento!);
      _status = animal.status;
      _dataSaida = animal.dataSaida;
      _isDesmamado = animal.isDesmamado;
      _dataDesmame = animal.dataDesmame;
      _selectedLoteId = animal.loteId;
    }

    _motivoSaidaController = TextEditingController(text: animal?.motivoSaida ?? '');
    _dataSaidaController = TextEditingController(text: _dataSaida != null ? DateFormat('dd/MM/yyyy').format(_dataSaida!) : '');
    _dataDesmameController = TextEditingController(text: _dataDesmame != null ? DateFormat('dd/MM/yyyy').format(_dataDesmame!) : '');
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

  Future<void> _selectDate(BuildContext context, {required String field}) async {
    DateTime initialDate;
    // CORRIGIDO: Adicionadas chaves {} para seguir as regras do linter.
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
        motivoSaida: _status != AnimalStatus.ativo ? _motivoSaidaController.text : null,
        isDesmamado: _isDesmamado,
        dataDesmame: _isDesmamado ? _dataDesmame : null,
        historicoPeso: widget.animal?.historicoPeso ?? [],
        historicoMedicacao: widget.animal?.historicoMedicacao ?? [],
        historicoSaude: widget.animal?.historicoSaude ?? [],
        historicoReprodutivo: widget.animal?.historicoReprodutivo ?? [],
        historicoLeite: widget.animal?.historicoLeite ?? [],
      );

      await JsonStorageService.instance.addOrUpdateAnimal(newOrUpdatedAnimal);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animal == null ? 'Novo Animal' : 'Editar Animal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Dados Básicos', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(controller: _brincoController, decoration: const InputDecoration(labelText: 'Brinco / Identificador'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome (Opcional)')),
              TextFormField(controller: _dataNascimentoController, decoration: const InputDecoration(labelText: 'Data de Nascimento', suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () => _selectDate(context, field: 'nascimento'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              DropdownButtonFormField<String>(initialValue: _sexo, decoration: const InputDecoration(labelText: 'Sexo'), items: ['Fêmea', 'Macho'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _sexo = v!)),
              TextFormField(controller: _racaController, decoration: const InputDecoration(labelText: 'Raça (Opcional)')),
              DropdownButtonFormField<String?>(
                initialValue: _selectedLoteId,
                decoration: const InputDecoration(labelText: 'Lote (Opcional)'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('Nenhum')),
                  ..._availableLotes.map((lote) => DropdownMenuItem(value: lote.id, child: Text(lote.nome))),
                ],
                onChanged: (v) => setState(() => _selectedLoteId = v),
              ),
              
              if (widget.animal != null) ...[
                const Divider(height: 40),
                Text('Status e Eventos', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                DropdownButtonFormField<AnimalStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status do Animal'),
                  items: AnimalStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
                if (_status != AnimalStatus.ativo) ...[
                  TextFormField(controller: _motivoSaidaController, decoration: InputDecoration(labelText: 'Motivo da Saída (${_status.name})')),
                  TextFormField(controller: _dataSaidaController, decoration: const InputDecoration(labelText: 'Data da Saída', suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () => _selectDate(context, field: 'saida')),
                ],
                SwitchListTile(
                  title: const Text('Animal desmamado?'),
                  value: _isDesmamado,
                  onChanged: (v) => setState(() => _isDesmamado = v),
                ),
                if (_isDesmamado)
                  TextFormField(controller: _dataDesmameController, decoration: const InputDecoration(labelText: 'Data do Desmame', suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () => _selectDate(context, field: 'desmame')),
              ],
              
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saveForm, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}