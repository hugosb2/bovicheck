// lib/controllers/animal_list_controller.dart

import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/services/json_storage_service.dart';
import 'package:flutter/material.dart';

class AnimalListController extends ChangeNotifier {
  List<Animal> _animals = [];
  List<Animal> _filteredAnimals = [];
  String _searchTerm = '';
  String? _selectedLoteId;

  List<Animal> get filteredAnimals => _filteredAnimals;

  AnimalListController() {
    fetchAnimals();
  }

  Future<void> fetchAnimals() async {
    _animals = JsonStorageService.instance.getAllAnimals();
    _filterAnimals();
    notifyListeners();
  }

  void search(String term) {
    _searchTerm = term.toLowerCase();
    _filterAnimals();
    notifyListeners();
  }

  void _filterAnimals() {
    List<Animal> tempAnimals = List.from(_animals);
    
    if (_selectedLoteId != null) {
      tempAnimals = tempAnimals.where((animal) => animal.loteId == _selectedLoteId).toList();
    }
    
    if (_searchTerm.isNotEmpty) {
      tempAnimals = tempAnimals.where((animal) {
        return animal.brinco.toLowerCase().contains(_searchTerm) ||
               (animal.nome?.toLowerCase().contains(_searchTerm) ?? false);
      }).toList();
    }
    _filteredAnimals = tempAnimals;
  }
  
  void filterByLote(String? loteId) {
    _selectedLoteId = loteId;
    _filterAnimals();
    notifyListeners();
  }
}