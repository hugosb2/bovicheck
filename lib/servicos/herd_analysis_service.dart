import 'package:bovicheck/modelos/animal/animal.dart';
import 'package:bovicheck/modelos/animal/milk_record.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class LactationCycle {
  final DateTime startDate;
  final DateTime? endDate;
  final List<MilkRecord> records;

  LactationCycle(
      {required this.startDate, this.endDate, required this.records});

  int get lengthInDays {
    final end = endDate ?? DateTime.now();
    final effectiveEnd = end.difference(startDate).inDays > 305
        ? startDate.add(const Duration(days: 305))
        : end;
    return effectiveEnd.difference(startDate).inDays;
  }

  double get totalProduction => records.map((r) => r.totalProduction).sum;

  double? get averageDailyProduction {
    if (records.isEmpty || lengthInDays == 0) return 0.0;
    return totalProduction / lengthInDays;
  }
}

class HerdAnalysisService {
  final List<Animal> herd;

  HerdAnalysisService(this.herd);

  Map<String, double?> analyze(DateTimeRange period) {
    return {
      'birthRate': _calculateBirthRate(period),
      'pregnancyRate': _calculatePregnancyRate(period),
      'weaningRate': _calculateWeaningRate(period),
      'mortalityRate': _calculateMortalityRate(period),
      'averageAgeAtFirstCalving': averageAgeAtFirstCalving,
      'averageCalvingInterval': averageCalvingInterval,
      'averageAdgBirthToWeaning': _calculateAverageAdgBirthToWeaning(period),
      'averageDailyMilkProduction':
          _calculateAverageDailyMilkProduction(period),
    };
  }

  double? _calculateAverageAdgBirthToWeaning(DateTimeRange period) {
    final weanedCalves = herd
        .where((a) =>
            a.isDesmamado &&
            a.dataDesmame != null &&
            !a.dataDesmame!.isBefore(period.start) &&
            !a.dataDesmame!.isAfter(period.end))
        .toList();

    if (weanedCalves.isEmpty) return null;

    final adgValues = <double>[];
    for (final calf in weanedCalves) {
      final birthWeightRecord = calf.historicoPeso
          .sortedBy((r) => r.date.difference(calf.dataNascimento).abs())
          .firstOrNull;
      final weanWeightRecord = calf.historicoPeso
          .sortedBy((r) => r.date.difference(calf.dataDesmame!).abs())
          .firstOrNull;

      if (birthWeightRecord != null && weanWeightRecord != null) {
        final days = calf.dataDesmame!.difference(calf.dataNascimento).inDays;
        if (days > 0) {
          final weightGain = weanWeightRecord.weight - birthWeightRecord.weight;
          if (weightGain > 0) {
            adgValues.add(weightGain / days);
          }
        }
      }
    }
    return adgValues.isEmpty ? null : adgValues.average;
  }

  double? _calculateAverageDailyMilkProduction(DateTimeRange period) {
    final lactationCycles = _getAllLactationCycles(period);
    if (lactationCycles.isEmpty) return null;

    final dailyAverages = lactationCycles
        .map((lc) => lc.averageDailyProduction)
        .nonNulls
        .toList();
    return dailyAverages.isEmpty ? null : dailyAverages.average;
  }

  List<LactationCycle> _getAllLactationCycles(DateTimeRange period) {
    final cycles = <LactationCycle>[];
    final females = herd.where((a) => a.sexo == 'Fêmea');

    for (final female in females) {
      final calvings = female.historicoReprodutivo
          .where((e) => e.eventType == 'Parto')
          .sortedBy((e) => e.date)
          .toList();
      if (calvings.isEmpty) continue;

      for (int i = 0; i < calvings.length; i++) {
        final startDate = calvings[i].date;
        final endDate = (i + 1 < calvings.length) ? calvings[i + 1].date : null;

        if (!startDate.isAfter(period.end)) {
          final milkInCycle = female.historicoLeite
              .where((r) =>
                  !r.date.isBefore(startDate) &&
                  (endDate == null || r.date.isBefore(endDate)))
              .toList();
          if (milkInCycle.isNotEmpty) {
            cycles.add(LactationCycle(
                startDate: startDate, endDate: endDate, records: milkInCycle));
          }
        }
      }
    }
    return cycles;
  }

  double? _calculateMortalityRate(DateTimeRange period) {
    final animalsAtStart =
        herd.where((a) => a.dataNascimento.isBefore(period.start)).toList();
    if (animalsAtStart.isEmpty) return null;

    final deadAnimals = animalsAtStart
        .where((a) =>
            a.status == AnimalStatus.morto &&
            a.dataSaida != null &&
            !a.dataSaida!.isBefore(period.start) &&
            !a.dataSaida!.isAfter(period.end))
        .toList();

    if (deadAnimals.isEmpty) return null;

    return (deadAnimals.length / animalsAtStart.length) * 100;
  }

  double? _calculateBirthRate(DateTimeRange period) {
    final eligibleFemales = herd
        .where((a) =>
            a.sexo == 'Fêmea' &&
            a.status == AnimalStatus.ativo &&
            period.start.difference(a.dataNascimento).inDays > 450)
        .toList();
    if (eligibleFemales.isEmpty) return null;

    final calvesBorn = herd
        .where((a) =>
            !a.dataNascimento.isBefore(period.start) &&
            !a.dataNascimento.isAfter(period.end))
        .toList();

    if (calvesBorn.isEmpty) return null;

    return (calvesBorn.length / eligibleFemales.length) * 100;
  }

  double? _calculatePregnancyRate(DateTimeRange period) {
    final exposedFemales = herd
        .where((a) =>
            a.sexo == 'Fêmea' &&
            a.historicoReprodutivo.any((e) =>
                (e.eventType == 'Inseminação' || e.eventType == 'Cio') &&
                !e.date.isBefore(period.start) &&
                !e.date.isAfter(period.end)))
        .toList();
    if (exposedFemales.isEmpty) return null;

    final pregnantFemales = exposedFemales
        .where((a) => a.historicoReprodutivo.any((e) =>
            e.eventType == 'Diagnóstico de Toque' &&
            e.result == 'Positivo' &&
            !e.date.isBefore(period.start) &&
            !e.date.isAfter(period.end)))
        .toList();

    if (pregnantFemales.isEmpty) return null;

    return (pregnantFemales.length / exposedFemales.length) * 100;
  }

  double? _calculateWeaningRate(DateTimeRange period) {
    final calvesBorn = herd
        .where((a) =>
            !a.dataNascimento.isBefore(period.start) &&
            !a.dataNascimento.isAfter(period.end))
        .toList();
    if (calvesBorn.isEmpty) return null;

    final weanedCalves = calvesBorn
        .where((a) =>
            a.isDesmamado &&
            a.dataDesmame != null &&
            !a.dataDesmame!.isAfter(period.end))
        .toList();

    if (weanedCalves.isEmpty) return null;

    return (weanedCalves.length / calvesBorn.length) * 100;
  }

  double? get averageAgeAtFirstCalving {
    final ages = <int>[];
    final females = herd.where((a) => a.sexo == 'Fêmea');
    for (final female in females) {
      final firstCalving = female.historicoReprodutivo
          .where((e) => e.eventType == 'Parto')
          .sortedBy((e) => e.date)
          .firstOrNull;
      if (firstCalving != null) {
        final ageInDays =
            firstCalving.date.difference(female.dataNascimento).inDays;
        ages.add(ageInDays);
      }
    }
    if (ages.isEmpty) return null;
    return ages.average / 30.44;
  }

  double? get averageCalvingInterval {
    final intervals = <int>[];
    final females = herd.where((a) => a.sexo == 'Fêmea');
    for (final female in females) {
      final calvings = female.historicoReprodutivo
          .where((e) => e.eventType == 'Parto')
          .sortedBy((e) => e.date)
          .toList();
      if (calvings.length > 1) {
        for (int i = 0; i < calvings.length - 1; i++) {
          final interval =
              calvings[i + 1].date.difference(calvings[i].date).inDays;
          intervals.add(interval);
        }
      }
    }
    if (intervals.isEmpty) return null;
    return intervals.average;
  }
}
