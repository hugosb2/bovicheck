enum PerformanceIndexType {
  ganhoMedioDiario,
  conversaoAlimentar,
  rendimentoDeCarcaca,
}

class PerformanceEvent {
  final String id;
  final DateTime date;
  final PerformanceIndexType type;
  final String? notes;

  final Map<String, dynamic> inputs;

  final double result;
  final String unit;

  PerformanceEvent({
    required this.id,
    required this.date,
    required this.type,
    required this.inputs,
    required this.result,
    required this.unit,
    this.notes,
  });

  String get name {
    switch (type) {
      case PerformanceIndexType.ganhoMedioDiario:
        return 'Ganho Médio Diário (GMD)';
      case PerformanceIndexType.conversaoAlimentar:
        return 'Conversão Alimentar';
      case PerformanceIndexType.rendimentoDeCarcaca:
        return 'Rendimento de Carcaça';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.name,
        'notes': notes,
        'inputs': inputs,
        'result': result,
        'unit': unit,
      };

  factory PerformanceEvent.fromJson(Map<String, dynamic> json) =>
      PerformanceEvent(
        id: json['id'],
        date: DateTime.parse(json['date']),
        type: PerformanceIndexType.values
            .firstWhere((e) => e.name == json['type']),
        inputs: Map<String, dynamic>.from(json['inputs']),
        result: (json['result'] as num).toDouble(),
        unit: json['unit'],
        notes: json['notes'],
      );
}
