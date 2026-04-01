import 'package:uuid/uuid.dart';
import 'animal.dart';

class Lote {
  final String id;
  final String fazendaId;
  final String nome;
  final String descricao;
  final String tipo;
  final int capacidade;
  final String sistemaProducao;
  final double areaHectares;

  Lote({
    String? id,
    required this.fazendaId,
    required this.nome,
    this.descricao = '',
    this.tipo = 'Geral',
    this.capacidade = 0,
    this.sistemaProducao = 'Extensivo',
    this.areaHectares = 0.0,
  }) : id = id ?? const Uuid().v4();

  // --- Métodos do Diagrama de Classes ---

  /// Adiciona um animal à lista fornecida (retorna nova lista imutável).
  List<Animal> adicionarAnimal(List<Animal> animais, Animal animal) {
    return [...animais, animal];
  }

  /// Calcula a taxa de mortalidade do lote dado uma lista de animais.
  double calcularTaxaMortalidade(List<Animal> animais) {
    if (animais.isEmpty) return 0.0;
    final mortos = animais.where((a) => a.status == 'Morto').length;
    return (mortos / animais.length) * 100;
  }

  /// Calcula a taxa de desmame (% de bezerros desmamados em relação às fêmeas paridas).
  double calcularTaxaDesmame(List<Animal> animais) {
    final femeas = animais.where((a) => a.sexo == 'F').length;
    if (femeas == 0) return 0.0;
    final desmamados =
        animais.where((a) => a.categoria.toLowerCase() == 'desmamado').length;
    return (desmamados / femeas) * 100;
  }

  /// Retorna a média de peso (kg) dos animais ativos do lote.
  double getMediaPeso(List<Animal> animais) {
    final ativos = animais.where((a) => a.isAtivo).toList();
    if (ativos.isEmpty) return 0.0;
    final soma = ativos.fold<double>(0.0, (acc, a) => acc + a.pesoAtualKg);
    return soma / ativos.length;
  }

  /// Retorna a lista de animais cujo peso está abaixo de um limite (padrão: 80% da média).
  List<Animal> getAnimaisAbaixoPeso(List<Animal> animais,
      {double? limiteKg}) {
    final media = getMediaPeso(animais);
    final limite = limiteKg ?? (media * 0.8);
    return animais
        .where((a) => a.isAtivo && a.pesoAtualKg < limite)
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fazendaId': fazendaId,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo,
      'capacidade': capacidade,
      'sistemaProducao': sistemaProducao,
      'areaHectares': areaHectares,
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
      sistemaProducao: map['sistemaProducao'] ?? 'Extensivo',
      areaHectares: (map['areaHectares'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

