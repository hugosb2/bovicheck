import 'package:uuid/uuid.dart';

class RegistroMedicacao {
  final String id;
  final DateTime data;
  final String nomeProduto;
  final String tipo;
  final String dose;
  final String? observacoes;

  RegistroMedicacao(
      {required this.id,
      required this.data,
      required this.nomeProduto,
      required this.tipo,
      required this.dose,
      this.observacoes});

  Map<String, dynamic> toMap({String? animalId}) {
    final map = {
      'id': id,
      'date': data.toIso8601String(),
      'productName': nomeProduto,
      'type': tipo,
      'dose': dose,
      'notes': observacoes,
    };
    if (animalId != null) {
      map['animalId'] = animalId;
    }
    return map;
  }

  factory RegistroMedicacao.fromMap(Map<String, dynamic> map) =>
      RegistroMedicacao(
        id: map['id'],
        data: DateTime.parse(map['date']),
        nomeProduto: map['productName'],
        tipo: map['type'],
        dose: map['dose'],
        observacoes: map['notes'],
      );

  Map<String, dynamic> toJson() => toMap();

  factory RegistroMedicacao.fromJson(Map<String, dynamic> json) =>
      RegistroMedicacao(
        id: json['id'] ?? const Uuid().v4(),
        data: DateTime.parse(json['date']),
        nomeProduto: json['productName'],
        tipo: json['type'],
        dose: json['dose'],
        observacoes: json['notes'],
      );

  // Compatibilidade com nomes antigos
  DateTime get date => data;
  String get productName => nomeProduto;
  String get type => tipo;
  String get doseValue => dose;
  String? get notes => observacoes;
}

class MedicationRecord extends RegistroMedicacao {
  MedicationRecord(
      {required super.id,
      required DateTime date,
      required String productName,
      required String type,
      required super.dose,
      String? notes})
      : super(
            data: date,
            nomeProduto: productName,
            tipo: type,
            observacoes: notes);

  factory MedicationRecord.fromMap(Map<String, dynamic> map) {
    final r = RegistroMedicacao.fromMap(map);
    return MedicationRecord(
      id: r.id,
      date: r.data,
      productName: r.nomeProduto,
      type: r.tipo,
      dose: r.dose,
      notes: r.observacoes,
    );
  }

  factory MedicationRecord.fromJson(Map<String, dynamic> json) {
    final r = RegistroMedicacao.fromJson(json);
    return MedicationRecord(
      id: r.id,
      date: r.data,
      productName: r.nomeProduto,
      type: r.tipo,
      dose: r.dose,
      notes: r.observacoes,
    );
  }
}
