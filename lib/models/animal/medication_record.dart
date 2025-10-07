class MedicationRecord {
  final String id;
  final DateTime date;
  final String productName;
  final String type;
  final String dose;
  final String? notes;

  MedicationRecord({required this.id, required this.date, required this.productName, required this.type, required this.dose, this.notes});

  Map<String, dynamic> toJson() => {'id': id, 'date': date.toIso8601String(), 'productName': productName, 'type': type, 'dose': dose, 'notes': notes};

  factory MedicationRecord.fromJson(Map<String, dynamic> json) => MedicationRecord(id: json['id'] ?? '', date: DateTime.parse(json['date']), productName: json['productName'], type: json['type'], dose: json['dose'], notes: json['notes']);
}