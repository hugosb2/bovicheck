import 'package:uuid/uuid.dart';

class ReproductiveEvent {
  final String id;
  final DateTime date;
  final String eventType;
  final String? result;
  final String? notes;

  ReproductiveEvent(
      {required this.id,
      required this.date,
      required this.eventType,
      this.result,
      this.notes});

  Map<String, dynamic> toMap({String? animalId}) {
    final map = {
      'id': id,
      'date': date.toIso8601String(),
      'eventType': eventType,
      'result': result,
      'notes': notes,
    };
    if (animalId != null) {
      map['animalId'] = animalId;
    }
    return map;
  }

  factory ReproductiveEvent.fromMap(Map<String, dynamic> map) =>
      ReproductiveEvent(
        id: map['id'],
        date: DateTime.parse(map['date']),
        eventType: map['eventType'],
        result: map['result'],
        notes: map['notes'],
      );

  Map<String, dynamic> toJson() => toMap();

  factory ReproductiveEvent.fromJson(Map<String, dynamic> json) =>
      ReproductiveEvent(
        id: json['id'] ?? const Uuid().v4(),
        date: DateTime.parse(json['date']),
        eventType: json['eventType'],
        result: json['result'],
        notes: json['notes'],
      );
}
