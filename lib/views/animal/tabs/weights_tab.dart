import 'package:bovicheck/controllers/animal_detail_controller.dart';
import 'package:bovicheck/models/animal/weight_record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class WeightsTab extends StatelessWidget {
  final String animalId;
  const WeightsTab({super.key, required this.animalId});

  void _showRecordOptions(BuildContext context,
      AnimalDetailController controller, WeightRecord record) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => Wrap(children: [
              ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddWeightDialog(context, controller,
                        recordToEdit: record);
                  }),
              ListTile(
                  leading: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  title: const Text('Apagar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDeleteConfirmation(context, controller, record);
                  }),
            ]));
  }

  void _showDeleteConfirmation(BuildContext context,
      AnimalDetailController controller, WeightRecord record) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: const Text(
                  'Tem certeza que deseja apagar este registro de peso?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                FilledButton(
                    child: const Text('Apagar'),
                    onPressed: () {
                      controller.deleteWeightRecord(record.id);
                      Navigator.pop(ctx);
                    }),
              ],
            ));
  }

  void _showAddWeightDialog(
      BuildContext context, AnimalDetailController controller,
      {WeightRecord? recordToEdit}) {
    final isEditing = recordToEdit != null;
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = recordToEdit?.date ?? DateTime.now();
    final dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(selectedDate));
    double? weight = recordToEdit?.weight;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 24, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
              child: Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                        isEditing ? 'Editar Pesagem' : 'Adicionar Nova Pesagem',
                        style: Theme.of(context).textTheme.titleLarge),
                    TextFormField(
                        controller: dateController,
                        decoration: const InputDecoration(
                            labelText: 'Data',
                            suffixIcon: Icon(Icons.calendar_today)),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now());
                          if (picked != null) {
                            selectedDate = picked;
                            dateController.text =
                                DateFormat('dd/MM/yyyy').format(picked);
                          }
                        }),
                    TextFormField(
                        initialValue: weight?.toString(),
                        decoration:
                            const InputDecoration(labelText: 'Peso (kg)'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        onSaved: (v) => weight = double.tryParse(v!)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                        child: const Text('Salvar'),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            final record = WeightRecord(
                                id: recordToEdit?.id ?? const Uuid().v4(),
                                date: selectedDate,
                                weight: weight!);
                            if (isEditing) {
                              controller.updateWeightRecord(record);
                            } else {
                              controller.addWeightRecord(record);
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
    final weightHistory = controller.animal?.historicoPeso ?? [];

    return Scaffold(
      body: weightHistory.isEmpty
          ? const Center(child: Text('Nenhum registro de peso encontrado.'))
          : ListView.builder(
              itemCount: weightHistory.length,
              itemBuilder: (context, index) {
                final record = weightHistory[index];
                return ListTile(
                  leading: const Icon(Icons.scale_outlined),
                  title: Text('${record.weight.toStringAsFixed(2)} kg'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(record.date)),
                  onTap: () => _showRecordOptions(context, controller, record),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'weightsTabFab',
        onPressed: () => _showAddWeightDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }
}
