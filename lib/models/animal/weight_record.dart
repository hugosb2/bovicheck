import 'package:uuid/uuid.dart';

class WeightRecord {
  final String id;
  final DateTime date;
  final double weight;
  final String? notes;

  WeightRecord(
      {required this.id, required this.date, required this.weight, this.notes});

  Map<String, dynamic> toMap({String? animalId}) {
    final map = {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'notes': notes,
    };
    if (animalId != null) {
      map['animalId'] = animalId;
    }
    return map;
  }

  factory WeightRecord.fromMap(Map<String, dynamic> map) => WeightRecord(
        id: map['id'],
        date: DateTime.parse(map['date']),
        weight: (map['weight'] as num).toDouble(),
        notes: map['notes'],
      );

  // Mantido para Backup/Restauração
  Map<String, dynamic> toJson() => toMap();
  factory WeightRecord.fromJson(Map<String, dynamic> json) => WeightRecord(
        id: json['id'] ?? const Uuid().v4(),
        date: DateTime.parse(json['date']),
        weight: (json['weight'] as num).toDouble(),
        notes: json['notes'],
      );
}
