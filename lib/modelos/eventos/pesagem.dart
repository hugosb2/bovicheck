import 'package:uuid/uuid.dart';

class Pesagem {
  final String id;
  final String animalId;
  final DateTime data;
  final double pesoKg;
  final String etapa;
  final String? observacao;

  Pesagem({
    String? id,
    required this.animalId,
    required this.data,
    required this.pesoKg,
    this.etapa = 'Geral',
    this.observacao,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'data': data.toIso8601String(),
      'pesoKg': pesoKg,
      'etapa': etapa,
      'observacao': observacao,
    };
  }

  factory Pesagem.fromMap(Map<String, dynamic> map) {
    return Pesagem(
      id: map['id'],
      animalId: map['animalId'] ?? '',
      data: DateTime.parse(map['data']),
      pesoKg: (map['pesoKg'] as num).toDouble(),
      etapa: map['etapa'] ?? 'Geral',
      observacao: map['observacao'],
    );
  }
}
