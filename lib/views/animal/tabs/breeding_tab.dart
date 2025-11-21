import 'package:bovicheck/controllers/animal_detail_controller.dart';
import 'package:bovicheck/models/animal/reproductive_event.dart';
import 'package:bovicheck/styles/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class BreedingTab extends StatelessWidget {
  final String animalId;
  const BreedingTab({super.key, required this.animalId});

  void _showRecordOptions(BuildContext context,
      AnimalDetailController controller, ReproductiveEvent record) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => Wrap(children: [
              ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddBreedingEventDialog(context, controller,
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
      AnimalDetailController controller, ReproductiveEvent record) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: const Text(
                  'Tem certeza que deseja apagar este evento reprodutivo?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                FilledButton(
                    child: const Text('Apagar'),
                    onPressed: () {
                      controller.deleteReproductiveEvent(record.id);
                      Navigator.pop(ctx);
                    }),
              ],
            ));
  }

  void _showAddBreedingEventDialog(
      BuildContext context, AnimalDetailController controller,
      {ReproductiveEvent? recordToEdit}) {
    final isEditing = recordToEdit != null;
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = recordToEdit?.date ?? DateTime.now();
    final dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(selectedDate));
    String eventType = recordToEdit?.eventType ?? 'Cio';
    String result = recordToEdit?.result ?? '';

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
                            ? 'Editar Evento Reprodutivo'
                            : 'Registrar Evento Reprodutivo',
                        style: Theme.of(context).textTheme.titleLarge),
                    TextFormField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: 'Data',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
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
                    DropdownButtonFormField<String>(
                      value: eventType,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Evento',
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
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
                      items: [
                        'Cio',
                        'Inseminação',
                        'Diagnóstico de Toque',
                        'Parto'
                      ]
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => eventType = v!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                        initialValue: result,
                        decoration: InputDecoration(
                          labelText: 'Resultado (ex: Positivo, Fêmea)',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
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
                        onSaved: (v) => result = v ?? ''),
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
                            final record = ReproductiveEvent(
                                id: recordToEdit?.id ?? const Uuid().v4(),
                                date: selectedDate,
                                eventType: eventType,
                                result: result);
                            if (isEditing) {
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
    final theme = Theme.of(context);

    return Scaffold(
      body: breedingHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.breeding,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum evento reprodutivo registrado.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: breedingHistory.length,
              itemBuilder: (context, index) {
                final record = breedingHistory[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppIcons.breeding,
                        color: Colors.pink.shade700,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      record.eventType,
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
                            'Resultado: ${record.result ?? 'N/A'}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Data: ${DateFormat('dd/MM/yyyy').format(record.date)}',
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
                    onTap: () => _showRecordOptions(context, controller, record),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'breedingTabFab',
        onPressed: () => _showAddBreedingEventDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Novo Evento'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
    );
  }
}
