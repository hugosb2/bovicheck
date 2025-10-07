// lib/services/animal_analysis_service.dart

import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/services/herd_analysis_service.dart'; // Reutiliza a classe LactationCycle
import 'package:collection/collection.dart';

class AnimalAnalysisService {
  final Animal animal;

  AnimalAnalysisService(this.animal);

  // --- Índices Reprodutivos ---
  double? get ageAtFirstCalving {
    if (animal.sexo == 'Macho') return null;
    final firstCalving = animal.historicoReprodutivo
        .where((e) => e.eventType == 'Parto')
        .sortedBy((e) => e.date)
        .firstOrNull;
    
    if (firstCalving == null) return null;
    return firstCalving.date.difference(animal.dataNascimento).inDays / 30.44; // Em meses
  }

  double? get averageCalvingInterval {
    if (animal.sexo == 'Macho') return null;
    final intervals = calvingIntervals;
    if (intervals.isEmpty) return null;
    return intervals.average;
  }

  List<int> get calvingIntervals {
    final intervals = <int>[];
    final calvings = animal.historicoReprodutivo
        .where((e) => e.eventType == 'Parto')
        .sortedBy((e) => e.date)
        .toList();

    if (calvings.length > 1) {
      for (int i = 0; i < calvings.length - 1; i++) {
        final interval = calvings[i + 1].date.difference(calvings[i].date).inDays;
        intervals.add(interval);
      }
    }
    return intervals;
  }

  // --- Índices de Peso ---
  double? get adgBirthToWeaning {
    if (!animal.isDesmamado || animal.dataDesmame == null) return null;
    
    final birthWeightRecord = animal.historicoPeso.sortedBy((r) => r.date.difference(animal.dataNascimento).abs()).firstOrNull;
    final weanWeightRecord = animal.historicoPeso.sortedBy((r) => r.date.difference(animal.dataDesmame!).abs()).firstOrNull;

    if (birthWeightRecord != null && weanWeightRecord != null) {
      final days = animal.dataDesmame!.difference(animal.dataNascimento).inDays;
      if (days > 0) {
        final weightGain = weanWeightRecord.weight - birthWeightRecord.weight;
        return weightGain > 0 ? weightGain / days : 0.0;
      }
    }
    return null;
  }

  // --- Índices de Leite ---
  LactationCycle? get latestLactation {
    if (animal.sexo == 'Macho') return null;
    
    final calvings = animal.historicoReprodutivo.where((e) => e.eventType == 'Parto').sortedBy((e) => e.date).toList();
    if (calvings.isEmpty) return null;

    final lastCalving = calvings.last;
    
    final milkInCycle = animal.historicoLeite
        .where((r) => !r.date.isBefore(lastCalving.date))
        .toList();
        
    if (milkInCycle.isEmpty) return null;

    return LactationCycle(
      startDate: lastCalving.date,
      endDate: null, // Representa a lactação atual/aberta
      records: milkInCycle,
    );
  }
}