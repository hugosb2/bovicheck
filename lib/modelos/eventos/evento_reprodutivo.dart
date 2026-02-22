import 'package:uuid/uuid.dart';

class EventoReprodutivo {
  final String id;
  final String animalId;
  final DateTime data;
  final String tipo;
  final String? resultado;
  final String? observacao;

  EventoReprodutivo({
    String? id,
    required this.animalId,
    required this.data,
    required this.tipo,
    this.resultado,
    this.observacao,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'data': data.toIso8601String(),
      'tipo': tipo,
      'resultado': resultado,
      'observacao': observacao,
    };
  }

  factory EventoReprodutivo.fromMap(Map<String, dynamic> map) {
    return EventoReprodutivo(
      id: map['id'],
      animalId: map['animalId'] ?? '',
      data: DateTime.parse(map['data']),
      tipo: map['tipo'] ?? 'Desconhecido',
      resultado: map['resultado'],
      observacao: map['observacao'],
    );
  }
}
