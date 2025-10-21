import 'package:uuid/uuid.dart';

class MilkRecord {
  final String id;
  final DateTime date;
  final double morningProduction;
  final double afternoonProduction;
  final String? notes;

  MilkRecord(
      {required this.id,
      required this.date,
      required this.morningProduction,
      required this.afternoonProduction,
      this.notes});

  double get totalProduction => morningProduction + afternoonProduction;

  Map<String, dynamic> toMap({String? animalId}) {
    final map = {
      'id': id,
      'date': date.toIso8601String(),
      'morningProduction': morningProduction,
      'afternoonProduction': afternoonProduction,
      'notes': notes,
    };
    if (animalId != null) {
      map['animalId'] = animalId;
    }
    return map;
  }

  factory MilkRecord.fromMap(Map<String, dynamic> map) => MilkRecord(
        id: map['id'],
        date: DateTime.parse(map['date']),
        morningProduction: (map['morningProduction'] as num).toDouble(),
        afternoonProduction: (map['afternoonProduction'] as num).toDouble(),
        notes: map['notes'],
      );

  Map<String, dynamic> toJson() => toMap();

  factory MilkRecord.fromJson(Map<String, dynamic> json) => MilkRecord(
        id: json['id'] ?? const Uuid().v4(),
        date: DateTime.parse(json['date']),
        morningProduction: (json['morningProduction'] as num).toDouble(),
        afternoonProduction: (json['afternoonProduction'] as num).toDouble(),
        notes: json['notes'],
      );
}
