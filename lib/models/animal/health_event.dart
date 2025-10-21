import 'package:uuid/uuid.dart';

class HealthEvent {
  final String id;
  final DateTime date;
  final String diagnosis;
  final String? treatment;
  final String? notes;

  HealthEvent(
      {required this.id,
      required this.date,
      required this.diagnosis,
      this.treatment,
      this.notes});

  Map<String, dynamic> toMap({String? animalId}) {
    final map = {
      'id': id,
      'date': date.toIso8601String(),
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
    };
    if (animalId != null) {
      map['animalId'] = animalId;
    }
    return map;
  }

  factory HealthEvent.fromMap(Map<String, dynamic> map) => HealthEvent(
        id: map['id'],
        date: DateTime.parse(map['date']),
        diagnosis: map['diagnosis'],
        treatment: map['treatment'],
        notes: map['notes'],
      );

  Map<String, dynamic> toJson() => toMap();

  factory HealthEvent.fromJson(Map<String, dynamic> json) => HealthEvent(
        id: json['id'] ?? const Uuid().v4(),
        date: DateTime.parse(json['date']),
        diagnosis: json['diagnosis'],
        treatment: json['treatment'],
        notes: json['notes'],
      );
}
