import 'package:bovicheck/modelos/animal/animal.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:flutter/material.dart';

class AnimalListController extends ChangeNotifier {
  List<Animal> _animals = [];
  List<Animal> _filteredAnimals = [];
  String _searchTerm = '';
  String? _selectedLoteId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Animal> get filteredAnimals => _filteredAnimals;

  AnimalListController() {
    fetchAnimals();
  }

  Future<void> fetchAnimals() async {
    _isLoading = true;
    notifyListeners();

    _animals = await DatabaseService.instance.getAllAnimals();
    _filterAnimals();
  }

  void search(String term) {
    _searchTerm = term.toLowerCase();
    _filterAnimals();
  }

  void _filterAnimals() {
    List<Animal> tempAnimals = List.from(_animals);

    if (_selectedLoteId != null) {
      tempAnimals = tempAnimals
          .where((animal) => animal.loteId == _selectedLoteId)
          .toList();
    }

    if (_searchTerm.isNotEmpty) {
      tempAnimals = tempAnimals.where((animal) {
        return animal.brinco.toLowerCase().contains(_searchTerm) ||
            (animal.nome?.toLowerCase().contains(_searchTerm) ?? false);
      }).toList();
    }
    _filteredAnimals = tempAnimals;

    _isLoading = false;
    notifyListeners();
  }

  void filterByLote(String? loteId) {
    _selectedLoteId = loteId;
    _filterAnimals();
  }
}
