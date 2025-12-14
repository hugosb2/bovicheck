import 'package:uuid/uuid.dart';

class EventoSaude {
  final String id;
  final DateTime data;
  final String diagnostico;
  final String? tratamento;
  final String? observacoes;

  EventoSaude(
      {required this.id,
      required this.data,
      required this.diagnostico,
      this.tratamento,
      this.observacoes});

  Map<String, dynamic> toMap({String? animalId}) {
    final map = {
      'id': id,
      'date': data.toIso8601String(),
      'diagnosis': diagnostico,
      'treatment': tratamento,
      'notes': observacoes,
    };
    if (animalId != null) {
      map['animalId'] = animalId;
    }
    return map;
  }

  factory EventoSaude.fromMap(Map<String, dynamic> map) => EventoSaude(
        id: map['id'],
        data: DateTime.parse(map['date']),
        diagnostico: map['diagnosis'],
        tratamento: map['treatment'],
        observacoes: map['notes'],
      );

  Map<String, dynamic> toJson() => toMap();

  factory EventoSaude.fromJson(Map<String, dynamic> json) => EventoSaude(
        id: json['id'] ?? const Uuid().v4(),
        data: DateTime.parse(json['date']),
        diagnostico: json['diagnosis'],
        tratamento: json['treatment'],
        observacoes: json['notes'],
      );

  // Compatibilidade com nomes antigos
  DateTime get date => data;
  String get diagnosis => diagnostico;
  String? get treatment => tratamento;
  String? get notes => observacoes;
}

class HealthEvent extends EventoSaude {
  HealthEvent(
      {required super.id,
      required DateTime date,
      required String diagnosis,
      String? treatment,
      String? notes})
      : super(
            data: date,
            diagnostico: diagnosis,
            tratamento: treatment,
            observacoes: notes);

  factory HealthEvent.fromMap(Map<String, dynamic> map) {
    final r = EventoSaude.fromMap(map);
    return HealthEvent(
      id: r.id,
      date: r.data,
      diagnosis: r.diagnostico,
      treatment: r.tratamento,
      notes: r.observacoes,
    );
  }

  factory HealthEvent.fromJson(Map<String, dynamic> json) {
    final r = EventoSaude.fromJson(json);
    return HealthEvent(
      id: r.id,
      date: r.data,
      diagnosis: r.diagnostico,
      treatment: r.tratamento,
      notes: r.observacoes,
    );
  }
}
