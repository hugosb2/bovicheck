import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bovicheck/servicos/configuracao.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Configuracao.carregar();
  });

  group('Configuracao - chave da Groq', () {
    test('inicia sem chave quando não há prefs nem .env', () {
      expect(Configuracao.temChaveGroq, isFalse);
      expect(Configuracao.chaveGroq, isEmpty);
    });

    test('salva, lê e mascara a chave', () async {
      await Configuracao.salvarChaveGroq('  gsk_1234567890abcdef  ');

      expect(Configuracao.temChaveGroq, isTrue);
      expect(Configuracao.chaveGroq, 'gsk_1234567890abcdef');
      expect(Configuracao.chaveGroqMascarada, 'gsk_••••••••cdef');
      expect(Configuracao.chaveVeioDoEnv, isFalse);

      // Confirma persistência de verdade (recarrega do SharedPreferences)
      await Configuracao.carregar();
      expect(Configuracao.chaveGroq, 'gsk_1234567890abcdef');
    });

    test('remove a chave salva', () async {
      await Configuracao.salvarChaveGroq('gsk_1234567890abcdef');
      await Configuracao.removerChaveGroq();

      expect(Configuracao.temChaveGroq, isFalse);

      await Configuracao.carregar();
      expect(Configuracao.temChaveGroq, isFalse);
    });

    test('salvar chave vazia equivale a remover', () async {
      await Configuracao.salvarChaveGroq('gsk_1234567890abcdef');
      await Configuracao.salvarChaveGroq('   ');
      expect(Configuracao.temChaveGroq, isFalse);
    });
  });

  group('Configuracao - modelo da Groq', () {
    test('usa o modelo padrão por default', () {
      expect(Configuracao.modeloGroq, Configuracao.modeloGroqPadrao);
      expect(
        Configuracao.modelosGroq.containsKey(Configuracao.modeloGroqPadrao),
        isTrue,
      );
    });

    test('persiste o modelo escolhido', () async {
      await Configuracao.salvarModeloGroq('llama-3.1-8b-instant');
      expect(Configuracao.modeloGroq, 'llama-3.1-8b-instant');

      await Configuracao.carregar();
      expect(Configuracao.modeloGroq, 'llama-3.1-8b-instant');
    });

    test('ignora modelo desconhecido', () async {
      await Configuracao.salvarModeloGroq('modelo-inexistente');
      expect(Configuracao.modeloGroq, Configuracao.modeloGroqPadrao);
    });
  });
}
