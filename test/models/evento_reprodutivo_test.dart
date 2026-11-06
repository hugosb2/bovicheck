import 'package:flutter_test/flutter_test.dart';
import 'package:bovicheck/modelos/eventos/evento_reprodutivo.dart';

void main() {
  group('EventoReprodutivo.toMap / fromMap', () {
    test('round-trip com todos os campos', () {
      final original = EventoReprodutivo(
        id: 'evt_1',
        animalId: 'animal_1',
        data: DateTime(2025, 3, 15),
        tipo: 'Parto',
        resultado: 'Gemeos',
        observacao: 'Parto normal',
        progenieId: 'filhote_1',
        dataPrevistaParto: DateTime(2025, 3, 10),
        isPrimeiroParto: true,
      );
      final map = original.toMap();
      final reconstruido = EventoReprodutivo.fromMap(map);

      expect(reconstruido.id, original.id);
      expect(reconstruido.animalId, original.animalId);
      expect(reconstruido.data, original.data);
      expect(reconstruido.tipo, original.tipo);
      expect(reconstruido.resultado, original.resultado);
      expect(reconstruido.observacao, original.observacao);
      expect(reconstruido.progenieId, original.progenieId);
      expect(reconstruido.dataPrevistaParto, original.dataPrevistaParto);
      expect(reconstruido.isPrimeiroParto, original.isPrimeiroParto);
    });

    test('fromMap com campos minimos', () {
      final map = <String, dynamic>{
        'id': 'evt_2',
        'animalId': 'a1',
        'data': '2025-06-01T00:00:00.000',
        'tipo': 'Inseminação (IA)',
      };
      final evento = EventoReprodutivo.fromMap(map);
      expect(evento.id, 'evt_2');
      expect(evento.tipo, 'Inseminação (IA)');
      expect(evento.resultado, isNull);
      expect(evento.isPrimeiroParto, false);
    });

    test('fromMap com isPrimeiroParto como booleano true', () {
      final map = <String, dynamic>{
        'id': 'evt_3',
        'animalId': 'a1',
        'data': '2025-06-01T00:00:00.000',
        'tipo': 'Parto',
        'isPrimeiroParto': true,
      };
      final evento = EventoReprodutivo.fromMap(map);
      expect(evento.isPrimeiroParto, true);
    });

    test('tipo padrao quando ausente', () {
      final map = <String, dynamic>{
        'id': 'evt_4',
        'animalId': 'a1',
        'data': '2025-06-01T00:00:00.000',
      };
      final evento = EventoReprodutivo.fromMap(map);
      expect(evento.tipo, 'Desconhecido');
    });

    test('dataPrevistaParto null quando ausente', () {
      final map = <String, dynamic>{
        'id': 'evt_5',
        'animalId': 'a1',
        'data': '2025-06-01T00:00:00.000',
        'tipo': 'Parto',
      };
      final evento = EventoReprodutivo.fromMap(map);
      expect(evento.dataPrevistaParto, isNull);
    });
  });
}
