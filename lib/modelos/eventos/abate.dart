import 'package:uuid/uuid.dart';

class Abate {
  final String id;
  final String animalId;
  final DateTime data;
  final double pesoVivoKg;
  final double pesoCarcacaKg;
  final String? observacao;

  Abate({
    String? id,
    required this.animalId,
    required this.data,
    required this.pesoVivoKg,
    required this.pesoCarcacaKg,
    this.observacao,
  }) : id = id ?? const Uuid().v4();

  double calcularRendimento() {
    if (pesoVivoKg <= 0) return 0.0;
    return (pesoCarcacaKg / pesoVivoKg) * 100;
  }

  int calcularDiasDesdeAbate() {
    return DateTime.now().difference(data).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'data': data.toIso8601String(),
      'pesoVivoKg': pesoVivoKg,
      'pesoCarcacaKg': pesoCarcacaKg,
      'observacao': observacao,
    };
  }

  factory Abate.fromMap(Map<String, dynamic> map) {
    return Abate(
      id: map['id'],
      animalId: map['animalId'] ?? '',
      data: DateTime.parse(map['data']),
      pesoVivoKg: (map['pesoVivoKg'] as num).toDouble(),
      pesoCarcacaKg: (map['pesoCarcacaKg'] as num).toDouble(),
      observacao: map['observacao'],
    );
  }
}
