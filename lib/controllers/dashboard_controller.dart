// lib/controllers/dashboard_controller.dart

import 'package:flutter/material.dart';
import '../models/calculation_record.dart';
import '../services/ai_evaluation_service.dart';
import '../services/json_storage_service.dart';
import '../services/user_activity_service.dart';

class DashboardController extends ChangeNotifier {
  List<CalculationRecord> _latestRecords = [];
  List<String> _mostUsedActions = [];
  AIAnalysisResult? dashboardAIAnalysis;

  List<CalculationRecord> get latestRecords => _latestRecords;
  List<String> get mostUsedActions => _mostUsedActions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DashboardController() {
    fetchLatestRecords();
  }

  Future<void> fetchLatestRecords() async {
    _isLoading = true;
    notifyListeners();

    _latestRecords =
        JsonStorageService.instance.getLatestCalculationForEachIndex();
    _mostUsedActions =
        await UserActivityService.instance.getMostUsedActions(count: 4);

    dashboardAIAnalysis =
        AIEvaluationService().analyzeDashboard(_latestRecords);

    _isLoading = false;
    notifyListeners();
  }
}
