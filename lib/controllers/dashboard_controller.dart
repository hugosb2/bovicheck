import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/models/lote.dart'; // IMPORTADO
import 'package:bovicheck/models/propriedade.dart';
import 'package:bovicheck/services/herd_analysis_service.dart';
import 'package:flutter/material.dart';
import '../services/ai_evaluation_service.dart';
import '../services/database_service.dart';
import '../services/user_activity_service.dart';
import 'package:bovicheck/models/analysis_snapshot.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class DashboardController extends ChangeNotifier {
  Map<String, double?> _latestAnalysis = {};
  List<String> _mostUsedActions = [];
  AIAnalysisResult? dashboardAIAnalysis;

  int _animalCount = 0;
  int _loteCount = 0;
  int _propCount = 0;

  // NOVAS PROPRIEDADES
  Map<String, Map<String, double?>> loteAnalyses = {};
  Map<String, Lote> allLotesMap = {};

  Map<String, double?> get latestAnalysis => _latestAnalysis;
  List<String> get mostUsedActions => _mostUsedActions;

  int get animalCount => _animalCount;
  int get loteCount => _loteCount;
  int get propCount => _propCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DashboardController() {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    final List<Animal> allAnimals =
        await DatabaseService.instance.getAllAnimalsWithHistory();
    final List<Propriedade> allProps =
        await DatabaseService.instance.getAllPropriedades();
    final allLotes = await DatabaseService.instance.getAllLotes(); // JÁ EXISTIA

    final history = await DatabaseService.instance.getAnalysisHistory();

    final lastSavedSnapshot = history.isNotEmpty ? history.first : null;

    _animalCount = allAnimals.length;
    _loteCount = allLotes.length;
    _propCount = allProps.length;

    final Propriedade? mainProp = allProps.isNotEmpty ? allProps.first : null;
    final AIEvaluationService aiService = AIEvaluationService();

    // --- CÁLCULO GLOBAL (EXISTENTE) ---
    final period = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 365)),
      end: DateTime.now(),
    );

    if (allAnimals.isNotEmpty) {
      final analysisService = HerdAnalysisService(allAnimals);
      _latestAnalysis = analysisService.analyze(period);
    } else {
      _latestAnalysis = {};
    }
    // --- FIM DO CÁLCULO GLOBAL ---

    // --- NOVO CÁLCULO POR LOTE ---
    loteAnalyses.clear();
    allLotesMap = {for (var lote in allLotes) lote.id: lote};

    for (final lote in allLotes) {
      final animalsInLote =
          allAnimals.where((animal) => animal.loteId == lote.id).toList();

      if (animalsInLote.isNotEmpty) {
        final loteAnalysisService = HerdAnalysisService(animalsInLote);
        final loteResults = loteAnalysisService.analyze(period);

        // Só adiciona o lote se tiver resultados válidos
        if (loteResults.values.any((v) => v != null)) {
          loteAnalyses[lote.id] = loteResults;
        }
      }
    }
    // --- FIM DO NOVO CÁLCULO POR LOTE ---

    // A Análise de IA continua baseada nos dados globais
    dashboardAIAnalysis =
        aiService.analyzeDashboard(_latestAnalysis, propriedade: mainProp);

    // Lógica de Snapshot (mantida para os dados globais)
    bool areResultsDifferent = lastSavedSnapshot == null
        ? _latestAnalysis.isNotEmpty
        : !const DeepCollectionEquality()
            .equals(_latestAnalysis, lastSavedSnapshot.results);

    if (areResultsDifferent && _latestAnalysis.values.any((v) => v != null)) {
      final newSnapshot = AnalysisSnapshot(
        id: const Uuid().v4(),
        date: DateTime.now(),
        results: _latestAnalysis,
      );
      await DatabaseService.instance.addAnalysisSnapshot(newSnapshot);
      debugPrint("Novo snapshot de indicadores salvo pelo Dashboard.");
    }
    _mostUsedActions =
        await UserActivityService.instance.getMostUsedActions(count: 4);

    _isLoading = false;
    notifyListeners();
  }
}
