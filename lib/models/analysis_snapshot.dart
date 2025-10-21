import 'dart:convert';
import 'package:uuid/uuid.dart';

class AnalysisSnapshot {
  final String id;
  final DateTime date;
  final Map<String, double?> results;

  AnalysisSnapshot({
    required this.id,
    required this.date,
    required this.results,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'results': jsonEncode(results),
      };

  factory AnalysisSnapshot.fromMap(Map<String, dynamic> map) =>
      AnalysisSnapshot(
        id: map['id'],
        date: DateTime.parse(map['date']),
        results: Map<String, double?>.from(jsonDecode(map['results'])),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'results': results,
      };

  factory AnalysisSnapshot.fromJson(Map<String, dynamic> json) =>
      AnalysisSnapshot(
        id: json['id'] ?? const Uuid().v4(),
        date: DateTime.parse(json['date']),
        results: Map<String, double?>.from(json['results']),
      );
}
