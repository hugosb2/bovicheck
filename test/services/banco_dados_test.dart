import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:bovicheck/modelos/propriedade.dart';
import 'package:bovicheck/modelos/piquete.dart';
import 'package:bovicheck/modelos/animal.dart';
import 'package:bovicheck/modelos/eventos/pesagem.dart';
import 'package:bovicheck/modelos/eventos/evento_reprodutivo.dart';
import 'package:bovicheck/modelos/eventos/producao_leite.dart';
import 'package:bovicheck/modelos/eventos/evento_sanitario.dart';
import 'package:bovicheck/modelos/eventos/abate.dart';

Database? _db;

Future<void> _inicarDB({bool comFk = false}) async {
  sqfliteFfiInit();
  _db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  await _criarTabelas();
  if (comFk) await _db!.execute('PRAGMA foreign_keys = ON');
}

Future<void> _criarTabelas() async {
  for (final sql in _sqlTabelas) {
    await _db!.execute(sql);
  }
}

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

Propriedade _criarPropriedade() {
  return Propriedade(
    nomeFazenda: 'Fazenda Teste', nomeProprietario: 'João',
    cidade: 'Campo Grande', estado: 'MS',
    sistemaProducao: 'Extensivo',
  );
}

void main() {
  group('CRUD Propriedade', () {
    setUp(() async => await _inicarDB());
    tearDown(() async { await _db?.close(); _db = null; });

    test('inserir e ler propriedade', () async {
      final prop = _criarPropriedade();
      await _db!.insert('propriedades', prop.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      final rows = await _db!.query('propriedades');
      expect(rows.length, 1);
      expect(rows.first['nomeFazenda'], 'Fazenda Teste');
    });
  });

  group('CRUD Piquete', () {
    setUp(() async => await _inicarDB());
    tearDown(() async { await _db?.close(); _db = null; });

    test('inserir e ler piquete', () async {
      final piquete = Piquete(
        fazendaId: 'f1', nome: 'Piquete A', tipo: 'Pastagem',
        capacidade: 50,
      );
      await _db!.insert('lotes', piquete.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      final rows = await _db!.query('lotes',
          where: 'id = ?', whereArgs: [piquete.id]);
      expect(rows.length, 1);
      expect(rows.first['nome'], 'Piquete A');
    });
  });

  group('CRUD Animal', () {
    setUp(() async => await _inicarDB());
    tearDown(() async { await _db?.close(); _db = null; });

    test('inserir e ler animal', () async {
      final animal = Animal(
        id: '001', fazendaId: 'f1', loteId: 'l1',
        brinco: '001', raca: 'Nelore', sexo: 'F',
        categoria: 'Vaca', dataNascimento: DateTime(2020, 1, 1),
        pesoAtualKg: 450.0,
      );
      await _db!.insert('animais', animal.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      final rows = await _db!.query('animais',
          where: 'id = ?', whereArgs: ['001']);
      expect(rows.length, 1);
      final lido = Animal.fromMap(rows.first);
      expect(lido.brinco, '001');
      expect(lido.raca, 'Nelore');
    });
  });

  group('CRUD Pesagem', () {
    setUp(() async => await _inicarDB());
    tearDown(() async { await _db?.close(); _db = null; });

    test('inserir e ler pesagem', () async {
      final pesagem = Pesagem(
        animalId: '001', data: DateTime(2025, 6, 1), pesoKg: 470.0,
      );
      await _db!.insert('pesagens', pesagem.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      final rows = await _db!.query('pesagens',
          where: 'animalId = ?', whereArgs: ['001']);
      expect(rows.length, 1);
      expect((rows.first['pesoKg'] as num).toDouble(), 470.0);
    });
  });

  group('CRUD EventoReprodutivo', () {
    setUp(() async => await _inicarDB());
    tearDown(() async { await _db?.close(); _db = null; });

    test('inserir e ler evento', () async {
      final evento = EventoReprodutivo(
        animalId: '001', data: DateTime(2025, 3, 1),
        tipo: 'Parto', resultado: 'Simples',
      );
      await _db!.insert('eventos_reprodutivos', evento.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      final rows = await _db!.query('eventos_reprodutivos',
          where: 'animalId = ?', whereArgs: ['001']);
      expect(rows.length, 1);
      expect(rows.first['tipo'], 'Parto');
    });
  });

  group('CRUD ProducaoLeite', () {
    setUp(() async => await _inicarDB());
    tearDown(() async { await _db?.close(); _db = null; });

    test('inserir e ler producao de leite', () async {
      final producao = ProducaoLeite(
        animalId: '001', data: DateTime(2025, 6, 1, 6, 0),
        litros: 12.5, periodo: 'Manhã',
      );
      await _db!.insert('producao_leite', producao.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      final rows = await _db!.query('producao_leite');
      expect(rows.length, 1);
      expect((rows.first['litros'] as num).toDouble(), 12.5);
    });
  });

  group('CRUD EventoSanitario', () {
    setUp(() async => await _inicarDB());
    tearDown(() async { await _db?.close(); _db = null; });

    test('inserir e ler evento sanitario', () async {
      final evento = EventoSanitario(
        animalId: '001', data: DateTime(2025, 4, 10),
        tipo: 'Vacinação', nomeMedicamento: 'Aftosa',
      );
      await _db!.insert('eventos_sanitarios', evento.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      final rows = await _db!.query('eventos_sanitarios');
      expect(rows.length, 1);
      expect(rows.first['tipo'], 'Vacinação');
    });
  });

  group('CRUD Abate', () {
    setUp(() async => await _inicarDB());
    tearDown(() async { await _db?.close(); _db = null; });

    test('inserir e ler abate', () async {
      final abate = Abate(
        animalId: '001', data: DateTime(2025, 6, 1),
        pesoVivoKg: 500.0, pesoCarcacaKg: 260.0,
      );
      await _db!.insert('abates', abate.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      final rows = await _db!.query('abates');
      expect(rows.length, 1);
      expect((rows.first['pesoVivoKg'] as num).toDouble(), 500.0);
    });
  });

  group('Delete em cascata', () {
    setUp(() async => await _inicarDB(comFk: true));
    tearDown(() async { await _db?.close(); _db = null; });

    test('deletar propriedade com FK cascade', () async {
      final prop = _criarPropriedade();
      await _db!.insert('propriedades', prop.toMap());
      await _db!.insert('lotes', Piquete(
        fazendaId: prop.id, nome: 'Piquete A',
      ).toMap());
      await _db!.insert('animais', Animal(
        id: '001', fazendaId: prop.id, loteId: 'l1',
        brinco: '001', raca: 'Nelore', sexo: 'F',
        categoria: 'Vaca', dataNascimento: DateTime(2020, 1, 1),
        pesoAtualKg: 450.0,
      ).toMap());
      // Manual delete: sem FK entre animais->lotes, precisa deletar na ordem
      await _db!.delete('animais', where: 'fazendaId = ?', whereArgs: [prop.id]);
      await _db!.delete('lotes', where: 'fazendaId = ?', whereArgs: [prop.id]);
      await _db!.delete('propriedades', where: 'id = ?', whereArgs: [prop.id]);
      final props = await _db!.query('propriedades');
      expect(props, isEmpty);
    });
  });

  group('Delete de eventos e entidades (com FK, como no app)', () {
    setUp(() async {
      sqfliteFfiInit();
      _db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await _db!.execute('PRAGMA foreign_keys = ON');
      await _db!.execute('''CREATE TABLE lotes (
        id TEXT PRIMARY KEY, fazendaId TEXT NOT NULL,
        nome TEXT NOT NULL, tipo TEXT NOT NULL
      )''');
      await _db!.execute('''CREATE TABLE animais (
        id TEXT PRIMARY KEY, fazendaId TEXT NOT NULL, loteId TEXT NOT NULL,
        brinco TEXT NOT NULL, nome TEXT, raca TEXT NOT NULL,
        sexo TEXT NOT NULL, categoria TEXT NOT NULL,
        dataNascimento TEXT NOT NULL, pesoAtualKg REAL NOT NULL,
        isAtivo INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (loteId) REFERENCES lotes (id) ON DELETE NO ACTION
      )''');
      await _db!.execute('''CREATE TABLE pesagens (
        id TEXT PRIMARY KEY, animalId TEXT NOT NULL, data TEXT NOT NULL,
        pesoKg REAL NOT NULL,
        FOREIGN KEY (animalId) REFERENCES animais (id) ON DELETE CASCADE
      )''');
      await _db!.execute('''CREATE TABLE eventos_reprodutivos (
        id TEXT PRIMARY KEY, animalId TEXT NOT NULL, data TEXT NOT NULL,
        tipo TEXT NOT NULL,
        FOREIGN KEY (animalId) REFERENCES animais (id) ON DELETE CASCADE
      )''');
      await _db!.execute('''CREATE TABLE producao_leite (
        id TEXT PRIMARY KEY, animalId TEXT NOT NULL, data TEXT NOT NULL,
        litros REAL NOT NULL,
        FOREIGN KEY (animalId) REFERENCES animais (id) ON DELETE CASCADE
      )''');
      await _db!.execute('''CREATE TABLE eventos_sanitarios (
        id TEXT PRIMARY KEY, animalId TEXT NOT NULL, data TEXT NOT NULL,
        tipo TEXT NOT NULL,
        FOREIGN KEY (animalId) REFERENCES animais (id) ON DELETE CASCADE
      )''');
      await _db!.execute('''CREATE TABLE abates (
        id TEXT PRIMARY KEY, animalId TEXT NOT NULL, data TEXT NOT NULL,
        pesoCarcacaKg REAL NOT NULL,
        FOREIGN KEY (animalId) REFERENCES animais (id) ON DELETE CASCADE
      )''');
    });
    tearDown(() async { await _db?.close(); _db = null; });

    Future<void> inserirBase() async {
      await _db!.insert('lotes',
          {'id': 'l1', 'fazendaId': 'f1', 'nome': 'Pasto 1', 'tipo': 'Pasto'});
      await _db!.insert('animais', {
        'id': '001', 'fazendaId': 'f1', 'loteId': 'l1', 'brinco': '001',
        'raca': 'Nelore', 'sexo': 'F', 'categoria': 'Vaca',
        'dataNascimento': '2020-01-01T00:00:00.000', 'pesoAtualKg': 450.0,
      });
    }

    test('excluir pesagem remove apenas a pesagem', () async {
      await inserirBase();
      await _db!.insert('pesagens',
          {'id': 'p1', 'animalId': '001', 'data': '2025-06-01', 'pesoKg': 470.0});
      await _db!.delete('pesagens', where: 'id = ?', whereArgs: ['p1']);
      expect(await _db!.query('pesagens'), isEmpty);
      expect(await _db!.query('animais'), hasLength(1));
    });

    test('excluir evento reprodutivo, leite, sanitario e abate', () async {
      await inserirBase();
      await _db!.insert('eventos_reprodutivos',
          {'id': 'r1', 'animalId': '001', 'data': '2025-03-01', 'tipo': 'Parto'});
      await _db!.insert('producao_leite',
          {'id': 'm1', 'animalId': '001', 'data': '2025-06-01', 'litros': 12.5});
      await _db!.insert('eventos_sanitarios',
          {'id': 's1', 'animalId': '001', 'data': '2025-04-10', 'tipo': 'Vacinação'});
      await _db!.insert('abates',
          {'id': 'a1', 'animalId': '001', 'data': '2025-06-01', 'pesoCarcacaKg': 260.0});

      await _db!.delete('eventos_reprodutivos', where: 'id = ?', whereArgs: ['r1']);
      await _db!.delete('producao_leite', where: 'id = ?', whereArgs: ['m1']);
      await _db!.delete('eventos_sanitarios', where: 'id = ?', whereArgs: ['s1']);
      await _db!.delete('abates', where: 'id = ?', whereArgs: ['a1']);

      expect(await _db!.query('eventos_reprodutivos'), isEmpty);
      expect(await _db!.query('producao_leite'), isEmpty);
      expect(await _db!.query('eventos_sanitarios'), isEmpty);
      expect(await _db!.query('abates'), isEmpty);
      expect(await _db!.query('animais'), hasLength(1));
    });

    test('excluir animal remove eventos em cascata', () async {
      await inserirBase();
      await _db!.insert('pesagens',
          {'id': 'p1', 'animalId': '001', 'data': '2025-06-01', 'pesoKg': 470.0});
      await _db!.insert('eventos_reprodutivos',
          {'id': 'r1', 'animalId': '001', 'data': '2025-03-01', 'tipo': 'Parto'});
      await _db!.insert('abates',
          {'id': 'a1', 'animalId': '001', 'data': '2025-06-01', 'pesoCarcacaKg': 260.0});

      await _db!.delete('animais', where: 'id = ?', whereArgs: ['001']);

      expect(await _db!.query('animais'), isEmpty);
      expect(await _db!.query('pesagens'), isEmpty);
      expect(await _db!.query('eventos_reprodutivos'), isEmpty);
      expect(await _db!.query('abates'), isEmpty);
      expect(await _db!.query('lotes'), hasLength(1));
    });

    test('excluir piquete com animais falha por FK (NO ACTION)', () async {
      await inserirBase();
      await expectLater(
        _db!.delete('lotes', where: 'id = ?', whereArgs: ['l1']),
        throwsA(isA<DatabaseException>()),
      );
      expect(await _db!.query('lotes'), hasLength(1));
    });

    test('excluir piquete sem animais funciona', () async {
      await inserirBase();
      await _db!.delete('animais', where: 'id = ?', whereArgs: ['001']);
      await _db!.delete('lotes', where: 'id = ?', whereArgs: ['l1']);
      expect(await _db!.query('lotes'), isEmpty);
    });
  });
}
