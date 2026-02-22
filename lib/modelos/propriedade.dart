import 'package:uuid/uuid.dart';

class Propriedade {
  final String id;
  final String nomeFazenda;
  final String nomeProprietario;
  final String cidade;
  final String estado;
  final double? gpsLat;
  final double? gpsLong;
  final String sistemaProducao;
  final double areaTotalHectares;

  Propriedade({
    String? id,
    required this.nomeFazenda,
    required this.nomeProprietario,
    required this.cidade,
    required this.estado,
    required this.sistemaProducao,
    this.gpsLat,
    this.gpsLong,
    this.areaTotalHectares = 0.0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeFazenda': nomeFazenda,
      'nomeProprietario': nomeProprietario,
      'cidade': cidade,
      'estado': estado,
      'gpsLat': gpsLat,
      'gpsLong': gpsLong,
      'sistemaProducao': sistemaProducao,
      'areaTotalHectares': areaTotalHectares,
    };
  }

  factory Propriedade.fromMap(Map<String, dynamic> map) {
    return Propriedade(
      id: map['id'],
      nomeFazenda: map['nomeFazenda'] ?? '',
      nomeProprietario: map['nomeProprietario'] ?? '',
      cidade: map['cidade'] ?? '',
      estado: map['estado'] ?? '',
      sistemaProducao: map['sistemaProducao'] ?? 'Extensivo',
      gpsLat: map['gpsLat'],
      gpsLong: map['gpsLong'],
      areaTotalHectares: (map['areaTotalHectares'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
