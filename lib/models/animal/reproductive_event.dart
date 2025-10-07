class ReproductiveEvent {
  final String id;
  final DateTime date;
  final String eventType;
  final String? result;
  final String? notes;

  ReproductiveEvent({required this.id, required this.date, required this.eventType, this.result, this.notes});

  Map<String, dynamic> toJson() => {'id': id, 'date': date.toIso8601String(), 'eventType': eventType, 'result': result, 'notes': notes};

  factory ReproductiveEvent.fromJson(Map<String, dynamic> json) => ReproductiveEvent(id: json['id'] ?? '', date: DateTime.parse(json['date']), eventType: json['eventType'], result: json['result'], notes: json['notes']);
}