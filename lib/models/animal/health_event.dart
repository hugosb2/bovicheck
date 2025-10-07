class HealthEvent {
  final String id;
  final DateTime date;
  final String diagnosis;
  final String? treatment;
  final String? notes;

  HealthEvent({required this.id, required this.date, required this.diagnosis, this.treatment, this.notes});

  Map<String, dynamic> toJson() => {'id': id, 'date': date.toIso8601String(), 'diagnosis': diagnosis, 'treatment': treatment, 'notes': notes};

  factory HealthEvent.fromJson(Map<String, dynamic> json) => HealthEvent(id: json['id'] ?? '', date: DateTime.parse(json['date']), diagnosis: json['diagnosis'], treatment: json['treatment'], notes: json['notes']);
}