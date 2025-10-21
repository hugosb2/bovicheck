import 'dart:convert';
import 'dart:io';
import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/models/lote.dart';
import 'package:bovicheck/models/analysis_snapshot.dart';
import 'package:bovicheck/models/propriedade.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

class JsonStorageService {
  static final JsonStorageService instance = JsonStorageService._init();
  JsonStorageService._init();

  Map<String, Animal> _animals = {};
  Map<String, Lote> _lotes = {};
  List<AnalysisSnapshot> _analysisHistory = [];
  Map<String, Propriedade> _propriedades = {};

  Future<File> get _localFile async {
    final path = await getApplicationDocumentsDirectory();
    return File('${path.path}/bovicheck_data.json');
  }

  Future<void> loadData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        _animals = {};
        _lotes = {};
        _analysisHistory = [];
        _propriedades = {};
        return;
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        _animals = {};
        _lotes = {};
        _analysisHistory = [];
        _propriedades = {};
        return;
      }
      final Map<String, dynamic> json = jsonDecode(contents);

      if (json.containsKey('animals')) {
        _animals = (json['animals'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, Animal.fromJson(value)));
      }
      if (json.containsKey('lotes')) {
        _lotes = (json['lotes'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, Lote.fromJson(value)));
      }
      if (json.containsKey('analysisHistory')) {
        _analysisHistory = (json['analysisHistory'] as List)
            .map((item) => AnalysisSnapshot.fromJson(item))
            .toList();
      }
      if (json.containsKey('propriedades')) {
        _propriedades = (json['propriedades'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, Propriedade.fromJson(value)));
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados do JSON: $e");
      _animals = {};
      _lotes = {};
      _analysisHistory = [];
      _propriedades = {};
    }
  }

  Future<void> _saveData() async {
    try {
      final file = await _localFile;
      final fullData = {
        'animals': _animals.map((key, value) => MapEntry(key, value.toJson())),
        'lotes': _lotes.map((key, value) => MapEntry(key, value.toJson())),
        'analysisHistory': _analysisHistory.map((s) => s.toJson()).toList(),
        'propriedades':
            _propriedades.map((key, value) => MapEntry(key, value.toJson())),
      };
      await file.writeAsString(jsonEncode(fullData));
    } catch (e) {
      debugPrint("Erro ao salvar dados no JSON: $e");
    }
  }

  Future<void> addAnalysisSnapshot(AnalysisSnapshot snapshot) async {
    _analysisHistory.add(snapshot);
    await _saveData();
  }

  List<AnalysisSnapshot> getAnalysisHistory() {
    final sortedHistory = List<AnalysisSnapshot>.from(_analysisHistory)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedHistory;
  }

  List<Propriedade> getAllPropriedades() =>
      _propriedades.values.sortedBy((p) => p.nome).toList();

  Future<void> addOrUpdatePropriedade(Propriedade prop) async {
    _propriedades[prop.id] = prop;
    await _saveData();
  }

  bool isPropriedadeInUse(String propId) {
    return _lotes.values.any((lote) => lote.propriedadeId == propId);
  }

  Future<void> deletePropriedade(String propId) async {
    if (isPropriedadeInUse(propId)) {
      debugPrint("Tentativa de excluir propriedade em uso.");
      return;
    }
    _propriedades.remove(propId);
    await _saveData();
  }

  Map<String, dynamic> getAllData() {
    return {
      'animals': _animals,
      'lotes': _lotes,
      'analysisHistory': _analysisHistory,
      'propriedades': _propriedades,
    };
  }

  Future<void> restoreAllData(Map<String, dynamic> dataToRestore) async {
    if (dataToRestore.containsKey('animals')) {
      _animals = (dataToRestore['animals'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, Animal.fromJson(value)));
    }
    if (dataToRestore.containsKey('lotes')) {
      _lotes = (dataToRestore['lotes'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, Lote.fromJson(value)));
    }
    if (dataToRestore.containsKey('analysisHistory')) {
      _analysisHistory = (dataToRestore['analysisHistory'] as List)
          .map((item) => AnalysisSnapshot.fromJson(item))
          .toList();
    }
    if (dataToRestore.containsKey('propriedades')) {
      _propriedades = (dataToRestore['propriedades'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, Propriedade.fromJson(value)));
    }
    await _saveData();
  }

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

  List<Lote> getAllLotes() => _lotes.values.sortedBy((l) => l.nome).toList();

  Future<void> addOrUpdateLote(Lote lote) async {
    _lotes[lote.id] = lote;
    await _saveData();
  }

  Future<void> deleteLote(String loteId) async {
    _lotes.remove(loteId);
    for (var animal in _animals.values) {
      if (animal.loteId == loteId) {
        animal.loteId = null;
      }
    }
    await _saveData();
  }

  Future<void> clearAllData() async {
    _animals = {};
    _lotes = {};
    _analysisHistory = [];
    _propriedades = {};
    await _saveData();
  }
}
