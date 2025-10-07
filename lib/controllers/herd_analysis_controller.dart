// lib/controllers/herd_analysis_controller.dart

import 'package:bovicheck/services/herd_analysis_service.dart';
import 'package:bovicheck/services/json_storage_service.dart';
import 'package:flutter/material.dart';

class HerdAnalysisController extends ChangeNotifier {
  late HerdAnalysisService _analysisService;
  bool isLoading = true;
  
  DateTimeRange selectedPeriod = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 365)),
    end: DateTime.now(),
  );
  
  Map<String, double?> analysisResults = {};

  HerdAnalysisController() {
    loadDataAndAnalyze();
  }

  void loadDataAndAnalyze() {
    isLoading = true;
    notifyListeners();

    final allAnimals = JsonStorageService.instance.getAllAnimals();
    _analysisService = HerdAnalysisService(allAnimals);
    analysisResults = _analysisService.analyze(selectedPeriod);

    isLoading = false;
    notifyListeners();
  }

  Future<void> setPeriod(DateTimeRange newPeriod) async {
    selectedPeriod = newPeriod;
    loadDataAndAnalyze();
  }
}