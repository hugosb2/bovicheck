// lib/views/animal/tabs/breeding_tab.dart

import 'package:bovicheck/controllers/animal_detail_controller.dart';
import 'package:bovicheck/models/animal/reproductive_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class BreedingTab extends StatelessWidget {
  final String animalId;
  const BreedingTab({super.key, required this.animalId});

  void _showRecordOptions(BuildContext context, AnimalDetailController controller, ReproductiveEvent record) {
    showModalBottomSheet(context: context, builder: (ctx) => Wrap(children: [
      ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Editar'), onTap: () {
        Navigator.pop(ctx);
        _showAddBreedingEventDialog(context, controller, recordToEdit: record);
      }),
      ListTile(leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error), title: const Text('Apagar'), onTap: () {
        Navigator.pop(ctx);
        _showDeleteConfirmation(context, controller, record);
      }),
    ]));
  }

  void _showDeleteConfirmation(BuildContext context, AnimalDetailController controller, ReproductiveEvent record) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Confirmar Exclusão'),
      content: const Text('Tem certeza que deseja apagar este evento reprodutivo?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(child: const Text('Apagar'), onPressed: () {
          controller.deleteReproductiveEvent(record.id);
          Navigator.pop(ctx);
        }),
      ],
    ));
  }

  void _showAddBreedingEventDialog(BuildContext context, AnimalDetailController controller, {ReproductiveEvent? recordToEdit}) {
    final isEditing = recordToEdit != null;
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = recordToEdit?.date ?? DateTime.now();
    final dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(selectedDate));
    String eventType = recordToEdit?.eventType ?? 'Cio';
    String result = recordToEdit?.result ?? '';

    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(isEditing ? 'Editar Evento Reprodutivo' : 'Registrar Evento Reprodutivo', style: Theme.of(context).textTheme.titleLarge),
        TextFormField(controller: dateController, decoration: const InputDecoration(labelText: 'Data', suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
          if(picked != null) { selectedDate = picked; dateController.text = DateFormat('dd/MM/yyyy').format(picked); }
        }),
        DropdownButtonFormField<String>(
          value: eventType,
          decoration: const InputDecoration(labelText: 'Tipo de Evento'),
          items: ['Cio', 'Inseminação', 'Diagnóstico de Toque', 'Parto'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => eventType = v!,
        ),
        TextFormField(initialValue: result, decoration: const InputDecoration(labelText: 'Resultado (ex: Positivo, Fêmea)'), onSaved: (v) => result = v ?? ''),
        const SizedBox(height: 24),
        ElevatedButton(child: const Text('Salvar'), onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            final record = ReproductiveEvent(id: recordToEdit?.id ?? const Uuid().v4(), date: selectedDate, eventType: eventType, result: result);
            if(isEditing) {
              controller.updateReproductiveEvent(record);
            } else {
              controller.addReproductiveEvent(record);
            }
            Navigator.pop(ctx);
          }
        }),
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimalDetailController>();
    final breedingHistory = controller.animal?.historicoReprodutivo ?? [];

    return Scaffold(
      body: breedingHistory.isEmpty ? const Center(child: Text('Nenhum evento reprodutivo registrado.')) : ListView.builder(
        itemCount: breedingHistory.length,
        itemBuilder: (context, index) {
          final record = breedingHistory[index];
          return ListTile(
            leading: const Icon(Icons.favorite_border),
            title: Text(record.eventType),
            subtitle: Text('Resultado: ${record.result ?? 'N/A'}\nData: ${DateFormat('dd/MM/yyyy').format(record.date)}'),
            isThreeLine: true,
            onTap: () => _showRecordOptions(context, controller, record),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'breedingTabFab',
        onPressed: () => _showAddBreedingEventDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }
}