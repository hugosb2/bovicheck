// lib/models/lote.dart

class Lote {
  final String id;
  String nome;
  String? descricao;

  Lote({
    required this.id,
    required this.nome,
    this.descricao,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'descricao': descricao,
  };

  factory Lote.fromJson(Map<String, dynamic> json) => Lote(
    id: json['id'],
    nome: json['nome'],
    descricao: json['descricao'],
  );
}