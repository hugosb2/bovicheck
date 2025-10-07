// lib/views/animal/tabs/health_tab.dart

import 'package:bovicheck/controllers/animal_detail_controller.dart';
import 'package:bovicheck/models/animal/health_event.dart';
import 'package:bovicheck/models/animal/medication_record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UnifiedHealthItem {
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final dynamic originalRecord;

  UnifiedHealthItem({ required this.date, required this.title, required this.subtitle, required this.icon, required this.originalRecord});
}

class HealthTab extends StatelessWidget {
  // CORRIGIDO: Adicionado o campo e o construtor para receber o ID
  final String animalId;
  const HealthTab({super.key, required this.animalId});

  void _showRecordOptions(BuildContext context, AnimalDetailController controller, UnifiedHealthItem item) {
    showModalBottomSheet(context: context, builder: (ctx) => Wrap(children: [
      ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Editar'), onTap: () {
        Navigator.pop(ctx);
        if (item.originalRecord is HealthEvent) {
          _showAddHealthEventDialog(context, controller, recordToEdit: item.originalRecord);
        } else if (item.originalRecord is MedicationRecord) {
          _showAddMedicationDialog(context, controller, recordToEdit: item.originalRecord);
        }
      }),
      ListTile(leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error), title: const Text('Apagar'), onTap: () {
        Navigator.pop(ctx);
        _showDeleteConfirmation(context, controller, item.originalRecord);
      }),
    ]));
  }

  void _showDeleteConfirmation(BuildContext context, AnimalDetailController controller, dynamic record) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Confirmar Exclusão'),
      content: const Text('Tem certeza que deseja apagar este registro?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(child: const Text('Apagar'), onPressed: () {
          if (record is HealthEvent) controller.deleteHealthEvent(record.id);
          if (record is MedicationRecord) controller.deleteMedicationRecord(record.id);
          Navigator.pop(ctx);
        }),
      ],
    ));
  }

  void _showAddHealthEventDialog(BuildContext context, AnimalDetailController controller, {HealthEvent? recordToEdit}) {
    final isEditing = recordToEdit != null;
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = recordToEdit?.date ?? DateTime.now();
    final dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(selectedDate));
    String diagnosis = recordToEdit?.diagnosis ?? '';
    String treatment = recordToEdit?.treatment ?? '';

    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(isEditing ? 'Editar Evento de Saúde' : 'Registrar Evento de Saúde', style: Theme.of(context).textTheme.titleLarge),
        TextFormField(controller: dateController, decoration: const InputDecoration(labelText: 'Data', suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
            if(picked != null) { selectedDate = picked; dateController.text = DateFormat('dd/MM/yyyy').format(picked); }
        }),
        TextFormField(initialValue: diagnosis, decoration: const InputDecoration(labelText: 'Diagnóstico (ex: Febre, Ferimento)'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null, onSaved: (v) => diagnosis = v!),
        TextFormField(initialValue: treatment, decoration: const InputDecoration(labelText: 'Tratamento (Opcional)'), onSaved: (v) => treatment = v!),
        const SizedBox(height: 24),
        ElevatedButton(child: const Text('Salvar'), onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            final record = HealthEvent(id: recordToEdit?.id ?? const Uuid().v4(), date: selectedDate, diagnosis: diagnosis, treatment: treatment);
            if(isEditing) {
              controller.updateHealthEvent(record);
            } else {
              controller.addHealthEvent(record);
            }
            Navigator.pop(ctx);
          }
        }),
      ])),
    ));
  }

  void _showAddMedicationDialog(BuildContext context, AnimalDetailController controller, {MedicationRecord? recordToEdit}) {
    final isEditing = recordToEdit != null;
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = recordToEdit?.date ?? DateTime.now();
    final dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(selectedDate));
    String productName = recordToEdit?.productName ?? '';
    String type = recordToEdit?.type ?? 'Vacina';
    String dose = recordToEdit?.dose ?? '';

    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(isEditing ? 'Editar Medicação' : 'Registrar Medicação', style: Theme.of(context).textTheme.titleLarge),
        TextFormField(controller: dateController, decoration: const InputDecoration(labelText: 'Data', suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
            if(picked != null) { selectedDate = picked; dateController.text = DateFormat('dd/MM/yyyy').format(picked); }
        }),
        TextFormField(initialValue: productName, decoration: const InputDecoration(labelText: 'Nome do Produto'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null, onSaved: (v) => productName = v!),
        DropdownButtonFormField<String>(
          value: type,
          decoration: const InputDecoration(labelText: 'Tipo'),
          items: ['Vacina', 'Vermífugo', 'Antibiótico', 'Outro'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => type = v!,
        ),
        TextFormField(initialValue: dose, decoration: const InputDecoration(labelText: 'Dose (ex: 10 ml)'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null, onSaved: (v) => dose = v!),
        const SizedBox(height: 24),
        ElevatedButton(child: const Text('Salvar'), onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            final record = MedicationRecord(id: recordToEdit?.id ?? const Uuid().v4(), date: selectedDate, productName: productName, type: type, dose: dose);
            if(isEditing) {
              controller.updateMedicationRecord(record);
            } else {
              controller.addMedicationRecord(record);
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
    final healthEvents = controller.animal?.historicoSaude ?? [];
    final medicationRecords = controller.animal?.historicoMedicacao ?? [];

    final unifiedList = [
      ...healthEvents.map((e) => UnifiedHealthItem(date: e.date, title: e.diagnosis, subtitle: 'Tratamento: ${e.treatment ?? 'N/A'}', icon: Icons.healing_outlined, originalRecord: e)),
      ...medicationRecords.map((e) => UnifiedHealthItem(date: e.date, title: '${e.type}: ${e.productName}', subtitle: 'Dose: ${e.dose}', icon: Icons.vaccines_outlined, originalRecord: e)),
    ];
    unifiedList.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      body: unifiedList.isEmpty ? const Center(child: Text('Nenhum registro de saúde ou medicação.')) : ListView.builder(
        itemCount: unifiedList.length,
        itemBuilder: (context, index) {
          final item = unifiedList[index];
          return ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            subtitle: Text('${item.subtitle}\nData: ${DateFormat('dd/MM/yyyy').format(item.date)}'),
            isThreeLine: true,
            onTap: () => _showRecordOptions(context, controller, item),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'healthTabFab',
        onPressed: () {
          showDialog(context: context, builder: (ctx) => AlertDialog(
            title: const Text('O que você quer registrar?'),
            actions: [
              TextButton(child: const Text('Evento de Saúde'), onPressed: () {
                Navigator.pop(ctx);
                _showAddHealthEventDialog(context, controller);
              }),
              TextButton(child: const Text('Medicação'), onPressed: () {
                Navigator.pop(ctx);
                _showAddMedicationDialog(context, controller);
              }),
            ],
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}