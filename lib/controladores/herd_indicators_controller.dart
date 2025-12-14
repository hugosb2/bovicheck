import 'package:bovicheck/modelos/analysis_snapshot.dart';
import 'package:bovicheck/servicos/herd_analysis_service.dart';
import 'package:bovicheck/servicos/database_service.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class HerdIndicatorsController extends ChangeNotifier {
  late HerdAnalysisService _analysisService;
  bool isLoading = true;

  DateTimeRange selectedPeriod = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 365)),
    end: DateTime.now(),
  );

  Map<String, double?> analysisResults = {};
  AnalysisSnapshot? _lastSavedSnapshot;

  HerdIndicatorsController() {
    loadDataAndAnalyze();
  }

  Future<void> loadDataAndAnalyze() async {
    isLoading = true;
    notifyListeners();

    try {
      final history = await DatabaseService.instance.getAnalysisHistory();
      _lastSavedSnapshot = history.isNotEmpty ? history.first : null;

      final allAnimals = await DatabaseService.instance.getAllAnimals();
      _analysisService = HerdAnalysisService(allAnimals);
      final newAnalysisResults = _analysisService.analyze(selectedPeriod);

      bool areResultsDifferent = _lastSavedSnapshot == null
          ? newAnalysisResults.isNotEmpty
          : !const DeepCollectionEquality()
              .equals(newAnalysisResults, _lastSavedSnapshot!.results);

      if (areResultsDifferent) {
        final newSnapshot = AnalysisSnapshot(
          id: const Uuid().v4(),
          date: DateTime.now(),
          results: newAnalysisResults,
        );
        await DatabaseService.instance.addAnalysisSnapshot(newSnapshot);
        _lastSavedSnapshot = newSnapshot;
        debugPrint("Novo snapshot de indicadores salvo automaticamente.");
      }

      analysisResults = newAnalysisResults;
    } catch (e) {
      debugPrint("Erro ao carregar/salvar indicadores: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setPeriod(DateTimeRange newPeriod) async {
    selectedPeriod = newPeriod;
    await loadDataAndAnalyze();
  }
}
