import 'package:uuid/uuid.dart';

class EventoSanitario {
  final String id;
  final String animalId;
  final DateTime data;
  final String tipo;
  final String? nomeMedicamento;
  final String? observacao;

  EventoSanitario({
    String? id,
    required this.animalId,
    required this.data,
    required this.tipo,
    this.nomeMedicamento,
    this.observacao,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'data': data.toIso8601String(),
      'tipo': tipo,
      'nomeMedicamento': nomeMedicamento,
      'observacao': observacao,
    };
  }

  factory EventoSanitario.fromMap(Map<String, dynamic> map) {
    return EventoSanitario(
      id: map['id'],
      animalId: map['animalId'] ?? '',
      data: DateTime.parse(map['data']),
      tipo: map['tipo'] ?? 'Outro',
      nomeMedicamento: map['nomeMedicamento'] ?? '',
      observacao: map['observacao'],
    );
  }
}
