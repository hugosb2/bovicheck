import 'package:uuid/uuid.dart';

class MedicationRecord {
  final String id;
  final DateTime date;
  final String productName;
  final String type;
  final String dose;
  final String? notes;

  MedicationRecord(
      {required this.id,
      required this.date,
      required this.productName,
      required this.type,
      required this.dose,
      this.notes});

  Map<String, dynamic> toMap({String? animalId}) {
    final map = {
      'id': id,
      'date': date.toIso8601String(),
      'productName': productName,
      'type': type,
      'dose': dose,
      'notes': notes,
    };
    if (animalId != null) {
      map['animalId'] = animalId;
    }
    return map;
  }

  factory MedicationRecord.fromMap(Map<String, dynamic> map) =>
      MedicationRecord(
        id: map['id'],
        date: DateTime.parse(map['date']),
        productName: map['productName'],
        type: map['type'],
        dose: map['dose'],
        notes: map['notes'],
      );

  Map<String, dynamic> toJson() => toMap();

  factory MedicationRecord.fromJson(Map<String, dynamic> json) =>
      MedicationRecord(
        id: json['id'] ?? const Uuid().v4(),
        date: DateTime.parse(json['date']),
        productName: json['productName'],
        type: json['type'],
        dose: json['dose'],
        notes: json['notes'],
      );
}
