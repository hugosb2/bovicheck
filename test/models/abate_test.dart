import 'package:flutter_test/flutter_test.dart';
import 'package:bovicheck/modelos/eventos/abate.dart';

void main() {
  group('Abate.calcularRendimento', () {
    test('calcula rendimento corretamente', () {
      final abate = Abate(
        id: 'abate_1',
        animalId: 'animal_1',
        data: DateTime(2025, 6, 1),
        pesoVivoKg: 500.0,
        pesoCarcacaKg: 260.0,
      );
      expect(abate.calcularRendimento(), closeTo(52.0, 0.01));
    });

    test('retorna 0 quando pesoVivoKg <= 0', () {
      final abate = Abate(
        animalId: 'a1',
        data: DateTime(2025, 1, 1),
        pesoVivoKg: 0,
        pesoCarcacaKg: 100,
      );
      expect(abate.calcularRendimento(), 0.0);
    });

    test('retorna 0 quando pesoVivoKg negativo', () {
      final abate = Abate(
        animalId: 'a1',
        data: DateTime(2025, 1, 1),
        pesoVivoKg: -10,
        pesoCarcacaKg: 100,
      );
      expect(abate.calcularRendimento(), 0.0);
    });
  });

  group('Abate.toMap / fromMap', () {
    test('round-trip preserva todos os campos', () {
      final original = Abate(
        id: 'abate_1',
        animalId: 'animal_1',
        data: DateTime(2025, 6, 1, 8, 30),
        pesoVivoKg: 500.0,
        pesoCarcacaKg: 260.0,
        observacao: 'Abate programado',
      );
      final map = original.toMap();
      final reconstruido = Abate.fromMap(map);

      expect(reconstruido.id, original.id);
      expect(reconstruido.animalId, original.animalId);
      expect(reconstruido.data, original.data);
      expect(reconstruido.pesoVivoKg, original.pesoVivoKg);
      expect(reconstruido.pesoCarcacaKg, original.pesoCarcacaKg);
      expect(reconstruido.observacao, original.observacao);
    });

    test('fromMap com campos minimos', () {
      final map = <String, dynamic>{
        'id': 'a1',
        'animalId': 'animal_1',
        'data': '2025-01-15T00:00:00.000',
        'pesoVivoKg': 450.0,
        'pesoCarcacaKg': 230.0,
      };
      final abate = Abate.fromMap(map);
      expect(abate.observacao, isNull);
    });
  });
}
