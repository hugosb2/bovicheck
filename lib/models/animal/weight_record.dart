class WeightRecord {
  final String id;
  final DateTime date;
  final double weight;
  final String? notes;

  WeightRecord({required this.id, required this.date, required this.weight, this.notes});

  Map<String, dynamic> toJson() => {'id': id, 'date': date.toIso8601String(), 'weight': weight, 'notes': notes};

  factory WeightRecord.fromJson(Map<String, dynamic> json) => WeightRecord(id: json['id'] ?? '', date: DateTime.parse(json['date']), weight: (json['weight'] as num).toDouble(), notes: json['notes']);
}