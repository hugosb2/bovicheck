import 'package:flutter_test/flutter_test.dart';
import 'package:bovicheck/modelos/eventos/evento_sanitario.dart';

void main() {
  group('EventoSanitario.toMap / fromMap', () {
    test('round-trip com todos os campos', () {
      final original = EventoSanitario(
        id: 'san_1',
        animalId: 'animal_1',
        data: DateTime(2025, 4, 10),
        tipo: 'Vacinação',
        nomeMedicamento: 'Aftosa',
        dose: '5ml',
        observacao: 'Dose unique',
      );
      final map = original.toMap();
      final reconstruido = EventoSanitario.fromMap(map);

      expect(reconstruido.id, original.id);
      expect(reconstruido.animalId, original.animalId);
      expect(reconstruido.data, original.data);
      expect(reconstruido.tipo, original.tipo);
      expect(reconstruido.nomeMedicamento, original.nomeMedicamento);
      expect(reconstruido.dose, original.dose);
      expect(reconstruido.observacao, original.observacao);
    });

    test('fromMap com campos minimos', () {
      final map = <String, dynamic>{
        'id': 'san_2',
        'animalId': 'a1',
        'data': '2025-06-01T00:00:00.000',
        'tipo': 'Doença',
      };
      final evento = EventoSanitario.fromMap(map);
      expect(evento.nomeMedicamento, '');
      expect(evento.dose, isNull);
      expect(evento.observacao, isNull);
    });

    test('tipo padrao quando ausente', () {
      final map = <String, dynamic>{
        'id': 'san_3',
        'animalId': 'a1',
        'data': '2025-06-01T00:00:00.000',
      };
      final evento = EventoSanitario.fromMap(map);
      expect(evento.tipo, 'Outro');
    });
  });
}
