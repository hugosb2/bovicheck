import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bovicheck/modelos/propriedade.dart';
import 'package:bovicheck/modelos/piquete.dart';
import 'package:bovicheck/modelos/animal.dart';
import 'package:bovicheck/modelos/eventos/pesagem.dart';
import 'package:bovicheck/modelos/eventos/evento_reprodutivo.dart';
import 'package:bovicheck/modelos/eventos/producao_leite.dart';
import 'package:bovicheck/modelos/eventos/evento_sanitario.dart';

Database? _db;

const _sqlTabelas = [
  '''CREATE TABLE IF NOT EXISTS propriedades (
    id TEXT PRIMARY KEY, nomeFazenda TEXT NOT NULL,
    nomeProprietario TEXT NOT NULL, cidade TEXT, estado TEXT,
    cep TEXT, sistemaProducao TEXT NOT NULL DEFAULT 'Extensivo',
    areaTotalHectares REAL DEFAULT 0,
    areaProducaoHectares REAL DEFAULT 0,
    areaUtilizadaHectares REAL DEFAULT 0, gpsLat REAL, gpsLong REAL
  )''',
  '''CREATE TABLE IF NOT EXISTS lotes (
    id TEXT PRIMARY KEY, fazendaId TEXT NOT NULL, nome TEXT NOT NULL,
    descricao TEXT NOT NULL DEFAULT '', tipo TEXT NOT NULL,
    capacidade INTEGER NOT NULL DEFAULT 0,
    sistemaProducao TEXT NOT NULL DEFAULT 'Extensivo',
    areaHectares REAL DEFAULT 0
  )''',
  '''CREATE TABLE IF NOT EXISTS animais (
    id TEXT PRIMARY KEY, fazendaId TEXT NOT NULL, loteId TEXT NOT NULL,
    brinco TEXT NOT NULL, nome TEXT, raca TEXT NOT NULL,
    sexo TEXT NOT NULL, categoria TEXT NOT NULL,
    dataNascimento TEXT NOT NULL, pesoAtualKg REAL NOT NULL,
    isAtivo INTEGER NOT NULL DEFAULT 1, status TEXT DEFAULT 'Ativo',
    dataObito TEXT, causaObito TEXT, paiId TEXT, maeId TEXT,
    dataSaida TEXT, motivoSaida TEXT, pesoVendaKg REAL, valorVenda REAL
  )''',
  '''CREATE TABLE IF NOT EXISTS pesagens (
    id TEXT PRIMARY KEY, animalId TEXT NOT NULL, data TEXT NOT NULL,
    pesoKg REAL NOT NULL, etapa TEXT NOT NULL, observacao TEXT
  )''',
  '''CREATE TABLE IF NOT EXISTS eventos_reprodutivos (
    id TEXT PRIMARY KEY, animalId TEXT NOT NULL, data TEXT NOT NULL,
    tipo TEXT NOT NULL, resultado TEXT, observacao TEXT,
    progenieId TEXT, dataPrevistaParto TEXT,
    isPrimeiroParto INTEGER DEFAULT 0
  )''',
  '''CREATE TABLE IF NOT EXISTS eventos_sanitarios (
    id TEXT PRIMARY KEY, animalId TEXT NOT NULL, data TEXT NOT NULL,
    tipo TEXT NOT NULL, nomeMedicamento TEXT, dose TEXT, observacao TEXT
  )''',
  '''CREATE TABLE IF NOT EXISTS abates (
    id TEXT PRIMARY KEY, animalId TEXT NOT NULL, data TEXT NOT NULL,
    pesoVivoKg REAL NOT NULL, pesoCarcacaKg REAL NOT NULL, observacao TEXT
  )''',
  '''CREATE TABLE IF NOT EXISTS producao_leite (
    id TEXT PRIMARY KEY, animalId TEXT NOT NULL, data TEXT NOT NULL,
    litros REAL NOT NULL, periodo TEXT NOT NULL, observacao TEXT
  )''',
];

Future<void> _iniciarDB() async {
  sqfliteFfiInit();
  _db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  for (final sql in _sqlTabelas) {
    await _db!.execute(sql);
  }
}

void main() {
  setUp(() async => await _iniciarDB());
  tearDown(() async { await _db?.close(); _db = null; });

  group('Fluxo 1: Cadastrar animal -> Registrar pesagem -> Verificar peso', () {
    test('fluxo completo de pesagem atualiza peso do animal', () async {
      final prop = Propriedade(nomeFazenda: 'Faz A', nomeProprietario: 'João',
          cidade: 'Campo Grande', estado: 'MS', sistemaProducao: 'Extensivo');
      await _db!.insert('propriedades', prop.toMap());

      final piquete = Piquete(fazendaId: prop.id, nome: 'Pasto 1', tipo: 'Pastagem', capacidade: 50);
      await _db!.insert('lotes', piquete.toMap());

      final animal = Animal(id: '001', fazendaId: prop.id, loteId: piquete.id,
          brinco: '001', raca: 'Nelore', sexo: 'F', categoria: 'Vaca',
          dataNascimento: DateTime(2020, 1, 1), pesoAtualKg: 400.0);
      await _db!.insert('animais', animal.toMap());

      final pesagem = Pesagem(animalId: '001', data: DateTime(2025, 6, 1), pesoKg: 450.0);
      await _db!.insert('pesagens', pesagem.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      await _db!.update('animais', {'pesoAtualKg': 450.0}, where: 'id = ?', whereArgs: ['001']);

      final rows = await _db!.query('animais', where: 'id = ?', whereArgs: ['001']);
      final atualizado = Animal.fromMap(rows.first);
      expect(atualizado.pesoAtualKg, 450.0);
    });
  });

  group('Fluxo 2: Evento reprodutivo (Parto -> Desmame)', () {
    test('cria fêmea, registra parto e desmame', () async {
      final prop = Propriedade(nomeFazenda: 'Faz B', nomeProprietario: 'Maria', cidade: 'Cuiabá', estado: 'MT', sistemaProducao: 'Extensivo');
      await _db!.insert('propriedades', prop.toMap());

      final piquete = Piquete(fazendaId: prop.id, nome: 'Matrizes', tipo: 'Pasto', capacidade: 30);
      await _db!.insert('lotes', piquete.toMap());

      final mae = Animal(id: 'v001', fazendaId: prop.id, loteId: piquete.id,
          brinco: 'V001', raca: 'Angus', sexo: 'F', categoria: 'Vaca',
          dataNascimento: DateTime(2019, 3, 1), pesoAtualKg: 500.0);
      final bezerro = Animal(id: 'b001', fazendaId: prop.id, loteId: piquete.id,
          brinco: 'B001', raca: 'Angus', sexo: 'M', categoria: 'Bezerro',
          dataNascimento: DateTime(2025, 2, 1), pesoAtualKg: 80.0);
      await _db!.insert('animais', mae.toMap());
      await _db!.insert('animais', bezerro.toMap());

      final parto = EventoReprodutivo(animalId: 'v001', data: DateTime(2025, 2, 1),
          tipo: 'Parto', resultado: 'Simples', progenieId: 'b001');
      await _db!.insert('eventos_reprodutivos', parto.toMap());

      final desmame = EventoReprodutivo(animalId: 'b001', data: DateTime(2025, 6, 1),
          tipo: 'Desmame');
      await _db!.insert('eventos_reprodutivos', desmame.toMap());

      for (final id in ['v001', 'b001']) {
        final eventos = await _db!.query('eventos_reprodutivos',
            where: 'animalId = ?', whereArgs: [id], orderBy: 'data ASC');
        expect(eventos, isNotEmpty);
      }
    });
  });

  group('Fluxo 3: Produção de leite', () {
    test('registra e recupera produção de leite', () async {
      final prop = Propriedade(nomeFazenda: 'Faz C', nomeProprietario: 'José', cidade: 'Uberaba', estado: 'MG', sistemaProducao: 'Extensivo');
      await _db!.insert('propriedades', prop.toMap());

      final animal = Animal(id: 'vaca1', fazendaId: prop.id, loteId: 'l1',
          brinco: 'V001', raca: 'Girolando', sexo: 'F', categoria: 'Vaca',
          dataNascimento: DateTime(2021, 1, 1), pesoAtualKg: 550.0);
      await _db!.insert('animais', animal.toMap());

      await _db!.insert('producao_leite', ProducaoLeite(animalId: 'vaca1',
          data: DateTime(2025, 6, 1, 6, 0), litros: 12.5, periodo: 'Manhã').toMap());
      await _db!.insert('producao_leite', ProducaoLeite(animalId: 'vaca1',
          data: DateTime(2025, 6, 1, 14, 0), litros: 8.0, periodo: 'Tarde').toMap());

      final rows = await _db!.query('producao_leite', where: 'animalId = ?', whereArgs: ['vaca1']);
      expect(rows.length, 2);

      final totalLitros = rows.fold(0.0, (sum, r) => sum + (r['litros'] as num).toDouble());
      expect(totalLitros, closeTo(20.5, 0.01));
    });
  });

  group('Fluxo 4: Evento sanitário', () {
    test('registra e recupera vacinação', () async {
      final prop = Propriedade(nomeFazenda: 'Faz D', nomeProprietario: 'Pedro', cidade: 'Ribeirão', estado: 'SP', sistemaProducao: 'Extensivo');
      await _db!.insert('propriedades', prop.toMap());

      final animal = Animal(id: 'a1', fazendaId: prop.id, loteId: 'l1',
          brinco: '001', raca: 'Nelore', sexo: 'M', categoria: 'Boi',
          dataNascimento: DateTime(2022, 1, 1), pesoAtualKg: 600.0);
      await _db!.insert('animais', animal.toMap());

      await _db!.insert('eventos_sanitarios', EventoSanitario(animalId: 'a1',
          data: DateTime(2025, 4, 10), tipo: 'Vacinação', nomeMedicamento: 'Aftosa',
          dose: '5ml').toMap());

      final rows = await _db!.query('eventos_sanitarios', where: 'animalId = ?', whereArgs: ['a1']);
      expect(rows.length, 1);
      expect(rows.first['nomeMedicamento'], 'Aftosa');
    });
  });

  group('Fluxo 6: Indicadores com dados completos', () {
    test('calcula indicadores a partir de dados reais', () async {
      final prop = Propriedade(nomeFazenda: 'Faz E', nomeProprietario: 'Ana', cidade: 'Campo Grande', estado: 'MS', sistemaProducao: 'Extensivo');
      await _db!.insert('propriedades', prop.toMap());

      final lote = Piquete(fazendaId: prop.id, nome: 'Rebanho', tipo: 'Pasto', capacidade: 100);
      await _db!.insert('lotes', lote.toMap());

      final femea = Animal(id: 'f1', fazendaId: prop.id, loteId: lote.id,
          brinco: 'F001', raca: 'Nelore', sexo: 'F', categoria: 'Vaca',
          dataNascimento: DateTime(2019, 3, 1), pesoAtualKg: 480.0);
      final femea2 = Animal(id: 'f2', fazendaId: prop.id, loteId: lote.id,
          brinco: 'F002', raca: 'Nelore', sexo: 'F', categoria: 'Vaca',
          dataNascimento: DateTime(2018, 5, 1), pesoAtualKg: 500.0);
      final macho = Animal(id: 'm1', fazendaId: prop.id, loteId: lote.id,
          brinco: 'M001', raca: 'Nelore', sexo: 'M', categoria: 'Boi',
          dataNascimento: DateTime(2021, 1, 1), pesoAtualKg: 650.0);
      await _db!.insert('animais', femea.toMap());
      await _db!.insert('animais', femea2.toMap());
      await _db!.insert('animais', macho.toMap());

      final inicio = DateTime(2025, 1, 1);
      final fim = DateTime(2025, 12, 31);

      await _db!.insert('pesagens',
          Pesagem(animalId: 'f1', data: DateTime(2025, 1, 1), pesoKg: 450.0).toMap());
      await _db!.insert('pesagens',
          Pesagem(animalId: 'f1', data: DateTime(2025, 6, 1), pesoKg: 480.0).toMap());
      await _db!.insert('pesagens',
          Pesagem(animalId: 'f2', data: DateTime(2025, 3, 1), pesoKg: 480.0).toMap());
      await _db!.insert('pesagens',
          Pesagem(animalId: 'f2', data: DateTime(2025, 9, 1), pesoKg: 500.0).toMap());

      await _db!.insert('eventos_reprodutivos',
          EventoReprodutivo(animalId: 'f1', data: DateTime(2025, 2, 1), tipo: 'Parto').toMap());
      await _db!.insert('eventos_reprodutivos',
          EventoReprodutivo(animalId: 'f2', data: DateTime(2025, 4, 1), tipo: 'Parto').toMap());

      await _db!.insert('producao_leite',
          ProducaoLeite(animalId: 'f1', data: DateTime(2025, 6, 1, 6, 0), litros: 12.0, periodo: 'Manhã').toMap());
      await _db!.insert('producao_leite',
          ProducaoLeite(animalId: 'f1', data: DateTime(2025, 6, 1, 14, 0), litros: 8.0, periodo: 'Tarde').toMap());
      await _db!.insert('producao_leite',
          ProducaoLeite(animalId: 'f2', data: DateTime(2025, 6, 1, 6, 0), litros: 10.0, periodo: 'Manhã').toMap());

      final animais = await _db!.query('animais');
      expect(animais.length, 3);

      final pesagens = await _db!.query('pesagens',
          where: 'data >= ? AND data <= ?', whereArgs: [inicio.toIso8601String(), fim.toIso8601String()]);
      expect(pesagens.length, 4);

      final partos = await _db!.query('eventos_reprodutivos', where: 'tipo = ?', whereArgs: ['Parto']);
      expect(partos.length, 2);

      final leite = await _db!.query('producao_leite');
      expect(leite.length, 3);

      final femeasAptas = animais.where((a) =>
          a['sexo'] == 'F' &&
          _calcularIdadeMeses(DateTime.parse(a['dataNascimento'] as String)) >= 24).length;
      expect(femeasAptas, 2);

      double taxaNatalidade = 0;
      if (femeasAptas > 0) {
        taxaNatalidade = (partos.length / femeasAptas) * 100;
      }
      expect(taxaNatalidade, 100.0);

      Map<String, List<Map<String, dynamic>>> pesagensPorAnimal = {};
      for (var p in pesagens) {
        pesagensPorAnimal.putIfAbsent(p['animalId'] as String, () => []).add(p);
      }
      List<double> gmds = [];
      for (var lista in pesagensPorAnimal.values) {
        if (lista.length < 2) continue;
        lista.sort((a, b) => DateTime.parse(a['data'] as String).compareTo(DateTime.parse(b['data'] as String)));
        final primeiro = lista.first;
        final ultimo = lista.last;
        final dias = DateTime.parse(ultimo['data'] as String).difference(DateTime.parse(primeiro['data'] as String)).inDays;
        if (dias >= 7) {
          final ganho = (ultimo['pesoKg'] as num).toDouble() - (primeiro['pesoKg'] as num).toDouble();
          gmds.add(ganho / dias);
        }
      }
      expect(gmds.length, 2);

      Map<String, double> producaoPorVacaDia = {};
      for (var l in leite) {
        final chave = '${l['animalId']}_${(l['data'] as String).substring(0, 10)}';
        producaoPorVacaDia[chave] = (producaoPorVacaDia[chave] ?? 0) + (l['litros'] as num).toDouble();
      }
      expect(producaoPorVacaDia.length, 2);
    });
  });

  group('Fluxo 5: Export/Import round-trip', () {
    test('exporta e importa mantendo dados', () async {
      final prop = Propriedade(nomeFazenda: 'Faz X', nomeProprietario: 'Teste',
          cidade: 'Campo Grande', estado: 'MS', sistemaProducao: 'Extensivo');
      await _db!.insert('propriedades', prop.toMap());

      final piquete = Piquete(fazendaId: prop.id, nome: 'Pasto X', tipo: 'Pastagem', capacidade: 20);
      await _db!.insert('lotes', piquete.toMap());

      final animal = Animal(id: 'x001', fazendaId: prop.id, loteId: piquete.id,
          brinco: 'X001', raca: 'Nelore', sexo: 'M', categoria: 'Boi',
          dataNascimento: DateTime(2022, 6, 1), pesoAtualKg: 500.0);
      await _db!.insert('animais', animal.toMap());

      final exportData = {
        'tipo': 'fazenda_unica',
        'version': 1,
        'propriedade': (await _db!.query('propriedades')).first,
        'lotes': await _db!.query('lotes'),
        'animais': await _db!.query('animais'),
        'pesagens': <Map<String, dynamic>>[],
        'eventos_reprodutivos': <Map<String, dynamic>>[],
        'producao_leite': <Map<String, dynamic>>[],
        'eventos_sanitarios': <Map<String, dynamic>>[],
        'abates': <Map<String, dynamic>>[],
      };

      await _db!.close();
      _db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      for (final sql in _sqlTabelas) {
        await _db!.execute(sql);
      }

      await _db!.insert('propriedades', Map<String, dynamic>.from(exportData['propriedade'] as Map));
      for (final l in exportData['lotes'] as List) {
        await _db!.insert('lotes', Map<String, dynamic>.from(l as Map));
      }
      for (final a in exportData['animais'] as List) {
        await _db!.insert('animais', Map<String, dynamic>.from(a as Map));
      }

      final props = await _db!.query('propriedades');
      expect(props.length, 1);
      expect(props.first['nomeFazenda'], 'Faz X');

      final animais = await _db!.query('animais');
      expect(animais.length, 1);
      expect(animais.first['brinco'], 'X001');
    });
  });
}

int _calcularIdadeMeses(DateTime dataNascimento) {
  final hoje = DateTime.now();
  if (dataNascimento.isAfter(hoje)) return 0;
  int meses = (hoje.year - dataNascimento.year) * 12 + (hoje.month - dataNascimento.month);
  if (hoje.day < dataNascimento.day) meses--;
  return meses > 0 ? meses : 0;
}
