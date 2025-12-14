import 'package:uuid/uuid.dart';

class Lote {
  final String dbId;
  String identificador;
  String nome;
  String? descricao;
  double areaDestinada;
  final String propriedadeId;
  List<String> animaisIds;

  String get id => dbId;

  Lote({
    required this.dbId,
    required this.identificador,
    required this.nome,
    this.descricao,
    this.areaDestinada = 0.0,
    required this.propriedadeId,
    this.animaisIds = const [],
  });

  Map<String, dynamic> toMap() => {
        'dbId': dbId,
        'identificador': identificador,
        'nome': nome,
        'descricao': descricao,
        'areaDestinada': areaDestinada,
        'propriedadeId': propriedadeId,
        'animaisIds': animaisIds.join(','),
      };

  factory Lote.fromMap(Map<String, dynamic> map) => Lote(
        dbId: map['dbId'],
        identificador: map['identificador'],
        nome: map['nome'],
        descricao: map['descricao'],
        areaDestinada: map['areaDestinada'] != null
            ? (map['areaDestinada'] is double
                ? map['areaDestinada'] as double
                : (map['areaDestinada'] as num).toDouble())
            : 0.0,
        propriedadeId: map['propriedadeId'],
        animaisIds: map['animaisIds'] != null
            ? (map['animaisIds'] is String
                ? (map['animaisIds'] as String)
                    .split(',')
                    .where((s) => s.isNotEmpty)
                    .toList()
                : List<String>.from(map['animaisIds']))
            : [],
      );

  Map<String, dynamic> toJson() => toMap();

  factory Lote.fromJson(Map<String, dynamic> json) => Lote(
        dbId: json['dbId'] ?? const Uuid().v4(),
        identificador: json['identificador'] ?? '',
        nome: json['nome'] ?? '',
        descricao: json['descricao'],
        areaDestinada: json['areaDestinada'] != null
            ? (json['areaDestinada'] is double
                ? json['areaDestinada'] as double
                : (json['areaDestinada'] as num).toDouble())
            : 0.0,
        propriedadeId: json['propriedadeId'] ?? '',
        animaisIds: json['animaisIds'] != null
            ? (json['animaisIds'] is String
                ? (json['animaisIds'] as String)
                    .split(',')
                    .where((s) => s.isNotEmpty)
                    .toList()
                : List<String>.from(json['animaisIds']))
            : [],
      );
}
