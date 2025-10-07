// lib/models/animal/animal.dart

import 'package:bovicheck/models/animal/health_event.dart';
import 'package:bovicheck/models/animal/medication_record.dart';
import 'package:bovicheck/models/animal/milk_record.dart';
import 'package:bovicheck/models/animal/reproductive_event.dart';
import 'package:bovicheck/models/animal/weight_record.dart';

enum AnimalStatus { ativo, vendido, morto }

class Animal {
  final String id;
  String brinco;
  String? nome;
  DateTime dataNascimento;
  String sexo;
  String? raca;
  String? idMae;
  String? idPai;
  String? loteId; // Adicionado
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

  Animal({
    required this.id,
    required this.brinco,
    this.nome,
    required this.dataNascimento,
    required this.sexo,
    this.raca,
    this.idMae,
    this.idPai,
    this.loteId, // Adicionado
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'brinco': brinco,
        'nome': nome,
        'dataNascimento': dataNascimento.toIso8601String(),
        'sexo': sexo,
        'raca': raca,
        'idMae': idMae,
        'idPai': idPai,
        'loteId': loteId, // Adicionado
        'status': status.name,
        'motivoSaida': motivoSaida,
        'dataSaida': dataSaida?.toIso8601String(),
        'isDesmamado': isDesmamado,
        'dataDesmame': dataDesmame?.toIso8601String(),
        'historicoPeso': historicoPeso.map((e) => e.toJson()).toList(),
        'historicoMedicacao': historicoMedicacao.map((e) => e.toJson()).toList(),
        'historicoSaude': historicoSaude.map((e) => e.toJson()).toList(),
        'historicoReprodutivo': historicoReprodutivo.map((e) => e.toJson()).toList(),
        'historicoLeite': historicoLeite.map((e) => e.toJson()).toList(),
      };

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      brinco: json['brinco'],
      nome: json['nome'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      sexo: json['sexo'],
      raca: json['raca'],
      idMae: json['idMae'],
      idPai: json['idPai'],
      loteId: json['loteId'], // Adicionado
      status: AnimalStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => AnimalStatus.ativo),
      motivoSaida: json['motivoSaida'],
      dataSaida: json['dataSaida'] != null ? DateTime.parse(json['dataSaida']) : null,
      isDesmamado: json['isDesmamado'] ?? false,
      dataDesmame: json['dataDesmame'] != null ? DateTime.parse(json['dataDesmame']) : null,
      historicoPeso: (json['historicoPeso'] as List? ?? []).map((e) => WeightRecord.fromJson(e)).toList(),
      historicoMedicacao: (json['historicoMedicacao'] as List? ?? []).map((e) => MedicationRecord.fromJson(e)).toList(),
      historicoSaude: (json['historicoSaude'] as List? ?? []).map((e) => HealthEvent.fromJson(e)).toList(),
      historicoReprodutivo: (json['historicoReprodutivo'] as List? ?? []).map((e) => ReproductiveEvent.fromJson(e)).toList(),
      historicoLeite: (json['historicoLeite'] as List? ?? []).map((e) => MilkRecord.fromJson(e)).toList(),
    );
  }
}