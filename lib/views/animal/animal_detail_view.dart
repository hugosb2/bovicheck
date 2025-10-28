import 'package:bovicheck/views/animal/tabs/breeding_tab.dart';
import 'package:bovicheck/views/animal/tabs/health_tab.dart';
import 'package:bovicheck/views/animal/tabs/production_tab.dart';
import 'package:bovicheck/views/animal/tabs/summary_tab.dart';
import 'package:bovicheck/views/animal/tabs/weights_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/animal_detail_controller.dart';
import 'animal_form_view.dart';

class AnimalDetailView extends StatefulWidget {
  final String animalId;
  const AnimalDetailView({super.key, required this.animalId});

  @override
  State<AnimalDetailView> createState() => _AnimalDetailViewState();
}

class _AnimalDetailViewState extends State<AnimalDetailView> {
  int _selectedIndex = 0;

  Future<void> _showDeleteAnimalConfirmation(
      BuildContext context, AnimalDetailController controller) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
              'Tem certeza que deseja apagar o animal "${controller.animal?.brinco}"? Todos os seus dados (pesagens, saúde, etc.) serão perdidos permanentemente.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Apagar'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await controller.deleteAnimal();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnimalDetailController(widget.animalId)..fetchAnimal(),
      child: Consumer<AnimalDetailController>(
        builder: (context, controller, child) {
          final animal = controller.animal;

          if (controller.isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Carregando...')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (animal == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Erro')),
              body: const Center(child: Text('Animal não encontrado')),
            );
          }

          final List<Widget> widgetOptions = [];
          final List<Widget> drawerItems = [];
          int tabIndex = 0;

          widgetOptions.add(const SummaryTab());
          drawerItems.add(_buildDrawerItem(
            context,
            icon: Icons.dashboard_outlined,
            title: 'Desempenho',
            index: tabIndex,
          ));
          tabIndex++;

          widgetOptions.add(WeightsTab(animalId: animal.id));
          drawerItems.add(_buildDrawerItem(
            context,
            icon: Icons.scale_outlined,
            title: 'Pesagens',
            index: tabIndex,
          ));
          tabIndex++;

          widgetOptions.add(HealthTab(animalId: animal.id));
          drawerItems.add(_buildDrawerItem(
            context,
            icon: Icons.healing_outlined,
            title: 'Saúde',
            index: tabIndex,
          ));
          tabIndex++;

          if (animal.sexo == 'Fêmea') {
            widgetOptions.add(ProductionTab(animalId: animal.id));
            drawerItems.add(_buildDrawerItem(
              context,
              icon: Icons.opacity_outlined,
              title: 'Produção',
              index: tabIndex,
            ));
            tabIndex++;

            widgetOptions.add(BreedingTab(animalId: animal.id));
            drawerItems.add(_buildDrawerItem(
              context,
              icon: Icons.favorite_border,
              title: 'Reprodução',
              index: tabIndex,
            ));
            tabIndex++;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Brinco: ${animal.brinco}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar Animal',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AnimalFormView(animal: animal)),
                    );
                    controller.fetchAnimal();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Apagar Animal',
                  onPressed: () =>
                      _showDeleteAnimalConfirmation(context, controller),
                ),
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      tooltip: 'Ver seções',
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    );
                  },
                ),
              ],
            ),
            body: widgetOptions[_selectedIndex],
            endDrawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Brinco: ${animal.brinco}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (animal.nome != null)
                          Text(
                            animal.nome!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ...drawerItems,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}
