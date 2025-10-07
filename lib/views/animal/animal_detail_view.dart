// lib/views/animal/animal_detail_view.dart

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

          final List<Widget> widgetOptions = <Widget>[
            const SummaryTab(),
            WeightsTab(animalId: animal.id),
            HealthTab(animalId: animal.id),
            if (animal.sexo == 'Fêmea') ProductionTab(animalId: animal.id),
            if (animal.sexo == 'Fêmea') BreedingTab(animalId: animal.id),
          ];
          
          final List<BottomNavigationBarItem> navBarItems = [
            const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Desempenho'),
            const BottomNavigationBarItem(icon: Icon(Icons.scale_outlined), label: 'Pesagens'),
            const BottomNavigationBarItem(icon: Icon(Icons.healing_outlined), label: 'Saúde'),
            if (animal.sexo == 'Fêmea')
              const BottomNavigationBarItem(icon: Icon(Icons.opacity_outlined), label: 'Produção'),
            if (animal.sexo == 'Fêmea')
              const BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Reprodução'),
          ];


          return Scaffold(
            appBar: AppBar(
              title: Text('Brinco: ${animal.brinco}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AnimalFormView(animal: animal)),
                    );
                    controller.fetchAnimal();
                  },
                ),
              ],
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: widgetOptions,
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: navBarItems,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }
}