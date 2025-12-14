import 'dart:convert';
import 'package:uuid/uuid.dart';

class AnaliseInstantanea {
  final String id;
  final DateTime data;
  final Map<String, double?> resultados;

  AnaliseInstantanea({
    required this.id,
    required this.data,
    required this.resultados,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': data.toIso8601String(),
        'results': jsonEncode(resultados),
      };

  factory AnaliseInstantanea.fromMap(Map<String, dynamic> map) =>
      AnaliseInstantanea(
        id: map['id'],
        data: DateTime.parse(map['date']),
        resultados: Map<String, double?>.from(jsonDecode(map['results'])),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': data.toIso8601String(),
        'results': resultados,
      };

  factory AnaliseInstantanea.fromJson(Map<String, dynamic> json) =>
      AnaliseInstantanea(
        id: json['id'] ?? const Uuid().v4(),
        data: DateTime.parse(json['date']),
        resultados: Map<String, double?>.from(json['results']),
      );
}

class AnalysisSnapshot extends AnaliseInstantanea {
  AnalysisSnapshot(
      {required super.id,
      required DateTime date,
      required Map<String, double?> results})
      : super(data: date, resultados: results);

  // Compatibilidade: getters com nomes antigos
  DateTime get date => data;
  Map<String, double?> get results => resultados;

  factory AnalysisSnapshot.fromMap(Map<String, dynamic> map) =>
      AnalysisSnapshot(
        id: map['id'],
        date: DateTime.parse(map['date']),
        results: Map<String, double?>.from(jsonDecode(map['results'])),
      );

  factory AnalysisSnapshot.fromJson(Map<String, dynamic> json) =>
      AnalysisSnapshot(
        id: json['id'] ?? const Uuid().v4(),
        date: DateTime.parse(json['date']),
        results: Map<String, double?>.from(json['results']),
      );
}
