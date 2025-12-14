import 'package:uuid/uuid.dart';

class AreaPastagem {
  final String dbId;
  String nome;
  String? descricao;
  double areaDestinada;
  final String loteId;
  final String propriedadeId;
  List<String> animaisIds;

  AreaPastagem({
    String? dbId,
    required this.nome,
    this.descricao,
    this.areaDestinada = 0.0,
    required this.loteId,
    required this.propriedadeId,
    this.animaisIds = const [],
  }) : dbId = dbId ?? const Uuid().v4();

  String get id => dbId;

  Map<String, dynamic> toMap() => {
        'dbId': dbId,
        'nome': nome,
        'descricao': descricao,
        'areaDestinada': areaDestinada,
        'loteId': loteId,
        'propriedadeId': propriedadeId,
        'animaisIds': animaisIds.join(','),
      };

  factory AreaPastagem.fromMap(Map<String, dynamic> map) => AreaPastagem(
        dbId: map['dbId'] ?? map['id'],
        nome: map['nome'] ?? '',
        descricao: map['descricao'],
        areaDestinada: map['areaDestinada'] != null
            ? (map['areaDestinada'] is double
                ? map['areaDestinada'] as double
                : (map['areaDestinada'] as num).toDouble())
            : 0.0,
        loteId: map['loteId'] ?? '',
        propriedadeId: map['propriedadeId'] ?? '',
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

  factory AreaPastagem.fromJson(Map<String, dynamic> json) => AreaPastagem(
        dbId: json['dbId'] ?? const Uuid().v4(),
        nome: json['nome'] ?? '',
        descricao: json['descricao'],
        areaDestinada: json['areaDestinada'] != null
            ? (json['areaDestinada'] is double
                ? json['areaDestinada'] as double
                : (json['areaDestinada'] as num).toDouble())
            : 0.0,
        loteId: json['loteId'] ?? '',
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
