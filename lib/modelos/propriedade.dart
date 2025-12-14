import 'package:uuid/uuid.dart';

class Propriedade {
  final String dbId;
  String identificador;
  String nome;
  String proprietario;
  String municipio;
  String estado;
  double areaTotal;

  String get id => dbId;

  Propriedade({
    required this.dbId,
    required this.identificador,
    required this.nome,
    required this.proprietario,
    required this.municipio,
    required this.estado,
    this.areaTotal = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'dbId': dbId,
        'identificador': identificador,
        'nome': nome,
        'proprietario': proprietario,
        'municipio': municipio,
        'estado': estado,
        'areaTotal': areaTotal,
      };

  factory Propriedade.fromMap(Map<String, dynamic> map) => Propriedade(
        dbId: map['dbId'] ?? map['id'],
        identificador: map['identificador'] ?? map['id'] ?? '',
        nome: map['nome'],
        proprietario: map['proprietario'],
        municipio: map['municipio'] ?? map['cidade'] ?? '',
        estado: map['estado'],
        areaTotal: map['areaTotal'] != null
            ? (map['areaTotal'] is double
                ? map['areaTotal'] as double
                : (map['areaTotal'] as num).toDouble())
            : 0.0,
      );

  Map<String, dynamic> toJson() => toMap();

  factory Propriedade.fromJson(Map<String, dynamic> json) => Propriedade(
        dbId: json['dbId'] ?? json['id'] ?? const Uuid().v4(),
        identificador: json['identificador'] ?? json['id'] ?? '',
        nome: json['nome'] ?? '',
        proprietario: json['proprietario'] ?? '',
        municipio: json['municipio'] ?? json['cidade'] ?? '',
        estado: json['estado'] ?? '',
        areaTotal: json['areaTotal'] != null
            ? (json['areaTotal'] is double
                ? json['areaTotal'] as double
                : (json['areaTotal'] as num).toDouble())
            : 0.0,
      );
}
