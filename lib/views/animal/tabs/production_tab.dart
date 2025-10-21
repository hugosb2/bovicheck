import 'package:bovicheck/controllers/animal_detail_controller.dart';
import 'package:bovicheck/models/animal/milk_record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ProductionTab extends StatelessWidget {
  final String animalId;
  const ProductionTab({super.key, required this.animalId});

  void _showRecordOptions(BuildContext context,
      AnimalDetailController controller, MilkRecord record) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => Wrap(children: [
              ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddMilkRecordDialog(context, controller,
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
      AnimalDetailController controller, MilkRecord record) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: const Text(
                  'Tem certeza que deseja apagar este registro de produção?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                FilledButton(
                    child: const Text('Apagar'),
                    onPressed: () {
                      controller.deleteMilkRecord(record.id);
                      Navigator.pop(ctx);
                    }),
              ],
            ));
  }

  void _showAddMilkRecordDialog(
      BuildContext context, AnimalDetailController controller,
      {MilkRecord? recordToEdit}) {
    final isEditing = recordToEdit != null;
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = recordToEdit?.date ?? DateTime.now();
    final dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(selectedDate));
    double? morningProd = recordToEdit?.morningProduction;
    double? afternoonProd = recordToEdit?.afternoonProduction;

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
                        isEditing
                            ? 'Editar Registro de Leite'
                            : 'Adicionar Registro de Leite',
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
                        initialValue: morningProd?.toString(),
                        decoration: const InputDecoration(
                            labelText: 'Produção da Manhã (L)'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        onSaved: (v) => morningProd = double.tryParse(v!)),
                    TextFormField(
                        initialValue: afternoonProd?.toString(),
                        decoration: const InputDecoration(
                            labelText: 'Produção da Tarde (L)'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        onSaved: (v) => afternoonProd = double.tryParse(v!)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                        child: const Text('Salvar'),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            final record = MilkRecord(
                                id: recordToEdit?.id ?? const Uuid().v4(),
                                date: selectedDate,
                                morningProduction: morningProd!,
                                afternoonProduction: afternoonProd!);
                            if (isEditing) {
                              controller.updateMilkRecord(record);
                            } else {
                              controller.addMilkRecord(record);
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
    final productionHistory = controller.animal?.historicoLeite ?? [];

    return Scaffold(
      body: productionHistory.isEmpty
          ? const Center(child: Text('Nenhum registro de produção encontrado.'))
          : ListView.builder(
              itemCount: productionHistory.length,
              itemBuilder: (context, index) {
                final record = productionHistory[index];
                return ListTile(
                  leading: const Icon(Icons.opacity_outlined),
                  title: Text(
                      'Total: ${record.totalProduction.toStringAsFixed(2)} Litros'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(record.date)),
                  trailing: Text(
                      'Manhã: ${record.morningProduction} L\nTarde: ${record.afternoonProduction} L'),
                  onTap: () => _showRecordOptions(context, controller, record),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'productionTabFab',
        onPressed: () => _showAddMilkRecordDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }
}
