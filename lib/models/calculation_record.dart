class CalculationRecord {
  final String id; // ID único para cada registro
  final String indexName;
  final double value;
  final String unit;
  final DateTime date;
  final Map<String, String> inputs; // Valores de entrada do cálculo

  CalculationRecord({
    required this.id,
    required this.indexName,
    required this.value,
    required this.unit,
    required this.date,
    required this.inputs,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'indexName': indexName,
      'value': value,
      'unit': unit,
      'date': date.toIso8601String(),
      'inputs': inputs,
    };
  }

  factory CalculationRecord.fromJson(Map<String, dynamic> map) {
    return CalculationRecord(
      id: map['id'] ?? '', // Fallback para dados antigos sem ID
      indexName: map['indexName'],
      value: map['value'],
      unit: map['unit'],
      date: DateTime.parse(map['date']),
      inputs: Map<String, String>.from(map['inputs'] ?? {}), // Fallback
    );
  }
}