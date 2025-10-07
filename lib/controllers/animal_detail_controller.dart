// lib/controllers/animal_detail_controller.dart

import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/models/animal/health_event.dart';
import 'package:bovicheck/models/animal/medication_record.dart';
import 'package:bovicheck/models/animal/milk_record.dart';
import 'package:bovicheck/models/animal/reproductive_event.dart';
import 'package:bovicheck/models/animal/weight_record.dart';
import 'package:bovicheck/services/animal_analysis_service.dart';
import 'package:bovicheck/services/json_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimalDetailController extends ChangeNotifier {
  final String animalId;
  Animal? _animal;
  bool _isLoading = true;
  
  late AnimalAnalysisService _analysisService;
  Map<String, dynamic> analysisResults = {};

  Animal? get animal => _animal;
  bool get isLoading => _isLoading;

  AnimalDetailController(this.animalId);

  Future<void> fetchAnimal() async {
    _isLoading = true;
    // Pequeno delay para garantir que a UI de loading apareça se a operação for muito rápida
    await Future.delayed(const Duration(milliseconds: 50));
    notifyListeners();
    
    _animal = JsonStorageService.instance.getAnimalById(animalId);
    
    if (_animal != null) {
      _analysisService = AnimalAnalysisService(_animal!);
      analysisResults = {
        'ageAtFirstCalving': _analysisService.ageAtFirstCalving,
        'averageCalvingInterval': _analysisService.averageCalvingInterval,
        'adgBirthToWeaning': _analysisService.adgBirthToWeaning,
        'latestLactation': _analysisService.latestLactation,
      };
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _updateAndRefresh(Function updateAction) async {
    if (_animal == null) return;
    updateAction();
    await JsonStorageService.instance.addOrUpdateAnimal(_animal!);
    await fetchAnimal();
  }

  // --- PESAGENS ---
  Future<void> addWeightRecord(WeightRecord r) async => await _updateAndRefresh(() => _animal!.historicoPeso.add(r));
  Future<void> updateWeightRecord(WeightRecord r) async => await _updateAndRefresh(() {
    final i = _animal!.historicoPeso.indexWhere((e) => e.id == r.id);
    if (i != -1) _animal!.historicoPeso[i] = r;
  });
  Future<void> deleteWeightRecord(String id) async => await _updateAndRefresh(() => _animal!.historicoPeso.removeWhere((e) => e.id == id));
  
  // --- EVENTOS DE SAÚDE ---
  Future<void> addHealthEvent(HealthEvent r) async => await _updateAndRefresh(() => _animal!.historicoSaude.add(r));
  Future<void> updateHealthEvent(HealthEvent r) async => await _updateAndRefresh(() {
    final i = _animal!.historicoSaude.indexWhere((e) => e.id == r.id);
    if (i != -1) _animal!.historicoSaude[i] = r;
  });
  Future<void> deleteHealthEvent(String id) async => await _updateAndRefresh(() => _animal!.historicoSaude.removeWhere((e) => e.id == id));
  
  // --- MEDICAÇÕES ---
  Future<void> addMedicationRecord(MedicationRecord r) async => await _updateAndRefresh(() => _animal!.historicoMedicacao.add(r));
  Future<void> updateMedicationRecord(MedicationRecord r) async => await _updateAndRefresh(() {
    final i = _animal!.historicoMedicacao.indexWhere((e) => e.id == r.id);
    if (i != -1) _animal!.historicoMedicacao[i] = r;
  });
  Future<void> deleteMedicationRecord(String id) async => await _updateAndRefresh(() => _animal!.historicoMedicacao.removeWhere((e) => e.id == id));

  // --- EVENTOS REPRODUTIVOS ---
  Future<void> addReproductiveEvent(ReproductiveEvent r) async => await _updateAndRefresh(() => _animal!.historicoReprodutivo.add(r));
  Future<void> updateReproductiveEvent(ReproductiveEvent r) async => await _updateAndRefresh(() {
    final i = _animal!.historicoReprodutivo.indexWhere((e) => e.id == r.id);
    if (i != -1) _animal!.historicoReprodutivo[i] = r;
  });
  Future<void> deleteReproductiveEvent(String id) async => await _updateAndRefresh(() => _animal!.historicoReprodutivo.removeWhere((e) => e.id == id));

  // --- PRODUÇÃO DE LEITE ---
  Future<void> addMilkRecord(MilkRecord r) async => await _updateAndRefresh(() => _animal!.historicoLeite.add(r));
  Future<void> updateMilkRecord(MilkRecord r) async => await _updateAndRefresh(() {
    final i = _animal!.historicoLeite.indexWhere((e) => e.id == r.id);
    if (i != -1) _animal!.historicoLeite[i] = r;
  });
  Future<void> deleteMilkRecord(String id) async => await _updateAndRefresh(() => _animal!.historicoLeite.removeWhere((e) => e.id == id));

  // --- GETTERS ---
  String get formattedBirthDate {
    if (_animal == null) return '';
    return DateFormat('dd/MM/yyyy').format(_animal!.dataNascimento);
  }

  String get formattedAge {
    if (_animal == null) return '';
    final now = DateTime.now();
    final difference = now.difference(_animal!.dataNascimento);
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    if (years > 0) return '$years anos e $months meses';
    return '$months meses';
  }
}