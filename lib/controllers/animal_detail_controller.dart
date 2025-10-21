import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/models/animal/health_event.dart';
import 'package:bovicheck/models/animal/medication_record.dart';
import 'package:bovicheck/models/animal/milk_record.dart';
import 'package:bovicheck/models/animal/reproductive_event.dart';
import 'package:bovicheck/models/animal/weight_record.dart';
import 'package:bovicheck/services/animal_analysis_service.dart';
import 'package:bovicheck/services/database_service.dart';
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
    notifyListeners();

    _animal = await DatabaseService.instance.getAnimalWithHistory(animalId);

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

  Future<void> addWeightRecord(WeightRecord r) async {
    await DatabaseService.instance.addWeightRecord(_animal!.id, r);
    await fetchAnimal();
  }

  Future<void> updateWeightRecord(WeightRecord r) async {
    await DatabaseService.instance.updateWeightRecord(r);
    await fetchAnimal();
  }

  Future<void> deleteWeightRecord(String id) async {
    await DatabaseService.instance.deleteWeightRecord(id);
    await fetchAnimal();
  }

  Future<void> addHealthEvent(HealthEvent r) async {
    await DatabaseService.instance.addHealthEvent(_animal!.id, r);
    await fetchAnimal();
  }

  Future<void> updateHealthEvent(HealthEvent r) async {
    await DatabaseService.instance.updateHealthEvent(r);
    await fetchAnimal();
  }

  Future<void> deleteHealthEvent(String id) async {
    await DatabaseService.instance.deleteHealthEvent(id);
    await fetchAnimal();
  }

  Future<void> addMedicationRecord(MedicationRecord r) async {
    await DatabaseService.instance.addMedicationRecord(_animal!.id, r);
    await fetchAnimal();
  }

  Future<void> updateMedicationRecord(MedicationRecord r) async {
    await DatabaseService.instance.updateMedicationRecord(r);
    await fetchAnimal();
  }

  Future<void> deleteMedicationRecord(String id) async {
    await DatabaseService.instance.deleteMedicationRecord(id);
    await fetchAnimal();
  }

  Future<void> addReproductiveEvent(ReproductiveEvent r) async {
    await DatabaseService.instance.addReproductiveEvent(_animal!.id, r);
    await fetchAnimal();
  }

  Future<void> updateReproductiveEvent(ReproductiveEvent r) async {
    await DatabaseService.instance.updateReproductiveEvent(r);
    await fetchAnimal();
  }

  Future<void> deleteReproductiveEvent(String id) async {
    await DatabaseService.instance.deleteReproductiveEvent(id);
    await fetchAnimal();
  }

  Future<void> addMilkRecord(MilkRecord r) async {
    await DatabaseService.instance.addMilkRecord(_animal!.id, r);
    await fetchAnimal();
  }

  Future<void> updateMilkRecord(MilkRecord r) async {
    await DatabaseService.instance.updateMilkRecord(r);
    await fetchAnimal();
  }

  Future<void> deleteMilkRecord(String id) async {
    await DatabaseService.instance.deleteMilkRecord(id);
    await fetchAnimal();
  }

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
