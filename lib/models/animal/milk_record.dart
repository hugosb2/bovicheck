class MilkRecord {
  final String id;
  final DateTime date;
  final double morningProduction;
  final double afternoonProduction;
  final String? notes;

  MilkRecord({required this.id, required this.date, required this.morningProduction, required this.afternoonProduction, this.notes});

  double get totalProduction => morningProduction + afternoonProduction;

  Map<String, dynamic> toJson() => {'id': id, 'date': date.toIso8601String(), 'morningProduction': morningProduction, 'afternoonProduction': afternoonProduction, 'notes': notes};

  factory MilkRecord.fromJson(Map<String, dynamic> json) => MilkRecord(id: json['id'] ?? '', date: DateTime.parse(json['date']), morningProduction: (json['morningProduction'] as num).toDouble(), afternoonProduction: (json['afternoonProduction'] as num).toDouble(), notes: json['notes']);
}