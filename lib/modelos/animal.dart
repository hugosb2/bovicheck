class Animal {
  final String id;
  final String fazendaId;
  final String loteId;
  final String brinco;
  final String? nome;
  final String sexo; // 'M' ou 'F'
  final DateTime dataNascimento;
  final String raca;
  final String categoria;
  final double pesoAtualKg;
  final bool isAtivo;
  final String status; // 'Ativo', 'Morto', 'Vendido'
  final DateTime? dataObito;
  final String? causaObito;
  final String? paiId;
  final String? maeId;
  final DateTime? dataSaida;
  final String? motivoSaida;
  final double? pesoVendaKg;
  final double? valorVenda;

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
    this.isAtivo = true,
    this.status = 'Ativo',
    this.dataObito,
    this.causaObito,
    this.paiId,
    this.maeId,
    this.dataSaida,
    this.motivoSaida,
    this.pesoVendaKg,
    this.valorVenda,
  });

  // --- Métodos do Diagrama de Classes ---

  /// Retorna a idade do animal em meses completos.
  int calcularIdadeMeses() {
    final hoje = DateTime.now();
    final meses = (hoje.year - dataNascimento.year) * 12 +
        (hoje.month - dataNascimento.month);
    return meses > 0 ? meses : 0;
  }

  /// Retorna a idade do animal em dias.
  int calcularIdadeDias() {
    return DateTime.now().difference(dataNascimento).inDays;
  }

  /// Calcula o Ganho Médio Diário (GMD) em kg/dia desde o nascimento.
  /// Requer um peso inicial ou usa o pesoAtualKg com base nos dias de vida.
  double calcularGMD() {
    final dias = calcularIdadeDias();
    if (dias <= 0) return 0.0;
    return pesoAtualKg / dias;
  }

  /// Calcula o Intervalo Entre Partos (IEP) em dias.
  /// Retorna 0 se o animal não for fêmea ou não tiver dados reprodutivos.
  int calcularIEP() {
    // Lógica base; o valor real depende dos eventos reprodutivos do animal.
    return 0;
  }

  /// Estima a idade do primeiro parto em meses para fêmeas.
  /// Padrão de referência para bovinos de corte: ~24 meses.
  int estimarIdadePrimeiroParto() {
    if (sexo != 'F') return 0;
    return 24; // média padrão em meses
  }

  /// Registra o óbito do animal, retornando uma cópia atualizada.
  Animal registrarObito(DateTime data, String causa) {
    return Animal(
      id: id,
      fazendaId: fazendaId,
      loteId: loteId,
      brinco: brinco,
      nome: nome,
      raca: raca,
      sexo: sexo,
      categoria: categoria,
      dataNascimento: dataNascimento,
      pesoAtualKg: pesoAtualKg,
      isAtivo: false,
      status: 'Morto',
      dataObito: data,
      causaObito: causa,
      paiId: paiId,
      maeId: maeId,
    );
  }

  /// Retorna o status reprodutivo textual do animal.
  String getStatusReprodutivo() {
    if (sexo == 'M') return 'Reprodutor';
    switch (categoria.toLowerCase()) {
      case 'vaca':
        return 'Vaca em produção';
      case 'novilha':
        return 'Novilha';
      case 'bezerra':
        return 'Bezerra';
      default:
        return 'Não reprodutivo';
    }
  }

  /// Retorna o peso atual do animal (último registrado).
  double getUltimoPeso() => pesoAtualKg;

  /// Retorna a última produção de leite registrada.
  /// Requer integração com o banco de dados; retorna 0.0 por padrão.
  double getUltimaProducao() => 0.0;

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
      'status': status,
      'causaObito': causaObito,
      'paiId': paiId,
      'maeId': maeId,
      'dataSaida': dataSaida?.toIso8601String(),
      'motivoSaida': motivoSaida,
      'pesoVendaKg': pesoVendaKg,
      'valorVenda': valorVenda,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      fazendaId: map['fazendaId'] ?? '',
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
      status: map['status'] ?? 'Ativo',
      causaObito: map['causaObito'],
      paiId: map['paiId'],
      maeId: map['maeId'],
      dataSaida:
          map['dataSaida'] != null ? DateTime.parse(map['dataSaida']) : null,
      motivoSaida: map['motivoSaida'],
      pesoVendaKg: (map['pesoVendaKg'] as num?)?.toDouble(),
      valorVenda: (map['valorVenda'] as num?)?.toDouble(),
    );
  }
}
