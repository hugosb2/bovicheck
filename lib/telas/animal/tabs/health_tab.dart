import 'package:bovicheck/controladores/animal_detail_controller.dart';
import 'package:bovicheck/modelos/animal/health_event.dart';
import 'package:bovicheck/modelos/animal/medication_record.dart';
import 'package:bovicheck/estilos/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UnifiedHealthItem {
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final dynamic originalRecord;

  UnifiedHealthItem(
      {required this.date,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.originalRecord});
}

class HealthTab extends StatelessWidget {
  final String animalId;
  const HealthTab({super.key, required this.animalId});

  void _showRecordOptions(BuildContext context,
      AnimalDetailController controller, UnifiedHealthItem item) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => Wrap(children: [
              ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (item.originalRecord is HealthEvent) {
                      _showAddHealthEventDialog(context, controller,
                          recordToEdit: item.originalRecord);
                    } else if (item.originalRecord is MedicationRecord) {
                      _showAddMedicationDialog(context, controller,
                          recordToEdit: item.originalRecord);
                    }
                  }),
              ListTile(
                  leading: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  title: const Text('Apagar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDeleteConfirmation(
                        context, controller, item.originalRecord);
                  }),
            ]));
  }

  void _showDeleteConfirmation(
      BuildContext context, AnimalDetailController controller, dynamic record) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content:
                  const Text('Tem certeza que deseja apagar este registro?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                FilledButton(
                    child: const Text('Apagar'),
                    onPressed: () {
                      if (record is HealthEvent) {
                        controller.deleteHealthEvent(record.id);
                      }
                      if (record is MedicationRecord) {
                        controller.deleteMedicationRecord(record.id);
                      }
                      Navigator.pop(ctx);
                    }),
              ],
            ));
  }

  void _showAddHealthEventDialog(
      BuildContext context, AnimalDetailController controller,
      {HealthEvent? recordToEdit}) {
    final isEditing = recordToEdit != null;
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = recordToEdit?.date ?? DateTime.now();
    final dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(selectedDate));
    String diagnosis = recordToEdit?.diagnosis ?? '';
    String treatment = recordToEdit?.treatment ?? '';

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
                            ? 'Editar Evento de Saúde'
                            : 'Registrar Evento de Saúde',
                        style: Theme.of(context).textTheme.titleLarge),
                    TextFormField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Data',
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                        initialValue: diagnosis,
                        decoration: InputDecoration(
                          labelText: 'Diagnóstico (ex: Febre, Ferimento)',
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        onSaved: (v) => diagnosis = v!),
                    const SizedBox(height: 16),
                    TextFormField(
                        initialValue: treatment,
                        decoration: InputDecoration(
                          labelText: 'Tratamento (Opcional)',
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onSaved: (v) => treatment = v!),
                    const SizedBox(height: 24),
                    FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Salvar'),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            final record = HealthEvent(
                                id: recordToEdit?.id ?? const Uuid().v4(),
                                date: selectedDate,
                                diagnosis: diagnosis,
                                treatment: treatment);
                            if (isEditing) {
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

  void _showAddMedicationDialog(
      BuildContext context, AnimalDetailController controller,
      {MedicationRecord? recordToEdit}) {
    final isEditing = recordToEdit != null;
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = recordToEdit?.date ?? DateTime.now();
    final dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(selectedDate));
    String productName = recordToEdit?.productName ?? '';
    String type = recordToEdit?.type ?? 'Vacina';
    String dose = recordToEdit?.dose ?? '';

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 24, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
              child: Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(isEditing ? 'Editar Medicação' : 'Registrar Medicação',
                        style: Theme.of(context).textTheme.titleLarge),
                    TextFormField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Data',
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                        initialValue: productName,
                        decoration: InputDecoration(
                          labelText: 'Nome do Produto',
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        onSaved: (v) => productName = v!),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      items: ['Vacina', 'Vermífugo', 'Antibiótico', 'Outro']
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => type = v!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                        initialValue: dose,
                        decoration: InputDecoration(
                          labelText: 'Dose (ex: 10 ml)',
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                        onSaved: (v) => dose = v!),
                    const SizedBox(height: 24),
                    FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Salvar'),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            final record = MedicationRecord(
                                id: recordToEdit?.id ?? const Uuid().v4(),
                                date: selectedDate,
                                productName: productName,
                                type: type,
                                dose: dose);
                            if (isEditing) {
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
      ...healthEvents.map((e) => UnifiedHealthItem(
          date: e.date,
          title: e.diagnosis,
          subtitle: 'Tratamento: ${e.treatment ?? 'N/A'}',
          icon: Icons.healing_outlined,
          originalRecord: e)),
      ...medicationRecords.map((e) => UnifiedHealthItem(
          date: e.date,
          title: '${e.type}: ${e.productName}',
          subtitle: 'Dose: ${e.dose}',
          icon: Icons.vaccines_outlined,
          originalRecord: e)),
    ];
    unifiedList.sort((a, b) => b.date.compareTo(a.date));

    final theme = Theme.of(context);
    return Scaffold(
      body: unifiedList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.health,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum registro de saúde ou medicação.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: unifiedList.length,
              itemBuilder: (context, index) {
                final item = unifiedList[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (item.icon == Icons.healing_outlined
                                ? Colors.red
                                : Colors.blue)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.icon == Icons.healing_outlined
                            ? Colors.red.shade700
                            : Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.subtitle,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Data: ${DateFormat('dd/MM/yyyy').format(item.date)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onTap: () => _showRecordOptions(context, controller, item),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'healthTabFab',
        onPressed: () {
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('O que você quer registrar?'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.healing_outlined,
                              color: Colors.red),
                          title: const Text('Evento de Saúde'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showAddHealthEventDialog(context, controller);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.medication_outlined,
                              color: Colors.blue),
                          title: const Text('Medicação'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showAddMedicationDialog(context, controller);
                          },
                        ),
                      ],
                    ),
                  ));
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Registro'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
    );
  }
}
