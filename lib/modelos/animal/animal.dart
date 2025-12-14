// lib/models/animal/animal.dart

import 'package:bovicheck/modelos/animal/health_event.dart';
import 'package:bovicheck/modelos/animal/medication_record.dart';
import 'package:bovicheck/modelos/animal/milk_record.dart';
import 'package:bovicheck/modelos/animal/reproductive_event.dart';
import 'package:bovicheck/modelos/animal/weight_record.dart';
import 'package:uuid/uuid.dart';

enum AnimalStatus { ativo, vendido, morto }

class Animal {
  final String dbId;
  String brinco;
  String? nome;
  DateTime dataNascimento;
  String sexo;
  String? raca;
  String? loteId;
  AnimalStatus status;
  String? motivoSaida;
  DateTime? dataSaida;
  bool isDesmamado;
  DateTime? dataDesmame;

  List<WeightRecord> historicoPeso;
  List<MedicationRecord> historicoMedicacao;
  List<HealthEvent> historicoSaude;
  List<ReproductiveEvent> historicoReprodutivo;
  List<MilkRecord> historicoLeite;

  String get id => dbId;

  Animal({
    required this.dbId,
    required this.brinco,
    this.nome,
    required this.dataNascimento,
    required this.sexo,
    this.raca,
    this.loteId,
    this.status = AnimalStatus.ativo,
    this.motivoSaida,
    this.dataSaida,
    this.isDesmamado = false,
    this.dataDesmame,
    this.historicoPeso = const [],
    this.historicoMedicacao = const [],
    this.historicoSaude = const [],
    this.historicoReprodutivo = const [],
    this.historicoLeite = const [],
  });

  Map<String, dynamic> toMap() => {
        'dbId': dbId,
        'brinco': brinco,
        'nome': nome,
        'dataNascimento': dataNascimento.toIso8601String(),
        'sexo': sexo,
        'raca': raca,
        'loteId': loteId,
        'status': status.name,
        'motivoSaida': motivoSaida,
        'dataSaida': dataSaida?.toIso8601String(),
        'isDesmamado': isDesmamado ? 1 : 0,
        'dataDesmame': dataDesmame?.toIso8601String(),
      };

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      dbId: map['dbId'] ?? map['id'],
      brinco: map['brinco'],
      nome: map['nome'],
      dataNascimento: DateTime.parse(map['dataNascimento']),
      sexo: map['sexo'],
      raca: map['raca'],
      loteId: map['loteId'],
      status: AnimalStatus.values.firstWhere((e) => e.name == map['status'],
          orElse: () => AnimalStatus.ativo),
      motivoSaida: map['motivoSaida'],
      dataSaida:
          map['dataSaida'] != null ? DateTime.parse(map['dataSaida']) : null,
      isDesmamado: map['isDesmamado'] == 1,
      dataDesmame: map['dataDesmame'] != null
          ? DateTime.parse(map['dataDesmame'])
          : null,
      historicoPeso: [],
      historicoMedicacao: [],
      historicoSaude: [],
      historicoReprodutivo: [],
      historicoLeite: [],
    );
  }

  Map<String, dynamic> toJson() => {
        'dbId': dbId,
        'brinco': brinco,
        'nome': nome,
        'dataNascimento': dataNascimento.toIso8601String(),
        'sexo': sexo,
        'raca': raca,
        'loteId': loteId,
        'status': status.name,
        'motivoSaida': motivoSaida,
        'dataSaida': dataSaida?.toIso8601String(),
        'isDesmamado': isDesmamado,
        'dataDesmame': dataDesmame?.toIso8601String(),
        'historicoPeso': historicoPeso.map((e) => e.toJson()).toList(),
        'historicoMedicacao':
            historicoMedicacao.map((e) => e.toJson()).toList(),
        'historicoSaude': historicoSaude.map((e) => e.toJson()).toList(),
        'historicoReprodutivo':
            historicoReprodutivo.map((e) => e.toJson()).toList(),
        'historicoLeite': historicoLeite.map((e) => e.toJson()).toList(),
      };

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      dbId: json['dbId'] ?? json['id'] ?? const Uuid().v4(),
      brinco: json['brinco'] ?? '',
      nome: json['nome'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      sexo: json['sexo'] ?? 'Fêmea',
      raca: json['raca'],
      loteId: json['loteId'],
      status: AnimalStatus.values.firstWhere((e) => e.name == json['status'],
          orElse: () => AnimalStatus.ativo),
      motivoSaida: json['motivoSaida'],
      dataSaida:
          json['dataSaida'] != null ? DateTime.parse(json['dataSaida']) : null,
      isDesmamado: json['isDesmamado'] ?? false,
      dataDesmame: json['dataDesmame'] != null
          ? DateTime.parse(json['dataDesmame'])
          : null,
      historicoPeso: (json['historicoPeso'] as List? ?? [])
          .map((e) => WeightRecord.fromJson(e))
          .toList(),
      historicoMedicacao: (json['historicoMedicacao'] as List? ?? [])
          .map((e) => MedicationRecord.fromJson(e))
          .toList(),
      historicoSaude: (json['historicoSaude'] as List? ?? [])
          .map((e) => HealthEvent.fromJson(e))
          .toList(),
      historicoReprodutivo: (json['historicoReprodutivo'] as List? ?? [])
          .map((e) => ReproductiveEvent.fromJson(e))
          .toList(),
      historicoLeite: (json['historicoLeite'] as List? ?? [])
          .map((e) => MilkRecord.fromJson(e))
          .toList(),
    );
  }
}
