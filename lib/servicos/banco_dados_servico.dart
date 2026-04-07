import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../modelos/propriedade.dart';
import '../modelos/lote.dart';
import '../modelos/animal.dart';
import '../modelos/eventos/pesagem.dart';
import '../modelos/eventos/evento_reprodutivo.dart';
import '../modelos/eventos/producao_leite.dart';

class BancoDadosServico {
  static final BancoDadosServico instancia = BancoDadosServico._init();
  static Database? _database;

  BancoDadosServico._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bovicheck.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Propriedades
    await db.execute('''
      CREATE TABLE propriedades (
        id TEXT PRIMARY KEY,
        nomeFazenda TEXT NOT NULL,
        nomeProprietario TEXT NOT NULL,
        cep TEXT,
        cidade TEXT NOT NULL,
        estado TEXT NOT NULL,
        gpsLat REAL,
        gpsLong REAL,
        sistemaProducao TEXT NOT NULL,
        areaTotalHectares REAL NOT NULL,
        areaProducaoHectares REAL DEFAULT 0,
        areaUtilizadaHectares REAL DEFAULT 0
      )
    ''');

    // 2. Lotes
    await db.execute('''
      CREATE TABLE lotes (
        id TEXT PRIMARY KEY,
        fazendaId TEXT NOT NULL,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL,
        capacidade INTEGER NOT NULL,
        descricao TEXT NOT NULL,
        sistemaProducao TEXT NOT NULL DEFAULT 'Extensivo',
        areaHectares REAL DEFAULT 0,
        FOREIGN KEY (fazendaId) REFERENCES propriedades (id) ON DELETE CASCADE
      )
    ''');

    // 3. Animais
    await db.execute('''
      CREATE TABLE animais (
        id TEXT PRIMARY KEY,
        fazendaId TEXT NOT NULL,
        loteId TEXT NOT NULL,
        brinco TEXT NOT NULL,
        nome TEXT,
        raca TEXT NOT NULL,
        sexo TEXT NOT NULL,
        categoria TEXT NOT NULL,
        dataNascimento TEXT NOT NULL,
        pesoAtualKg REAL NOT NULL,
        dataObito TEXT,
        isAtivo INTEGER NOT NULL,
        FOREIGN KEY (fazendaId) REFERENCES propriedades (id) ON DELETE CASCADE,
        FOREIGN KEY (loteId) REFERENCES lotes (id) ON DELETE SET NULL
      )
    ''');

    // 4. Pesagens
    await db.execute('''
      CREATE TABLE pesagens (
        id TEXT PRIMARY KEY,
        animalId TEXT NOT NULL,
        data TEXT NOT NULL,
        pesoKg REAL NOT NULL,
        etapa TEXT NOT NULL,
        FOREIGN KEY (animalId) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 5. Eventos Reprodutivos
    await db.execute('''
      CREATE TABLE eventos_reprodutivos (
        id TEXT PRIMARY KEY,
        animalId TEXT NOT NULL,
        data TEXT NOT NULL,
        tipo TEXT NOT NULL,
        resultado TEXT,
        observacao TEXT,
        progenieId TEXT,
        dataPrevistaParto TEXT,
        isPrimeiroParto INTEGER DEFAULT 0,
        FOREIGN KEY (animalId) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 6. Produção de Leite
    await db.execute('''
      CREATE TABLE producao_leite (
        id TEXT PRIMARY KEY,
        animalId TEXT NOT NULL,
        data TEXT NOT NULL,
        litros REAL NOT NULL,
        periodo TEXT NOT NULL,
        FOREIGN KEY (animalId) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 7. Eventos Sanitários
    await db.execute('''
      CREATE TABLE eventos_sanitarios (
        id TEXT PRIMARY KEY,
        animalId TEXT NOT NULL,
        data TEXT NOT NULL,
        tipo TEXT NOT NULL,
        nomeMedicamento TEXT,
        observacao TEXT,
        FOREIGN KEY (animalId) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');

    // 8. Abates
    await db.execute('''
      CREATE TABLE abates (
        id TEXT PRIMARY KEY,
        animalId TEXT NOT NULL,
        data TEXT NOT NULL,
        pesoVivoKg REAL NOT NULL,
        pesoCarcacaKg REAL NOT NULL,
        observacao TEXT,
        FOREIGN KEY (animalId) REFERENCES animais (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE propriedades ADD COLUMN cep TEXT');
      await db.execute(
        'ALTER TABLE propriedades ADD COLUMN areaProducaoHectares REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE propriedades ADD COLUMN areaUtilizadaHectares REAL DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE lotes ADD COLUMN sistemaProducao TEXT NOT NULL DEFAULT 'Extensivo'",
      );
      await db.execute(
        'ALTER TABLE lotes ADD COLUMN areaHectares REAL DEFAULT 0',
      );
    }
  }

  // --- CRUD GERAL ---

  Future<void> adicionarPropriedade(Propriedade p) async {
    final db = await database;
    await db.insert(
      'propriedades',
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePropriedade(Propriedade p) async {
    final db = await database;
    await db.update(
      'propriedades',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<void> deletePropriedade(String id) async {
    final db = await database;
    await db.delete('animais', where: 'fazendaId = ?', whereArgs: [id]);
    await db.delete('lotes', where: 'fazendaId = ?', whereArgs: [id]);
    await db.delete(
      'pesagens',
      where: 'animalId IN (SELECT id FROM animais WHERE fazendaId = ?)',
      whereArgs: [id],
    );
    await db.delete('propriedades', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Propriedade>> getPropriedades() async {
    final db = await database;
    final result = await db.query('propriedades');
    return result.map((json) => Propriedade.fromMap(json)).toList();
  }

  Future<void> adicionarLote(Lote l) async {
    final db = await database;
    await db.insert(
      'lotes',
      l.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateLote(Lote l) async {
    final db = await database;
    await db.update('lotes', l.toMap(), where: 'id = ?', whereArgs: [l.id]);
  }

  Future<List<Lote>> getLotesPorFazenda(String fazendaId) async {
    final db = await database;
    final result = await db.query(
      'lotes',
      where: 'fazendaId = ?',
      whereArgs: [fazendaId],
    );
    return result.map((json) => Lote.fromMap(json)).toList();
  }

  Future<void> adicionarAnimal(Animal a) async {
    final db = await database;
    await db.insert(
      'animais',
      a.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAnimal(Animal a) async {
    final db = await database;
    await db.update('animais', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
  }

  Future<List<Animal>> getAnimaisPorFazenda(String fazendaId) async {
    final db = await database;
    final result = await db.query(
      'animais',
      where: 'fazendaId = ?',
      whereArgs: [fazendaId],
      orderBy: 'brinco ASC',
    );
    return result.map((json) => Animal.fromMap(json)).toList();
  }

  // --- Eventos ---

  Future<void> salvarPesagem(Pesagem pesagem) async {
    final db = await database;
    await db.insert(
      'pesagens',
      pesagem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.update(
      'animais',
      {'pesoAtualKg': pesagem.pesoKg},
      where: 'id = ?',
      whereArgs: [pesagem.animalId],
    );
  }

  Future<List<Pesagem>> getPesagensPorAnimal(String animalId) async {
    final db = await database;
    final res = await db.query(
      'pesagens',
      where: 'animalId = ?',
      whereArgs: [animalId],
      orderBy: 'data DESC',
    );
    return res.map((x) => Pesagem.fromMap(x)).toList();
  }

  Future<void> salvarEventoReprodutivo(EventoReprodutivo evento) async {
    final db = await database;
    await db.insert(
      'eventos_reprodutivos',
      evento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<EventoReprodutivo>> getEventosReprodutivosPorAnimal(
    String animalId,
  ) async {
    final db = await database;
    final res = await db.query(
      'eventos_reprodutivos',
      where: 'animalId = ?',
      whereArgs: [animalId],
      orderBy: 'data DESC',
    );
    return res.map((x) => EventoReprodutivo.fromMap(x)).toList();
  }

  Future<void> salvarProducaoLeite(ProducaoLeite evento) async {
    final db = await database;
    await db.insert(
      'producao_leite',
      evento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProducaoLeite>> getProducaoLeitePorAnimal(String animalId) async {
    final db = await database;
    final res = await db.query(
      'producao_leite',
      where: 'animalId = ?',
      whereArgs: [animalId],
      orderBy: 'data DESC',
    );
    return res.map((x) => ProducaoLeite.fromMap(x)).toList();
  }

  Future<void> salvarEventoSanitario(Map<String, dynamic> evento) async {
    final db = await database;
    await db.insert(
      'eventos_sanitarios',
      evento,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> salvarAbate(Map<String, dynamic> abate) async {
    final db = await database;
    await db.insert(
      'abates',
      abate,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Utils ---

  Future<void> limparTudo() async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, 'bovicheck.db');
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
  }

  Future<List<int>> exportarBancoDados() async {
    final db = await database;
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, 'bovicheck.db');
    return File(path).readAsBytes();
  }

  Future<void> restaurarBancoDados(String caminhoNovoArquivo) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, 'bovicheck.db');
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
    await File(caminhoNovoArquivo).copy(path);
    await database;
  }
}
