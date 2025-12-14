import 'package:uuid/uuid.dart';

class RegistroPeso {
  final String id;
  final DateTime data;
  final double peso;
  final String? observacoes;

  RegistroPeso(
      {required this.id,
      required this.data,
      required this.peso,
      this.observacoes});

  Map<String, dynamic> toMap({String? animalId}) {
    final map = {
      'id': id,
      'date': data.toIso8601String(),
      'weight': peso,
      'notes': observacoes,
    };
    if (animalId != null) {
      map['animalId'] = animalId;
    }
    return map;
  }

  factory RegistroPeso.fromMap(Map<String, dynamic> map) => RegistroPeso(
        id: map['id'],
        data: DateTime.parse(map['date']),
        peso: (map['weight'] as num).toDouble(),
        observacoes: map['notes'],
      );

  // Mantido para Backup/Restauração
  Map<String, dynamic> toJson() => toMap();
  factory RegistroPeso.fromJson(Map<String, dynamic> json) => RegistroPeso(
        id: json['id'] ?? const Uuid().v4(),
        data: DateTime.parse(json['date']),
        peso: (json['weight'] as num).toDouble(),
        observacoes: json['notes'],
      );

  // Compatibilidade com nomes antigos
  DateTime get date => data;
  double get weight => peso;
  String? get notes => observacoes;
}

// Compatibilidade: mantém o nome antigo apontando para a nova implementação
class WeightRecord extends RegistroPeso {
  WeightRecord(
      {required super.id,
      required DateTime date,
      required double weight,
      String? notes})
      : super(data: date, peso: weight, observacoes: notes);

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    final r = RegistroPeso.fromMap(map);
    return WeightRecord(
        id: r.id, date: r.data, weight: r.peso, notes: r.observacoes);
  }

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    final r = RegistroPeso.fromJson(json);
    return WeightRecord(
        id: r.id, date: r.data, weight: r.peso, notes: r.observacoes);
  }
}
