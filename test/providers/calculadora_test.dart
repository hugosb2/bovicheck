import 'package:flutter_test/flutter_test.dart';
import 'package:bovicheck/modelos/animal.dart';
import 'package:bovicheck/modelos/eventos/pesagem.dart';
import 'package:bovicheck/modelos/eventos/evento_reprodutivo.dart';
import 'package:bovicheck/modelos/eventos/producao_leite.dart';
import 'package:bovicheck/servicos/calculadora_indicadores.dart';

void main() {
  final inicio = DateTime(2025, 1, 1);
  final fim = DateTime(2025, 12, 31);

  group('CalculadoraIndicadores.taxaNatalidade', () {
    test('retorna 0 quando sem femeas aptas', () {
      final calc = CalculadoraIndicadores(
        animais: [
          Animal(id: 'm1', fazendaId: 'f1', loteId: 'l1', brinco: '001',
            raca: 'Nelore', sexo: 'M', categoria: 'Touro',
            dataNascimento: DateTime(2020, 1, 1), pesoAtualKg: 600),
        ],
        pesagens: [], reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.taxaNatalidade, 0.0);
    });

    test('calcula natalidade corretamente', () {
      final femeaVelha = Animal(id: 'f1', fazendaId: 'f1', loteId: 'l1',
        brinco: '001', raca: 'Nelore', sexo: 'F', categoria: 'Vaca',
        dataNascimento: DateTime(2020, 1, 1), pesoAtualKg: 450);
      final parto = EventoReprodutivo(
        animalId: 'f1', data: DateTime(2025, 3, 1), tipo: 'Parto',
      );
      final calc = CalculadoraIndicadores(
        animais: [femeaVelha],
        pesagens: [], reprodutivos: [parto], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.taxaNatalidade, 100.0);
    });
  });

  group('CalculadoraIndicadores.taxaPrenhez', () {
    test('retorna 0 sem diagnosticos', () {
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.taxaPrenhez, 0.0);
    });

    test('calcula prenhez corretamente', () {
      final diagnosticos = [
        EventoReprodutivo(animalId: 'f1', data: DateTime(2025, 2, 1),
          tipo: 'Diagnóstico Gestação', resultado: 'Positivo'),
        EventoReprodutivo(animalId: 'f2', data: DateTime(2025, 3, 1),
          tipo: 'Diagnóstico Gestação', resultado: 'Negativo'),
      ];
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: diagnosticos, leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.taxaPrenhez, 50.0);
    });
  });

  group('CalculadoraIndicadores.gmdNascDesmame', () {
    test('retorna 0 sem pesagens', () {
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.gmdNascDesmame, 0.0);
    });

    test('calcula GMD medio com 2 pesagens', () {
      final pesagens = [
        Pesagem(animalId: 'a1', data: DateTime(2025, 1, 1), pesoKg: 200.0),
        Pesagem(animalId: 'a1', data: DateTime(2025, 2, 1), pesoKg: 230.0),
      ];
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: pesagens, reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      final gmd = calc.gmdNascDesmame;
      expect(gmd, greaterThan(0));
      // 230 - 200 = 30 kg em 31 dias ≈ 0.9677
      expect(gmd, closeTo(0.9677, 0.01));
    });

    test('ignora pesagens com menos de 7 dias de diferenca', () {
      final pesagens = [
        Pesagem(animalId: 'a1', data: DateTime(2025, 1, 1), pesoKg: 200.0),
        Pesagem(animalId: 'a1', data: DateTime(2025, 1, 3), pesoKg: 205.0),
      ];
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: pesagens, reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.gmdNascDesmame, 0.0);
    });
  });

  group('CalculadoraIndicadores.taxaDesmame', () {
    test('retorna 0 sem nascimentos no periodo', () {
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.taxaDesmame, 0.0);
    });

    test('calcula taxa de desmame com progenieId', () {
      final reprodutivos = [
        EventoReprodutivo(animalId: 'mae1', data: DateTime(2025, 2, 1),
          tipo: 'Parto', progenieId: 'filhote1'),
        EventoReprodutivo(animalId: 'filhote1', data: DateTime(2025, 6, 1),
          tipo: 'Desmame'),
      ];
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: reprodutivos, leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.taxaDesmame, 100.0);
    });

    test('sem progenieId, usa proporcao de desmames sobre nascimentos', () {
      final reprodutivos = [
        EventoReprodutivo(animalId: 'mae1', data: DateTime(2025, 2, 1),
          tipo: 'Parto'),
        EventoReprodutivo(animalId: 'filhote1', data: DateTime(2025, 6, 1),
          tipo: 'Desmame'),
      ];
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: reprodutivos, leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.taxaDesmame, 100.0);
    });

    test('sem progenieId e sem desmames, retorna 0', () {
      final reprodutivos = [
        EventoReprodutivo(animalId: 'mae1', data: DateTime(2025, 2, 1),
          tipo: 'Parto'),
      ];
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: reprodutivos, leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.taxaDesmame, 0.0);
    });
  });

  group('CalculadoraIndicadores.taxaMortalidade', () {
    test('retorna 0 sem obitos', () {
      final animais = [
        Animal(id: 'a1', fazendaId: 'f1', loteId: 'l1', brinco: '001',
          raca: 'Nelore', sexo: 'F', categoria: 'Vaca',
          dataNascimento: DateTime(2020, 1, 1), pesoAtualKg: 450),
      ];
      final calc = CalculadoraIndicadores(
        animais: animais, pesagens: [], reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.taxaMortalidade, 0.0);
    });

    test('calcula mortalidade corretamente', () {
      final animais = [
        Animal(id: 'a1', fazendaId: 'f1', loteId: 'l1', brinco: '001',
          raca: 'Nelore', sexo: 'F', categoria: 'Vaca',
          dataNascimento: DateTime(2020, 1, 1), pesoAtualKg: 450),
        Animal(id: 'a2', fazendaId: 'f1', loteId: 'l1', brinco: '002',
          raca: 'Nelore', sexo: 'M', categoria: 'Boi',
          dataNascimento: DateTime(2021, 1, 1), pesoAtualKg: 500,
          isAtivo: false, dataObito: DateTime(2025, 3, 1)),
      ];
      final calc = CalculadoraIndicadores(
        animais: animais, pesagens: [], reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.taxaMortalidade, 50.0);
    });
  });

  group('CalculadoraIndicadores.mediaLeiteDia', () {
    test('retorna 0 sem producao', () {
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.mediaLeiteDia, 0.0);
    });

    test('calcula media de leite por vaca/dia', () {
      final producoes = [
        ProducaoLeite(animalId: 'v1', data: DateTime(2025, 6, 1, 6, 0),
          litros: 12.0, periodo: 'Manhã'),
        ProducaoLeite(animalId: 'v1', data: DateTime(2025, 6, 1, 14, 0),
          litros: 8.0, periodo: 'Tarde'),
        ProducaoLeite(animalId: 'v2', data: DateTime(2025, 6, 1, 6, 0),
          litros: 10.0, periodo: 'Manhã'),
      ];
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: [], leite: producoes,
        inicio: inicio, fim: fim,
      );
      // v1: 20L, v2: 10L → media = 30/2 = 15L
      expect(calc.mediaLeiteDia, closeTo(15.0, 0.01));
    });
  });

  group('CalculadoraIndicadores.iepMeses', () {
    test('retorna 0 sem partos', () {
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.iepMeses, 0.0);
    });

    test('calcula IEP medio com 2 partos da mesma vaca', () {
      final partos = [
        EventoReprodutivo(animalId: 'v1', data: DateTime(2024, 1, 1),
          tipo: 'Parto'),
        EventoReprodutivo(animalId: 'v1', data: DateTime(2025, 3, 1),
          tipo: 'Parto'),
      ];
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: partos, leite: [],
        inicio: inicio, fim: fim,
      );
      final iep = calc.iepMeses;
      expect(iep, greaterThan(0));
    });
  });

  group('CalculadoraIndicadores.status', () {
    test('status neutro quando nao ha dados', () {
      final calc = CalculadoraIndicadores(
        animais: [], pesagens: [], reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.getStatusNatalidade(), StatusIndicador.neutro);
      expect(calc.getStatusPrenhez(), StatusIndicador.neutro);
      expect(calc.getStatusIEP(), StatusIndicador.neutro);
      expect(calc.getStatusGMD(), StatusIndicador.neutro);
      expect(calc.getStatusDesmame(), StatusIndicador.neutro);
    });

    test('mortalidade baixa e considerada boa', () {
      final animais = [
        Animal(id: 'a1', fazendaId: 'f1', loteId: 'l1', brinco: '001',
          raca: 'Nelore', sexo: 'F', categoria: 'Vaca',
          dataNascimento: DateTime(2020, 1, 1), pesoAtualKg: 450),
      ];
      final calc = CalculadoraIndicadores(
        animais: animais, pesagens: [], reprodutivos: [], leite: [],
        inicio: inicio, fim: fim,
      );
      expect(calc.getStatusMortalidade(), StatusIndicador.bom);
    });
  });
}
