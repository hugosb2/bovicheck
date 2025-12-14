enum PerformanceIndexType {
  ganhoMedioDiario,
  conversaoAlimentar,
  rendimentoDeCarcaca,
}

class EventoDesempenho {
  final String id;
  final DateTime data;
  final PerformanceIndexType tipo;
  final String? observacoes;

  final Map<String, dynamic> entradas;

  final double resultado;
  final String unidade;

  EventoDesempenho({
    required this.id,
    required this.data,
    required this.tipo,
    required this.entradas,
    required this.resultado,
    required this.unidade,
    this.observacoes,
  });

  String get nome {
    switch (tipo) {
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
        'date': data.toIso8601String(),
        'type': tipo.name,
        'notes': observacoes,
        'inputs': entradas,
        'result': resultado,
        'unit': unidade,
      };

  factory EventoDesempenho.fromJson(Map<String, dynamic> json) =>
      EventoDesempenho(
        id: json['id'],
        data: DateTime.parse(json['date']),
        tipo: PerformanceIndexType.values
            .firstWhere((e) => e.name == json['type']),
        entradas: Map<String, dynamic>.from(json['inputs']),
        resultado: (json['result'] as num).toDouble(),
        unidade: json['unit'],
        observacoes: json['notes'],
      );

  // Compatibilidade com nomes antigos
  DateTime get date => data;
  PerformanceIndexType get type => tipo;
  Map<String, dynamic> get inputs => entradas;
  double get result => resultado;
  String get unit => unidade;
  String? get notes => observacoes;
}

class PerformanceEvent extends EventoDesempenho {
  PerformanceEvent(
      {required super.id,
      required DateTime date,
      required PerformanceIndexType type,
      required Map<String, dynamic> inputs,
      required double result,
      required String unit,
      String? notes})
      : super(
            data: date,
            tipo: type,
            entradas: inputs,
            resultado: result,
            unidade: unit,
            observacoes: notes);

  factory PerformanceEvent.fromJson(Map<String, dynamic> json) {
    final r = EventoDesempenho.fromJson(json);
    return PerformanceEvent(
      id: r.id,
      date: r.data,
      type: r.tipo,
      inputs: r.entradas,
      result: r.resultado,
      unit: r.unidade,
      notes: r.observacoes,
    );
  }
}
