import 'package:bovicheck/modelos/animal/animal.dart';
import 'package:bovicheck/estilos/app_icons.dart';
import 'package:bovicheck/telas/animal/tabs/breeding_tab.dart';
import 'package:bovicheck/telas/animal/tabs/health_tab.dart';
import 'package:bovicheck/telas/animal/tabs/production_tab.dart';
import 'package:bovicheck/telas/animal/tabs/summary_tab.dart';
import 'package:bovicheck/telas/animal/tabs/weights_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controladores/animal_detail_controller.dart';
import 'animal_form_view.dart';

class AnimalDetailView extends StatefulWidget {
  final String animalId;
  const AnimalDetailView({super.key, required this.animalId});

  @override
  State<AnimalDetailView> createState() => _AnimalDetailViewState();
}

class _AnimalDetailViewState extends State<AnimalDetailView> {
  int _currentTabIndex = 0;
  final List<Map<String, dynamic>> _tabs = [];

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

  void _buildTabs(Animal animal) {
    _tabs.clear();

    _tabs.add({
      'title': 'Resumo',
      'icon': AppIcons.summary,
      'view': const SummaryTab(),
    });

    _tabs.add({
      'title': 'Pesagens',
      'icon': AppIcons.weights,
      'view': WeightsTab(animalId: animal.id),
    });

    _tabs.add({
      'title': 'Saúde',
      'icon': AppIcons.health,
      'view': HealthTab(animalId: animal.id),
    });

    if (animal.sexo == 'Fêmea') {
      _tabs.add({
        'title': 'Produção',
        'icon': AppIcons.production,
        'view': ProductionTab(animalId: animal.id),
      });

      _tabs.add({
        'title': 'Reprodução',
        'icon': AppIcons.breeding,
        'view': BreedingTab(animalId: animal.id),
      });
    }
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == _currentTabIndex;
            return ListTile(
              leading: Icon(
                tab['icon'],
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              title: Text(
                tab['title'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                setState(() {
                  _currentTabIndex = index;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
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

          // Constrói as abas pela primeira vez
          if (_tabs.isEmpty) {
            _buildTabs(animal);
          }

          final theme = Theme.of(context);
          final isMobile = MediaQuery.of(context).size.width < 600;
          final showFloatingButtons = _currentTabIndex == 0;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                animal.nome != null && animal.nome!.isNotEmpty
                    ? animal.nome!
                    : 'Brinco: ${animal.brinco}',
                style: TextStyle(fontSize: isMobile ? 18 : 20),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'Menu',
                  onPressed: () => _openMenu(context),
                ),
              ],
            ),
            body: _tabs.isNotEmpty
                ? _tabs[_currentTabIndex]['view'] as Widget
                : const Center(child: CircularProgressIndicator()),
            floatingActionButton: showFloatingButtons
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'edit',
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AnimalFormView(animal: animal)),
                          );
                          controller.fetchAnimal();
                        },
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(AppIcons.edit),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                        heroTag: 'delete',
                        onPressed: () =>
                            _showDeleteAnimalConfirmation(context, controller),
                        backgroundColor: theme.colorScheme.error,
                        child: const Icon(AppIcons.delete),
                      ),
                    ],
                  )
                : null,
          );
        },
      ),
    );
  }
}
