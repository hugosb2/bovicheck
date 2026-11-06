import 'package:flutter_test/flutter_test.dart';
import 'package:bovicheck/modelos/animal.dart';
import 'package:bovicheck/modelos/eventos/evento_reprodutivo.dart';

void main() {
  group('Animal.calcularIdadeMeses', () {
    test('retorna idade correta para animal nascido ha exatos 12 meses', () {
      final nascimento = DateTime.now().subtract(const Duration(days: 365));
      final animal = _criarAnimalFemea(dataNascimento: nascimento);
      expect(animal.calcularIdadeMeses(), greaterThanOrEqualTo(11));
    });

    test('retorna 0 para animal nascido hoje', () {
      final animal = _criarAnimalFemea(dataNascimento: DateTime.now());
      expect(animal.calcularIdadeMeses(), 0);
    });

    test('retorna 0 para data de nascimento futura', () {
      final futuro = DateTime.now().add(const Duration(days: 30));
      final animal = _criarAnimalFemea(dataNascimento: futuro);
      expect(animal.calcularIdadeMeses(), 0);
    });

    test('considera dia do mes no calculo', () {
      final hoje = DateTime.now();
      final mesPassado = DateTime(hoje.year, hoje.month - 1, hoje.day);
      final animal = _criarAnimalFemea(dataNascimento: mesPassado);
      expect(animal.calcularIdadeMeses(), 1);
    });
  });

  group('Animal.calcularGMD', () {
    test('retorna 0 para idade <= 0', () {
      final futuro = DateTime.now().add(const Duration(days: 1));
      final animal = _criarAnimalFemea(
        dataNascimento: futuro,
        pesoAtualKg: 100,
      );
      expect(animal.calcularGMD(), 0.0);
    });

    test('calcula GMD corretamente', () {
      final nascimento = DateTime.now().subtract(const Duration(days: 100));
      final animal = _criarAnimalFemea(
        dataNascimento: nascimento,
        pesoAtualKg: 50,
      );
      final gmd = animal.calcularGMD();
      expect(gmd, closeTo(0.5, 0.01));
    });
  });

  group('Animal.calcularIEP', () {
    test('retorna 0 para macho', () {
      final animal = _criarAnimalMacho();
      expect(animal.calcularIEP([]), 0.0);
    });

    test('retorna 0 para menos de 2 partos', () {
      final animal = _criarAnimalFemea();
      final parto = EventoReprodutivo(
        animalId: animal.id,
        data: DateTime(2024, 1, 1),
        tipo: 'Parto',
      );
      expect(animal.calcularIEP([parto]), 0.0);
    });

    test('calcula IEP com 2 partos', () {
      final animal = _criarAnimalFemea();
      final partos = [
        EventoReprodutivo(
          animalId: animal.id, data: DateTime(2024, 1, 1), tipo: 'Parto',
        ),
        EventoReprodutivo(
          animalId: animal.id, data: DateTime(2024, 12, 15), tipo: 'Parto',
        ),
      ];
      final iep = animal.calcularIEP(partos);
      expect(iep, greaterThan(0));
    });

    test('ignora partos de outros animais', () {
      final animal = _criarAnimalFemea();
      final partos = [
        EventoReprodutivo(
          animalId: 'outro_id', data: DateTime(2024, 1, 1), tipo: 'Parto',
        ),
        EventoReprodutivo(
          animalId: 'outro_id', data: DateTime(2024, 6, 1), tipo: 'Parto',
        ),
      ];
      expect(animal.calcularIEP(partos), 0.0);
    });
  });

  group('Animal.toMap / fromMap', () {
    test('round-trip preserva todos os campos', () {
      final original = _criarAnimalFemea(
        nome: 'Mimosa',
        pesoAtualKg: 450.0,
      );
      final map = original.toMap();
      final reconstruido = Animal.fromMap(map);
      expect(reconstruido.id, original.id);
      expect(reconstruido.brinco, original.brinco);
      expect(reconstruido.nome, original.nome);
      expect(reconstruido.raca, original.raca);
      expect(reconstruido.sexo, original.sexo);
      expect(reconstruido.pesoAtualKg, original.pesoAtualKg);
      expect(reconstruido.isAtivo, original.isAtivo);
    });

    test('fromMap com valores nulos', () {
      final map = <String, dynamic>{
        'id': '001',
        'fazendaId': 'faz1',
        'loteId': 'lote1',
        'brinco': '001',
        'nome': null,
        'raca': 'Nelore',
        'sexo': 'M',
        'categoria': 'Boi',
        'dataNascimento': '2023-06-15T00:00:00.000',
        'pesoAtualKg': 300.0,
        'isAtivo': 1,
      };
      final animal = Animal.fromMap(map);
      expect(animal.id, '001');
      expect(animal.nome, isNull);
      expect(animal.status, 'Ativo');
    });
  });

  group('Animal.registrarObito', () {
    test('cria copia com isAtivo false e dataObito', () {
      final animal = _criarAnimalFemea();
      final data = DateTime(2025, 3, 1);
      final obito = animal.registrarObito(data, 'Doenca');
      expect(obito.isAtivo, false);
      expect(obito.status, 'Morto');
      expect(obito.dataObito, data);
      expect(obito.causaObito, 'Doenca');
      expect(obito.id, animal.id);
    });
  });

  group('Animal.getStatusReprodutivo', () {
    test('macho retorna Reprodutor', () {
      final animal = _criarAnimalMacho();
      expect(animal.getStatusReprodutivo(), 'Reprodutor');
    });

    test('vaca retorna Vaca em producao', () {
      final animal = _criarAnimalFemea(categoria: 'Vaca');
      expect(animal.getStatusReprodutivo(), 'Vaca em produção');
    });
  });

  group('Animal.getUltimaProducao', () {
    test('retorna 0 para lista vazia', () {
      final animal = _criarAnimalFemea();
      expect(animal.getUltimaProducao([]), 0.0);
    });
  });
}

Animal _criarAnimalFemea({
  String? id,
  DateTime? dataNascimento,
  double pesoAtualKg = 200.0,
  String? nome,
  String categoria = 'Novilha',
}) {
  return Animal(
    id: id ?? 'test_id',
    fazendaId: 'faz1',
    loteId: 'lote1',
    brinco: '001',
    nome: nome,
    raca: 'Nelore',
    sexo: 'F',
    categoria: categoria,
    dataNascimento: dataNascimento ?? DateTime(2023, 1, 1),
    pesoAtualKg: pesoAtualKg,
  );
}

Animal _criarAnimalMacho({DateTime? dataNascimento}) {
  return Animal(
    id: 'test_macho',
    fazendaId: 'faz1',
    loteId: 'lote1',
    brinco: '002',
    nome: 'Touro',
    raca: 'Nelore',
    sexo: 'M',
    categoria: 'Touro',
    dataNascimento: dataNascimento ?? DateTime(2022, 6, 1),
    pesoAtualKg: 600.0,
  );
}
