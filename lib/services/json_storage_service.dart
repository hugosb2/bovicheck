// lib/services/json_storage_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/models/calculation_record.dart';
import 'package:bovicheck/models/lote.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

class JsonStorageService {
  static final JsonStorageService instance = JsonStorageService._init();
  JsonStorageService._init();

  Map<String, List<CalculationRecord>> _calculations = {};
  Map<String, Animal> _animals = {};
  Map<String, Lote> _lotes = {};

  Future<File> get _localFile async {
    final path = await getApplicationDocumentsDirectory();
    return File('${path.path}/bovicheck_data.json');
  }

  Future<void> loadData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        _calculations = {};
        _animals = {};
        _lotes = {};
        return;
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        _calculations = {};
        _animals = {};
        _lotes = {};
        return;
      }
      final Map<String, dynamic> json = jsonDecode(contents);

      if (json.containsKey('calculations')) {
        _calculations =
            (json['calculations'] as Map<String, dynamic>).map((key, value) {
          final records = (value as List)
              .map((item) => CalculationRecord.fromJson(item))
              .toList();
          return MapEntry(key, records);
        });
      }
      if (json.containsKey('animals')) {
        _animals = (json['animals'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, Animal.fromJson(value)));
      }
      if (json.containsKey('lotes')) {
        _lotes = (json['lotes'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, Lote.fromJson(value)));
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados do JSON: $e");
      _calculations = {};
      _animals = {};
      _lotes = {};
    }
  }

  Future<void> _saveData() async {
    try {
      final file = await _localFile;
      final fullData = {
        'calculations': _calculations.map((key, value) =>
            MapEntry(key, value.map((record) => record.toJson()).toList())),
        'animals': _animals.map((key, value) => MapEntry(key, value.toJson())),
        'lotes': _lotes.map((key, value) => MapEntry(key, value.toJson())),
      };
      await file.writeAsString(jsonEncode(fullData));
    } catch (e) {
      debugPrint("Erro ao salvar dados no JSON: $e");
    }
  }

  // --- MÉTODOS PARA CÁLCULOS ---
  Future<void> addCalculation(CalculationRecord record) async {
    (_calculations[record.indexName] ??= []).add(record);
    await _saveData();
  }

  Future<void> updateCalculation(CalculationRecord updatedRecord) async {
    if (_calculations.containsKey(updatedRecord.indexName)) {
      final index = _calculations[updatedRecord.indexName]!
          .indexWhere((record) => record.id == updatedRecord.id);
      if (index != -1) {
        _calculations[updatedRecord.indexName]![index] = updatedRecord;
      }
    }
    await _saveData();
  }

  Future<void> deleteCalculation(String id, String indexName) async {
    if (_calculations.containsKey(indexName)) {
      _calculations[indexName]!.removeWhere((record) => record.id == id);
      if (_calculations[indexName]!.isEmpty) {
        _calculations.remove(indexName);
      }
    }
    await _saveData();
  }

  Future<void> clearHistoryForIndex(String indexName) async {
    _calculations.remove(indexName);
    await _saveData();
  }

  /// CORRIGIDO: Esta versão garante a ordenação cronológica precisa (incluindo o horário)
  /// e não modifica a lista de dados original no serviço.
  List<CalculationRecord> getHistoryForIndex(String indexName) {
    final originalRecords = _calculations[indexName] ?? [];
    // Cria uma CÓPIA da lista e a ordena de forma robusta.
    // A ordenação por DateTime já considera o horário completo.
    final sortedRecords = List<CalculationRecord>.from(originalRecords)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedRecords;
  }

  List<CalculationRecord> getLatestCalculationForEachIndex() {
    return _calculations.values
        .where((records) => records.isNotEmpty)
        .map((records) => records.sortedBy((r) => r.date).last)
        .sortedBy((r) => r.date)
        .reversed
        .toList();
  }

  int getTotalRecordsCount() =>
      _calculations.values.fold(0, (sum, list) => sum + list.length);

  Map<String, dynamic> getAllData() {
    // Retorna todos os dados para backup, incluindo animais e lotes
    return {
      'calculations': _calculations,
      'animals': _animals,
      'lotes': _lotes,
    };
  }

  Future<void> restoreAllData(Map<String, dynamic> dataToRestore) async {
    if (dataToRestore.containsKey('calculations')) {
      _calculations = (dataToRestore['calculations'] as Map<String, dynamic>)
          .map((key, value) {
        return MapEntry(
            key,
            (value as List)
                .map((item) => CalculationRecord.fromJson(item))
                .toList());
      });
    }
    if (dataToRestore.containsKey('animals')) {
      _animals = (dataToRestore['animals'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, Animal.fromJson(value)));
    }
    if (dataToRestore.containsKey('lotes')) {
      _lotes = (dataToRestore['lotes'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, Lote.fromJson(value)));
    }
    await _saveData();
  }

  // --- MÉTODOS PARA ANIMAIS ---
  List<Animal> getAllAnimals() =>
      _animals.values.sortedBy((a) => a.brinco).toList();

  Animal? getAnimalById(String animalId) => _animals[animalId];

  Future<void> addOrUpdateAnimal(Animal animal) async {
    _animals[animal.id] = animal;
    await _saveData();
  }

  Future<void> deleteAnimal(String animalId) async {
    _animals.remove(animalId);
    await _saveData();
  }

  // --- MÉTODOS PARA LOTES ---
  List<Lote> getAllLotes() => _lotes.values.sortedBy((l) => l.nome).toList();

  Future<void> addOrUpdateLote(Lote lote) async {
    _lotes[lote.id] = lote;
    await _saveData();
  }

  Future<void> deleteLote(String loteId) async {
    // Remove o lote
    _lotes.remove(loteId);
    // Desvincula os animais que estavam nesse lote
    for (var animal in _animals.values) {
      if (animal.loteId == loteId) {
        animal.loteId = null;
      }
    }
    await _saveData();
  }

  // --- MÉTODOS GERAIS ---
  Future<void> clearAllData() async {
    _calculations = {};
    _animals = {};
    _lotes = {};
    await _saveData();
  }
}
