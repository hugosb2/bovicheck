import 'package:uuid/uuid.dart';

class EventoSanitario {
  final String id;
  final String animalId;
  final DateTime data;
  final String tipo;
  final String nomeProduto;
  final String? observacao;

  EventoSanitario({
    String? id,
    required this.animalId,
    required this.data,
    required this.tipo,
    required this.nomeProduto,
    this.observacao,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'data': data.toIso8601String(),
      'tipo': tipo,
      'nomeProduto': nomeProduto,
      'observacao': observacao,
    };
  }

  factory EventoSanitario.fromMap(Map<String, dynamic> map) {
    return EventoSanitario(
      id: map['id'],
      animalId: map['animalId'] ?? '',
      data: DateTime.parse(map['data']),
      tipo: map['tipo'] ?? 'Outro',
      nomeProduto: map['nomeProduto'] ?? '',
      observacao: map['observacao'],
    );
  }
}
