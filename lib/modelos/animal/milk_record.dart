import 'package:uuid/uuid.dart';

class RegistroLeite {
  final String id;
  final DateTime data;
  final double producaoManha;
  final double producaoTarde;
  final String? observacoes;

  RegistroLeite(
      {required this.id,
      required this.data,
      required this.producaoManha,
      required this.producaoTarde,
      this.observacoes});

  double get producaoTotal => producaoManha + producaoTarde;

  Map<String, dynamic> toMap({String? animalId}) {
    final map = {
      'id': id,
      'date': data.toIso8601String(),
      'morningProduction': producaoManha,
      'afternoonProduction': producaoTarde,
      'notes': observacoes,
    };
    if (animalId != null) {
      map['animalId'] = animalId;
    }
    return map;
  }

  factory RegistroLeite.fromMap(Map<String, dynamic> map) => RegistroLeite(
        id: map['id'],
        data: DateTime.parse(map['date']),
        producaoManha: (map['morningProduction'] as num).toDouble(),
        producaoTarde: (map['afternoonProduction'] as num).toDouble(),
        observacoes: map['notes'],
      );

  Map<String, dynamic> toJson() => toMap();

  factory RegistroLeite.fromJson(Map<String, dynamic> json) => RegistroLeite(
        id: json['id'] ?? const Uuid().v4(),
        data: DateTime.parse(json['date']),
        producaoManha: (json['morningProduction'] as num).toDouble(),
        producaoTarde: (json['afternoonProduction'] as num).toDouble(),
        observacoes: json['notes'],
      );

  // Compatibilidade com nomes antigos
  DateTime get date => data;
  double get morningProduction => producaoManha;
  double get afternoonProduction => producaoTarde;
  double get totalProduction => producaoTotal;
  String? get notes => observacoes;
}

class MilkRecord extends RegistroLeite {
  MilkRecord(
      {required super.id,
      required DateTime date,
      required double morningProduction,
      required double afternoonProduction,
      String? notes})
      : super(
            data: date,
            producaoManha: morningProduction,
            producaoTarde: afternoonProduction,
            observacoes: notes);

  factory MilkRecord.fromMap(Map<String, dynamic> map) {
    final r = RegistroLeite.fromMap(map);
    return MilkRecord(
        id: r.id,
        date: r.data,
        morningProduction: r.producaoManha,
        afternoonProduction: r.producaoTarde,
        notes: r.observacoes);
  }

  factory MilkRecord.fromJson(Map<String, dynamic> json) {
    final r = RegistroLeite.fromJson(json);
    return MilkRecord(
        id: r.id,
        date: r.data,
        morningProduction: r.producaoManha,
        afternoonProduction: r.producaoTarde,
        notes: r.observacoes);
  }
}
