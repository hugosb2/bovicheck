import 'package:uuid/uuid.dart';

class Lote {
  final String id;
  final String propriedadeId;
  final String nome;
  final String descricao;
  final String tipo;

  Lote({
    String? id,
    required this.propriedadeId,
    required this.nome,
    this.descricao = '',
    this.tipo = 'Geral',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propriedadeId': propriedadeId,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo,
    };
  }

  factory Lote.fromMap(Map<String, dynamic> map) {
    return Lote(
      id: map['id'],
      propriedadeId: map['propriedadeId'] ?? '',
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      tipo: map['tipo'] ?? 'Geral',
    );
  }
}
