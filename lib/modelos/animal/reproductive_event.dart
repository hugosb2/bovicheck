import 'package:uuid/uuid.dart';

class EventoReproducao {
  final String id;
  final DateTime data;
  final String tipoEvento;
  final String? resultado;
  final String? observacoes;

  EventoReproducao(
      {required this.id,
      required this.data,
      required this.tipoEvento,
      this.resultado,
      this.observacoes});

  Map<String, dynamic> toMap({String? animalId}) {
    final map = {
      'id': id,
      'date': data.toIso8601String(),
      'eventType': tipoEvento,
      'result': resultado,
      'notes': observacoes,
    };
    if (animalId != null) {
      map['animalId'] = animalId;
    }
    return map;
  }

  factory EventoReproducao.fromMap(Map<String, dynamic> map) =>
      EventoReproducao(
        id: map['id'],
        data: DateTime.parse(map['date']),
        tipoEvento: map['eventType'],
        resultado: map['result'],
        observacoes: map['notes'],
      );

  Map<String, dynamic> toJson() => toMap();

  factory EventoReproducao.fromJson(Map<String, dynamic> json) =>
      EventoReproducao(
        id: json['id'] ?? const Uuid().v4(),
        data: DateTime.parse(json['date']),
        tipoEvento: json['eventType'],
        resultado: json['result'],
        observacoes: json['notes'],
      );

  // Compatibilidade com nomes antigos
  DateTime get date => data;
  String get eventType => tipoEvento;
  String? get result => resultado;
  String? get notes => observacoes;
}

class ReproductiveEvent extends EventoReproducao {
  ReproductiveEvent(
      {required super.id,
      required DateTime date,
      required String eventType,
      String? result,
      String? notes})
      : super(
            data: date,
            tipoEvento: eventType,
            resultado: result,
            observacoes: notes);

  factory ReproductiveEvent.fromMap(Map<String, dynamic> map) {
    final r = EventoReproducao.fromMap(map);
    return ReproductiveEvent(
      id: r.id,
      date: r.data,
      eventType: r.tipoEvento,
      result: r.resultado,
      notes: r.observacoes,
    );
  }

  factory ReproductiveEvent.fromJson(Map<String, dynamic> json) {
    final r = EventoReproducao.fromJson(json);
    return ReproductiveEvent(
      id: r.id,
      date: r.data,
      eventType: r.tipoEvento,
      result: r.resultado,
      notes: r.observacoes,
    );
  }
}
