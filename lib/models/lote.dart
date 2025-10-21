import 'package:uuid/uuid.dart';

class Lote {
  final String id;
  String nome;
  String? descricao;
  final String propriedadeId;

  Lote({
    required this.id,
    required this.nome,
    this.descricao,
    required this.propriedadeId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'propriedadeId': propriedadeId,
      };

  factory Lote.fromMap(Map<String, dynamic> map) => Lote(
        id: map['id'],
        nome: map['nome'],
        descricao: map['descricao'],
        propriedadeId: map['propriedadeId'],
      );

  Map<String, dynamic> toJson() => toMap();

  factory Lote.fromJson(Map<String, dynamic> json) => Lote(
        id: json['id'] ?? const Uuid().v4(),
        nome: json['nome'] ?? '',
        descricao: json['descricao'],
        propriedadeId: json['propriedadeId'] ?? '',
      );
}
