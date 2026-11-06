import 'package:flutter_test/flutter_test.dart';
import 'package:bovicheck/modelos/eventos/pesagem.dart';

void main() {
  group('Pesagem.toMap / fromMap', () {
    test('round-trip preserva todos os campos', () {
      final original = Pesagem(
        id: 'pesagem_1',
        animalId: 'animal_1',
        data: DateTime(2025, 6, 1, 10, 0),
        pesoKg: 350.5,
        etapa: 'Geral',
        observacao: 'Pesagem de rotina',
      );
      final map = original.toMap();
      final reconstruido = Pesagem.fromMap(map);

      expect(reconstruido.id, original.id);
      expect(reconstruido.animalId, original.animalId);
      expect(reconstruido.data, original.data);
      expect(reconstruido.pesoKg, original.pesoKg);
      expect(reconstruido.etapa, original.etapa);
      expect(reconstruido.observacao, original.observacao);
    });

    test('fromMap com valores padrao', () {
      final map = <String, dynamic>{
        'id': 'p1',
        'animalId': 'a1',
        'data': '2025-01-15T00:00:00.000',
        'pesoKg': 300.0,
      };
      final pesagem = Pesagem.fromMap(map);
      expect(pesagem.id, 'p1');
      expect(pesagem.animalId, 'a1');
      expect(pesagem.etapa, 'Geral');
      expect(pesagem.observacao, isNull);
    });

    test('fromMap com animalId vazio', () {
      final map = <String, dynamic>{
        'id': 'p1',
        'data': '2025-01-15T00:00:00.000',
        'pesoKg': 300.0,
      };
      final pesagem = Pesagem.fromMap(map);
      expect(pesagem.animalId, '');
    });
  });

  group('Pesagem.id', () {
    test('gera UUID quando id nao fornecido', () {
      final pesagem = Pesagem(
        animalId: 'a1',
        data: DateTime(2025, 1, 1),
        pesoKg: 400.0,
      );
      expect(pesagem.id, isNotEmpty);
    });
  });
}
