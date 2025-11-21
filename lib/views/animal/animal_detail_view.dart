import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/styles/app_icons.dart';
import 'package:bovicheck/views/animal/tabs/breeding_tab.dart';
import 'package:bovicheck/views/animal/tabs/health_tab.dart';
import 'package:bovicheck/views/animal/tabs/production_tab.dart';
import 'package:bovicheck/views/animal/tabs/summary_tab.dart';
import 'package:bovicheck/views/animal/tabs/weights_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/animal_detail_controller.dart';
import 'animal_form_view.dart';

class AnimalDetailView extends StatefulWidget {
  final String animalId;
  const AnimalDetailView({super.key, required this.animalId});

  @override
  State<AnimalDetailView> createState() => _AnimalDetailViewState();
}

// 1. ADICIONE 'SingleTickerProviderStateMixin' PARA O TABCONTROLLER
class _AnimalDetailViewState extends State<AnimalDetailView>
    with SingleTickerProviderStateMixin {
  // 2. DECLARE O CONTROLLER, AS ABAS E AS VIEWS
  late TabController _tabController;
  final List<Tab> _tabs = [];
  final List<Widget> _tabViews = [];

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

  // 3. MÉTODO PARA CONSTRUIR AS ABAS DINAMICAMENTE
  void _buildTabs(Animal animal, BuildContext context) {
    _tabs.clear();
    _tabViews.clear();
    
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Em mobile, apenas ícones
      _tabs.add(const Tab(icon: Icon(AppIcons.summary, size: 20)));
      _tabViews.add(const SummaryTab());

      _tabs.add(const Tab(icon: Icon(AppIcons.weights, size: 20)));
      _tabViews.add(WeightsTab(animalId: animal.id));

      _tabs.add(const Tab(icon: Icon(AppIcons.health, size: 20)));
      _tabViews.add(HealthTab(animalId: animal.id));

      if (animal.sexo == 'Fêmea') {
        _tabs.add(const Tab(icon: Icon(AppIcons.production, size: 20)));
        _tabViews.add(ProductionTab(animalId: animal.id));

        _tabs.add(const Tab(icon: Icon(AppIcons.breeding, size: 20)));
        _tabViews.add(BreedingTab(animalId: animal.id));
      }
    } else {
      // Em telas maiores, ícone + texto
      _tabs.add(const Tab(icon: Icon(AppIcons.summary, size: 18), text: 'Resumo'));
      _tabViews.add(const SummaryTab());

      _tabs.add(const Tab(icon: Icon(AppIcons.weights, size: 18), text: 'Pesagens'));
      _tabViews.add(WeightsTab(animalId: animal.id));

      _tabs.add(const Tab(icon: Icon(AppIcons.health, size: 18), text: 'Saúde'));
      _tabViews.add(HealthTab(animalId: animal.id));

      if (animal.sexo == 'Fêmea') {
        _tabs.add(const Tab(icon: Icon(AppIcons.production, size: 18), text: 'Produção'));
        _tabViews.add(ProductionTab(animalId: animal.id));

        _tabs.add(const Tab(icon: Icon(AppIcons.breeding, size: 18), text: 'Reprodução'));
        _tabViews.add(BreedingTab(animalId: animal.id));
      }
    }

    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

          // 4. CONSTRÓI AS ABAS PELA PRIMEIRA VEZ (OU SE O ANIMAL MUDAR)
          if (_tabs.isEmpty) {
            _buildTabs(animal, context);
          }

          // 5. CONSTRÓI O SCAFFOLD COM TABBAR
          final theme = Theme.of(context);
          final isMobile = MediaQuery.of(context).size.width < 600;
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
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(AppIcons.edit, size: 22),
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
                  icon: const Icon(AppIcons.delete, size: 22),
                  tooltip: 'Apagar Animal',
                  onPressed: () =>
                      _showDeleteAnimalConfirmation(context, controller),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(isMobile ? 48 : 48),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: _tabs,
                    isScrollable: isMobile,
                    labelColor: theme.colorScheme.onPrimary,
                    unselectedLabelColor:
                        theme.colorScheme.onPrimary.withOpacity(0.7),
                    indicatorColor: theme.colorScheme.onPrimary,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 11 : 13,
                    ),
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                    ),
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: _tabViews.map((view) => view
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.05, end: 0)).toList(),
            ),
          );
        },
      ),
    );
  }
}
