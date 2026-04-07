import 'package:uuid/uuid.dart';

class ProducaoLeite {
  final String id;
  final String animalId;
  final DateTime data;
  final double litros;
  final String? observacao;
  final String periodo;

  ProducaoLeite({
    String? id,
    required this.animalId,
    required this.data,
    required this.litros,
    this.observacao,
    this.periodo = 'Manhã',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'data': data.toIso8601String(),
      'litros': litros,
      'periodo': periodo,
      'observacao': observacao,
    };
  }

  factory ProducaoLeite.fromMap(Map<String, dynamic> map) {
    return ProducaoLeite(
      id: map['id'],
      animalId: map['animalId'] ?? '',
      data: DateTime.parse(map['data']),
      litros: (map['litros'] as num).toDouble(),
      periodo: map['periodo'] ?? 'Manhã',
      observacao: map['observacao'],
    );
  }
}
