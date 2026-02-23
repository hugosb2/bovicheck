import 'package:uuid/uuid.dart';

class Lote {
  final String id;
  final String fazendaId;
  final String nome;
  final String descricao;
  final String tipo;
  final int capacidade;

  Lote({
    String? id,
    required this.fazendaId,
    required this.nome,
    this.descricao = '',
    this.tipo = 'Geral',
    this.capacidade = 0,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fazendaId': fazendaId,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo,
      'capacidade': capacidade,
    };
  }

  factory Lote.fromMap(Map<String, dynamic> map) {
    return Lote(
      id: map['id'],
      fazendaId: map['fazendaId'] ?? '',
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      tipo: map['tipo'] ?? 'Geral',
      capacidade: map['capacidade'] ?? 0,
    );
  }
}
