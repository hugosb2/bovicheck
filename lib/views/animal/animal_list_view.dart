import 'package:bovicheck/controllers/animal_list_controller.dart';
import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/models/lote.dart';
import 'package:bovicheck/services/database_service.dart';
import 'package:bovicheck/views/animal/animal_detail_view.dart';
import 'package:bovicheck/views/animal/animal_form_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimalListView extends StatefulWidget {
  const AnimalListView({super.key});
  @override
  State<AnimalListView> createState() => _AnimalListViewState();
}

class _AnimalListViewState extends State<AnimalListView> {
  String? _selectedLoteId;
  late Future<List<Lote>> _lotesFuture;

  @override
  void initState() {
    super.initState();
    _lotesFuture = DatabaseService.instance.getAllLotes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) => AnimalListController(),
      child: Consumer<AnimalListController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Meu Rebanho'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por brinco ou nome...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                    ),
                    onChanged: (value) => controller.search(value),
                  ),
                ),
                FutureBuilder<List<Lote>>(
                  future: _lotesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(height: 50);
                    }
                    final lotes = snapshot.data ?? [];
                    if (lotes.isEmpty) return const SizedBox.shrink();

                    return SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: lotes.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ChoiceChip(
                              label: const Text('Todos'),
                              selected: _selectedLoteId == null,
                              onSelected: (selected) {
                                setState(() => _selectedLoteId = null);
                                controller.filterByLote(null);
                              },
                              showCheckmark: false,
                            );
                          }
                          final lote = lotes[index - 1];
                          return ChoiceChip(
                            label: Text(lote.nome),
                            selected: _selectedLoteId == lote.id,
                            onSelected: (selected) {
                              final newLoteId = selected ? lote.id : null;
                              setState(() => _selectedLoteId = newLoteId);
                              controller.filterByLote(newLoteId);
                            },
                            showCheckmark: false,
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.filteredAnimals.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum animal encontrado.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.outline),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: controller.filteredAnimals.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final animal =
                                    controller.filteredAnimals[index];
                                final age = DateTime.now()
                                    .difference(animal.dataNascimento)
                                    .inDays;
                                final ageString = (age / 365).floor() > 0
                                    ? '${(age / 365).floor()} a'
                                    : '${(age / 30).floor()} m';

                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    side: BorderSide(
                                        color: theme.colorScheme.outlineVariant
                                            .withAlpha(100)),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      foregroundColor:
                                          theme.colorScheme.onPrimaryContainer,
                                      child: const Icon(Icons.pets, size: 20),
                                    ),
                                    title: Text(
                                      'Brinco: ${animal.brinco}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${animal.nome ?? 'Sem nome'} • ${animal.sexo} • $ageString',
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            animal.status == AnimalStatus.ativo
                                                ? Colors.green.shade100
                                                : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        animal.status.name,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: animal.status ==
                                                  AnimalStatus.ativo
                                              ? Colors.green.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => AnimalDetailView(
                                                  animalId: animal.id)));
                                      controller.fetchAnimals();
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AnimalFormView()));
                controller.fetchAnimals();
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
