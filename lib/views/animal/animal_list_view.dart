// lib/views/animal/animal_list_view.dart

import 'package:bovicheck/controllers/animal_list_controller.dart';
import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/models/lote.dart';
import 'package:bovicheck/services/json_storage_service.dart';
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
  List<Lote> _lotes = [];

  @override
  void initState() {
    super.initState();
    _lotes = JsonStorageService.instance.getAllLotes();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnimalListController(),
      // O Consumer agora envolve o Scaffold para fornecer o 'context' correto.
      child: Consumer<AnimalListController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Meu Rebanho'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por brinco ou nome',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => controller.search(value),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ChoiceChip(
                        label: const Text('Todos'),
                        selected: _selectedLoteId == null,
                        onSelected: (selected) {
                          setState(() => _selectedLoteId = null);
                          controller.filterByLote(null);
                        },
                      ),
                      ..._lotes.map((lote) => Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ChoiceChip(
                              label: Text(lote.nome),
                              selected: _selectedLoteId == lote.id,
                              onSelected: (selected) {
                                final newLoteId = selected ? lote.id : null;
                                setState(() => _selectedLoteId = newLoteId);
                                controller.filterByLote(newLoteId);
                              },
                            ),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: controller.filteredAnimals.isEmpty
                      ? const Center(child: Text('Nenhum animal encontrado.'))
                      : ListView.builder(
                          itemCount: controller.filteredAnimals.length,
                          itemBuilder: (context, index) {
                            final animal = controller.filteredAnimals[index];
                            final age = DateTime.now()
                                .difference(animal.dataNascimento)
                                .inDays;
                            final ageString = (age / 365).floor() > 0
                                ? '${(age / 365).floor()} anos'
                                : '${(age / 30).floor()} meses';
                            return ListTile(
                              leading: CircleAvatar(
                                  child:
                                      Text(animal.sexo == 'Fêmea' ? 'F' : 'M')),
                              title: Text('Brinco: ${animal.brinco}'),
                              subtitle: Text(
                                  '${animal.nome ?? 'Sem nome'} • $ageString'),
                              trailing: Icon(Icons.circle,
                                  color: animal.status == AnimalStatus.ativo
                                      ? Colors.green
                                      : Colors.red,
                                  size: 12),
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => AnimalDetailView(
                                            animalId: animal.id)));
                                controller.fetchAnimals();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                // O 'controller' agora é acessado diretamente pelo builder do Consumer,
                // o que resolve o erro de contexto.
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
