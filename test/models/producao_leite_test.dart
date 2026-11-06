import 'package:flutter_test/flutter_test.dart';
import 'package:bovicheck/modelos/eventos/producao_leite.dart';

void main() {
  group('ProducaoLeite.toMap / fromMap', () {
    test('round-trip com todos os campos', () {
      final original = ProducaoLeite(
        id: 'leite_1',
        animalId: 'animal_1',
        data: DateTime(2025, 6, 1, 6, 0),
        litros: 12.5,
        periodo: 'Manhã',
        observacao: 'Produção normal',
      );
      final map = original.toMap();
      final reconstruido = ProducaoLeite.fromMap(map);

      expect(reconstruido.id, original.id);
      expect(reconstruido.animalId, original.animalId);
      expect(reconstruido.data, original.data);
      expect(reconstruido.litros, original.litros);
      expect(reconstruido.periodo, original.periodo);
      expect(reconstruido.observacao, original.observacao);
    });

    test('fromMap com campos minimos', () {
      final map = <String, dynamic>{
        'id': 'leite_2',
        'animalId': 'a1',
        'data': '2025-06-01T00:00:00.000',
        'litros': 10.0,
      };
      final producao = ProducaoLeite.fromMap(map);
      expect(producao.periodo, 'Manhã');
      expect(producao.observacao, isNull);
    });
  });
}
