class Animal {
  final String id;
  final String fazendaId; // Novo Campo
  final String loteId;
  final String brinco;
  final String? nome;
  final String raca;
  final String sexo; // 'M' ou 'F'
  final String categoria; // Novo Campo: 'Bezerro', 'Novilha', etc.
  final DateTime dataNascimento;
  final double pesoAtualKg; // Novo Campo
  final DateTime? dataObito;
  final bool isAtivo;

  // Calculado: Idade em meses
  int get idadeMeses {
    final hoje = DateTime.now();
    final meses = (hoje.year - dataNascimento.year) * 12 +
        (hoje.month - dataNascimento.month);
    return meses > 0 ? meses : 0;
  }

  Animal({
    required this.id,
    required this.fazendaId,
    required this.loteId,
    required this.brinco,
    this.nome,
    required this.raca,
    required this.sexo,
    required this.categoria,
    required this.dataNascimento,
    required this.pesoAtualKg,
    this.dataObito,
    this.isAtivo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fazendaId': fazendaId,
      'loteId': loteId,
      'brinco': brinco,
      'nome': nome,
      'raca': raca,
      'sexo': sexo,
      'categoria': categoria,
      'dataNascimento': dataNascimento.toIso8601String(),
      'pesoAtualKg': pesoAtualKg,
      'dataObito': dataObito?.toIso8601String(),
      'isAtivo': isAtivo ? 1 : 0,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      fazendaId: map['fazendaId'] ?? '', // Fallback seguro
      loteId: map['loteId'],
      brinco: map['brinco'],
      nome: map['nome'],
      raca: map['raca'],
      sexo: map['sexo'],
      categoria: map['categoria'] ?? 'Indefinido',
      dataNascimento: DateTime.parse(map['dataNascimento']),
      pesoAtualKg: (map['pesoAtualKg'] as num?)?.toDouble() ?? 0.0,
      dataObito:
          map['dataObito'] != null ? DateTime.parse(map['dataObito']) : null,
      isAtivo: map['isAtivo'] == 1,
    );
  }
}
