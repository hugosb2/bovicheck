import 'package:bovicheck/modelos/animal/animal.dart';
import 'package:bovicheck/modelos/animal/health_event.dart';
import 'package:bovicheck/modelos/animal/medication_record.dart';
import 'package:bovicheck/modelos/animal/milk_record.dart';
import 'package:bovicheck/modelos/animal/reproductive_event.dart';
import 'package:bovicheck/modelos/animal/weight_record.dart';
import 'package:bovicheck/modelos/analysis_snapshot.dart';
import 'package:bovicheck/modelos/area_pastagem.dart';
import 'package:bovicheck/modelos/herd_indicator.dart';
import 'package:bovicheck/modelos/lote.dart';
import 'package:bovicheck/modelos/propriedade.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'dart:typed_data';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bovicheck.db');

    // Abre o banco com versão 5 (adiciona dbId e identificador)
    final db = await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );

    // Verifica se precisa migrar (caso o banco já existisse sem migração)
    try {
      final tableInfo = await db.rawQuery("PRAGMA table_info(propriedades)");
      final hasMunicipio = tableInfo.any((col) => col['name'] == 'municipio');
      final hasCidade = tableInfo.any((col) => col['name'] == 'cidade');
      final hasAreaTotal = tableInfo.any((col) => col['name'] == 'areaTotal');
      final hasDbId = tableInfo.any((col) => col['name'] == 'dbId');

      // Se não tem municipio mas tem cidade, precisa migrar para versão 2
      if (!hasMunicipio && hasCidade) {
        await _migrateToVersion2(db);
      }

      // Se não tem areaTotal, precisa migrar para versão 3
      if (!hasAreaTotal) {
        await _migrateToVersion3(db);
      }

      // Se não tem dbId, precisa migrar para versão 5
      if (!hasDbId) {
        await _migrateToVersion5(db);
      }
    } catch (e) {
      // Tabela pode não existir ainda, será criada pelo onCreate
    }

    return db;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migração da versão 1 para 2: remover latitude/longitude e renomear cidade para municipio
      await _migrateToVersion2(db);
    }
    if (oldVersion < 3) {
      // Migração da versão 2 para 3: adicionar areaTotal e criar tabela area_pastagens
      await _migrateToVersion3(db);
    }
    if (oldVersion < 4) {
      // Migração da versão 3 para 4: criar tabela herd_indicators
      await _migrateToVersion4(db);
    }
    if (oldVersion < 5) {
      // Migração da versão 4 para 5: adicionar dbId e identificador
      await _migrateToVersion5(db);
    }
  }

  Future<void> _migrateToVersion4(Database db) async {
    try {
      // Cria tabela herd_indicators se não existir
      final indicatorTables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='herd_indicators'");
      if (indicatorTables.isEmpty) {
        await db.execute('''
          CREATE TABLE herd_indicators(
            id TEXT PRIMARY KEY,
            indicatorKey TEXT NOT NULL,
            indicatorTitle TEXT NOT NULL,
            indicatorUnit TEXT NOT NULL,
            applyToLote INTEGER NOT NULL DEFAULT 0,
            applyToProperty INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');
      }
    } catch (e) {
      // Erro na migração
      rethrow;
    }
  }

  Future<void> _migrateToVersion5(Database db) async {
    try {
      // Primeiro, cria a tabela area_pastagens se não existir
      final areaTables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='area_pastagens'");

      if (areaTables.isEmpty) {
        await db.execute('''
          CREATE TABLE area_pastagens(
            dbId TEXT PRIMARY KEY,
            nome TEXT NOT NULL,
            descricao TEXT,
            areaDestinada REAL NOT NULL,
            loteId TEXT NOT NULL,
            propriedadeId TEXT NOT NULL,
            animaisIds TEXT,
            FOREIGN KEY (propriedadeId) REFERENCES propriedades(dbId) ON DELETE CASCADE,
            FOREIGN KEY (loteId) REFERENCES lotes(dbId) ON DELETE CASCADE
          )
        ''');
      }
      final propriedadesInfo =
          await db.rawQuery("PRAGMA table_info(propriedades)");
      final hasDbId = propriedadesInfo.any((col) => col['name'] == 'dbId');

      if (!hasDbId) {
        // Drop temporary table if it exists from a previous failed migration
        await db.execute('DROP TABLE IF EXISTS propriedades_new');

        await db.execute('''
          CREATE TABLE propriedades_new(
            dbId TEXT PRIMARY KEY,
            identificador TEXT NOT NULL,
            nome TEXT NOT NULL,
            proprietario TEXT NOT NULL,
            municipio TEXT NOT NULL,
            estado TEXT NOT NULL,
            areaTotal REAL NOT NULL DEFAULT 0.0
          )
        ''');

        await db.execute('''
          INSERT INTO propriedades_new (dbId, identificador, nome, proprietario, municipio, estado, areaTotal)
          SELECT id, id, nome, proprietario, municipio, estado, areaTotal
          FROM propriedades
        ''');

        await db.execute('DROP TABLE propriedades');
        await db.execute('ALTER TABLE propriedades_new RENAME TO propriedades');
      }

      // Migra tabela lotes: adiciona dbId e identificador
      final lotesInfo = await db.rawQuery("PRAGMA table_info(lotes)");
      final lotesHasDbId = lotesInfo.any((col) => col['name'] == 'dbId');

      if (!lotesHasDbId) {
        // Drop temporary table if it exists from a previous failed migration
        await db.execute('DROP TABLE IF EXISTS lotes_new');

        await db.execute('''
          CREATE TABLE lotes_new(
            dbId TEXT PRIMARY KEY,
            identificador TEXT NOT NULL,
            nome TEXT NOT NULL,
            descricao TEXT,
            areaDestinada REAL NOT NULL DEFAULT 0.0,
            propriedadeId TEXT NOT NULL,
            animaisIds TEXT,
            FOREIGN KEY (propriedadeId) REFERENCES propriedades(dbId) ON DELETE RESTRICT
          )
        ''');

        await db.execute('''
          INSERT INTO lotes_new (dbId, identificador, nome, descricao, areaDestinada, propriedadeId, animaisIds)
          SELECT id, id, nome, descricao, 0.0, propriedadeId, ''
          FROM lotes
        ''');

        await db.execute('DROP TABLE lotes');
        await db.execute('ALTER TABLE lotes_new RENAME TO lotes');
      }

      // Migra tabela animals: adiciona dbId
      final animalsInfo = await db.rawQuery("PRAGMA table_info(animals)");
      final animalsHasDbId = animalsInfo.any((col) => col['name'] == 'dbId');

      if (!animalsHasDbId) {
        // Drop temporary table if it exists from a previous failed migration
        await db.execute('DROP TABLE IF EXISTS animals_new');

        await db.execute('''
          CREATE TABLE animals_new(
            dbId TEXT PRIMARY KEY,
            brinco TEXT NOT NULL UNIQUE,
            nome TEXT,
            dataNascimento TEXT NOT NULL,
            sexo TEXT NOT NULL,
            raca TEXT,
            loteId TEXT,
            status TEXT NOT NULL,
            motivoSaida TEXT,
            dataSaida TEXT,
            isDesmamado INTEGER NOT NULL,
            dataDesmame TEXT,
            FOREIGN KEY (loteId) REFERENCES lotes(dbId) ON DELETE SET NULL
          )
        ''');

        await db.execute('''
          INSERT INTO animals_new (dbId, brinco, nome, dataNascimento, sexo, raca, loteId, status, motivoSaida, dataSaida, isDesmamado, dataDesmame)
          SELECT id, brinco, nome, dataNascimento, sexo, raca, loteId, status, motivoSaida, dataSaida, isDesmamado, dataDesmame
          FROM animals
        ''');

        await db.execute('DROP TABLE animals');
        await db.execute('ALTER TABLE animals_new RENAME TO animals');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _migrateToVersion2(Database db) async {
    try {
      // Verifica se a tabela propriedades existe
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='propriedades'");

      if (tables.isEmpty) {
        // Tabela não existe, será criada pelo onCreate
        return;
      }

      // Verifica se a tabela tem os campos antigos ou se já está atualizada
      final tableInfo = await db.rawQuery("PRAGMA table_info(propriedades)");
      final hasMunicipio = tableInfo.any((col) => col['name'] == 'municipio');
      final hasCidade = tableInfo.any((col) => col['name'] == 'cidade');
      final hasLatitude = tableInfo.any((col) => col['name'] == 'latitude');

      // Se já tem municipio, não precisa migrar
      if (hasMunicipio && !hasCidade && !hasLatitude) {
        return;
      }

      // Precisa migrar
      // Drop temporary table if it exists from a previous failed migration
      await db.execute('DROP TABLE IF EXISTS propriedades_new');

      // Cria tabela temporária com novo esquema
      await db.execute('''
            CREATE TABLE propriedades_new(
              id TEXT PRIMARY KEY,
              nome TEXT NOT NULL,
              proprietario TEXT NOT NULL,
              municipio TEXT NOT NULL,
              estado TEXT NOT NULL,
              areaTotal REAL NOT NULL DEFAULT 0.0
            )
      ''');

      // Copia dados da tabela antiga para a nova, migrando cidade para municipio
      await db.execute('''
            INSERT INTO propriedades_new (id, nome, proprietario, municipio, estado, areaTotal)
            SELECT 
              id,
              nome,
              proprietario,
              COALESCE(municipio, cidade, '') as municipio,
              estado,
              COALESCE(areaTotal, 0.0) as areaTotal
            FROM propriedades
          ''');

      // Remove tabela antiga
      await db.execute('DROP TABLE propriedades');

      // Renomeia tabela nova
      await db.execute('ALTER TABLE propriedades_new RENAME TO propriedades');
    } catch (e) {
      // Se houver erro, tenta recriar a tabela
      try {
        await db.execute('DROP TABLE IF EXISTS propriedades');
        await db.execute('DROP TABLE IF EXISTS propriedades_new');
        await db.execute('''
          CREATE TABLE propriedades(
            id TEXT PRIMARY KEY,
            nome TEXT NOT NULL,
            proprietario TEXT NOT NULL,
            municipio TEXT NOT NULL,
            estado TEXT NOT NULL,
            areaTotal REAL NOT NULL DEFAULT 0.0
          )
        ''');
      } catch (e2) {
        // Erro crítico na migração
        rethrow;
      }
    }
  }

  Future<void> _migrateToVersion3(Database db) async {
    try {
      // Adiciona coluna areaTotal se não existir
      final tableInfo = await db.rawQuery("PRAGMA table_info(propriedades)");
      final hasAreaTotal = tableInfo.any((col) => col['name'] == 'areaTotal');

      if (!hasAreaTotal) {
        await db.execute(
            'ALTER TABLE propriedades ADD COLUMN areaTotal REAL NOT NULL DEFAULT 0.0');
      }

      // Adiciona UNIQUE constraint ao brinco se não existir
      try {
        await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_animals_brinco ON animals(brinco)');
      } catch (e) {
        // Índice pode já existir
      }

      // Cria tabela area_pastagens se não existir
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='area_pastagens'");
      if (tables.isEmpty) {
        await db.execute('''
          CREATE TABLE area_pastagens(
            id TEXT PRIMARY KEY,
            nome TEXT NOT NULL,
            descricao TEXT,
            areaDestinada REAL NOT NULL,
            propriedadeId TEXT NOT NULL,
            loteId TEXT,
            animaisIds TEXT,
            FOREIGN KEY (propriedadeId) REFERENCES propriedades(id) ON DELETE CASCADE,
            FOREIGN KEY (loteId) REFERENCES lotes(id) ON DELETE SET NULL
          )
        ''');
      }

      // Cria tabela herd_indicators se não existir
      final indicatorTables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='herd_indicators'");
      if (indicatorTables.isEmpty) {
        await db.execute('''
          CREATE TABLE herd_indicators(
            id TEXT PRIMARY KEY,
            indicatorKey TEXT NOT NULL,
            indicatorTitle TEXT NOT NULL,
            indicatorUnit TEXT NOT NULL,
            applyToLote INTEGER NOT NULL DEFAULT 0,
            applyToProperty INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');
      }
    } catch (e) {
      // Erro na migração
      rethrow;
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE propriedades(
      dbId TEXT PRIMARY KEY,
      identificador TEXT NOT NULL,
      nome TEXT NOT NULL,
      proprietario TEXT NOT NULL,
      municipio TEXT NOT NULL,
      estado TEXT NOT NULL,
      areaTotal REAL NOT NULL DEFAULT 0.0
    )
    ''');

    await db.execute('''
    CREATE TABLE lotes(
      dbId TEXT PRIMARY KEY,
      identificador TEXT NOT NULL,
      nome TEXT NOT NULL,
      descricao TEXT,
      areaDestinada REAL NOT NULL DEFAULT 0.0,
      propriedadeId TEXT NOT NULL,
      animaisIds TEXT,
      FOREIGN KEY (propriedadeId) REFERENCES propriedades(dbId) ON DELETE RESTRICT
    )
    ''');

    await db.execute('''
    CREATE TABLE animals(
      dbId TEXT PRIMARY KEY,
      brinco TEXT NOT NULL UNIQUE,
      nome TEXT,
      dataNascimento TEXT NOT NULL,
      sexo TEXT NOT NULL,
      raca TEXT,
      loteId TEXT,
      status TEXT NOT NULL,
      motivoSaida TEXT,
      dataSaida TEXT,
      isDesmamado INTEGER NOT NULL,
      dataDesmame TEXT,
      FOREIGN KEY (loteId) REFERENCES lotes(dbId) ON DELETE SET NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE weight_records(
      id TEXT PRIMARY KEY,
      animalId TEXT NOT NULL,
      date TEXT NOT NULL,
      weight REAL NOT NULL,
      notes TEXT,
      FOREIGN KEY (animalId) REFERENCES animals(dbId) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE health_events(
      id TEXT PRIMARY KEY,
      animalId TEXT NOT NULL,
      date TEXT NOT NULL,
      diagnosis TEXT NOT NULL,
      treatment TEXT,
      notes TEXT,
      FOREIGN KEY (animalId) REFERENCES animals(dbId) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE medication_records(
      id TEXT PRIMARY KEY,
      animalId TEXT NOT NULL,
      date TEXT NOT NULL,
      productName TEXT NOT NULL,
      type TEXT NOT NULL,
      dose TEXT NOT NULL,
      notes TEXT,
      FOREIGN KEY (animalId) REFERENCES animals(dbId) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE reproductive_events(
      id TEXT PRIMARY KEY,
      animalId TEXT NOT NULL,
      date TEXT NOT NULL,
      eventType TEXT NOT NULL,
      result TEXT,
      notes TEXT,
      FOREIGN KEY (animalId) REFERENCES animals(dbId) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE milk_records(
      id TEXT PRIMARY KEY,
      animalId TEXT NOT NULL,
      date TEXT NOT NULL,
      morningProduction REAL NOT NULL,
      afternoonProduction REAL NOT NULL,
      notes TEXT,
      FOREIGN KEY (animalId) REFERENCES animals(dbId) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE analysis_snapshots(
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      results TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE area_pastagens(
      dbId TEXT PRIMARY KEY,
      nome TEXT NOT NULL,
      descricao TEXT,
      areaDestinada REAL NOT NULL,
      loteId TEXT NOT NULL,
      propriedadeId TEXT NOT NULL,
      animaisIds TEXT,
      FOREIGN KEY (propriedadeId) REFERENCES propriedades(dbId) ON DELETE CASCADE,
      FOREIGN KEY (loteId) REFERENCES lotes(dbId) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE herd_indicators(
      id TEXT PRIMARY KEY,
      indicatorKey TEXT NOT NULL,
      indicatorTitle TEXT NOT NULL,
      indicatorUnit TEXT NOT NULL,
      applyToLote INTEGER NOT NULL DEFAULT 0,
      applyToProperty INTEGER NOT NULL DEFAULT 0,
      createdAt TEXT NOT NULL
    )
    ''');
  }

  Future<void> addOrUpdatePropriedade(Propriedade prop) async {
    final db = await instance.database;
    await db.insert('propriedades', prop.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Propriedade>> getAllPropriedades() async {
    final db = await instance.database;
    final maps = await db.query('propriedades', orderBy: 'nome');
    return maps.map((map) => Propriedade.fromMap(map)).toList();
  }

  Future<void> deletePropriedade(String id) async {
    final db = await instance.database;
    await db.delete('propriedades', where: 'dbId = ?', whereArgs: [id]);
  }

  Future<bool> isPropriedadeInUse(String propId) async {
    final db = await instance.database;
    final result = await db.query('lotes',
        where: 'propriedadeId = ?', whereArgs: [propId], limit: 1);
    return result.isNotEmpty;
  }

  Future<void> addOrUpdateLote(Lote lote) async {
    final db = await instance.database;
    await db.insert('lotes', lote.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Lote>> getAllLotes() async {
    final db = await instance.database;
    final maps = await db.query('lotes', orderBy: 'nome');
    return maps.map((map) => Lote.fromMap(map)).toList();
  }

  Future<void> deleteLote(String id) async {
    final db = await instance.database;
    await db.delete('lotes', where: 'dbId = ?', whereArgs: [id]);
  }

  Future<List<Animal>> getAllAnimalsWithHistory() async {
    final db = await instance.database;
    final animalMaps = await db.query('animals', orderBy: 'brinco');

    List<Animal> animals = [];
    for (var map in animalMaps) {
      final animal = Animal.fromMap(map);
      animal.historicoPeso = await getWeightRecordsForAnimal(animal.id);
      animal.historicoSaude = await getHealthEventsForAnimal(animal.id);
      animal.historicoMedicacao =
          await getMedicationRecordsForAnimal(animal.id);
      animal.historicoReprodutivo =
          await getReproductiveEventsForAnimal(animal.id);
      animal.historicoLeite = await getMilkRecordsForAnimal(animal.id);
      animals.add(animal);
    }
    return animals;
  }

  Future<List<Animal>> getAllAnimals() async {
    final db = await instance.database;
    final animalMaps = await db.query('animals', orderBy: 'brinco');
    return animalMaps.map((map) => Animal.fromMap(map)).toList();
  }

  Future<Animal?> getAnimalWithHistory(String id) async {
    final db = await instance.database;
    final maps = await db.query('animals', where: 'dbId = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;

    final animal = Animal.fromMap(maps.first);
    animal.historicoPeso = await getWeightRecordsForAnimal(animal.dbId);
    animal.historicoSaude = await getHealthEventsForAnimal(animal.dbId);
    animal.historicoMedicacao =
        await getMedicationRecordsForAnimal(animal.dbId);
    animal.historicoReprodutivo =
        await getReproductiveEventsForAnimal(animal.dbId);
    animal.historicoLeite = await getMilkRecordsForAnimal(animal.dbId);
    return animal;
  }

  Future<void> addOrUpdateAnimal(Animal animal) async {
    final db = await instance.database;
    await db.insert('animals', animal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteAnimal(String id) async {
    final db = await instance.database;
    await db.delete('animals', where: 'dbId = ?', whereArgs: [id]);
  }

  Future<void> addWeightRecord(String animalId, WeightRecord record) async {
    final db = await instance.database;
    await db.insert('weight_records', record.toMap(animalId: animalId));
  }

  Future<void> updateWeightRecord(WeightRecord record) async {
    final db = await instance.database;
    await db.update('weight_records', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> deleteWeightRecord(String recordId) async {
    final db = await instance.database;
    await db.delete('weight_records', where: 'id = ?', whereArgs: [recordId]);
  }

  Future<List<WeightRecord>> getWeightRecordsForAnimal(String animalId) async {
    final db = await instance.database;
    final maps = await db.query('weight_records',
        where: 'animalId = ?', whereArgs: [animalId], orderBy: 'date DESC');
    return maps.map((map) => WeightRecord.fromMap(map)).toList();
  }

  Future<void> addHealthEvent(String animalId, HealthEvent record) async {
    final db = await instance.database;
    await db.insert('health_events', record.toMap(animalId: animalId));
  }

  Future<void> updateHealthEvent(HealthEvent record) async {
    final db = await instance.database;
    await db.update('health_events', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> deleteHealthEvent(String recordId) async {
    final db = await instance.database;
    await db.delete('health_events', where: 'id = ?', whereArgs: [recordId]);
  }

  Future<List<HealthEvent>> getHealthEventsForAnimal(String animalId) async {
    final db = await instance.database;
    final maps = await db.query('health_events',
        where: 'animalId = ?', whereArgs: [animalId], orderBy: 'date DESC');
    return maps.map((map) => HealthEvent.fromMap(map)).toList();
  }

  Future<void> addMedicationRecord(
      String animalId, MedicationRecord record) async {
    final db = await instance.database;
    await db.insert('medication_records', record.toMap(animalId: animalId));
  }

  Future<void> updateMedicationRecord(MedicationRecord record) async {
    final db = await instance.database;
    await db.update('medication_records', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> deleteMedicationRecord(String recordId) async {
    final db = await instance.database;
    await db
        .delete('medication_records', where: 'id = ?', whereArgs: [recordId]);
  }

  Future<List<MedicationRecord>> getMedicationRecordsForAnimal(
      String animalId) async {
    final db = await instance.database;
    final maps = await db.query('medication_records',
        where: 'animalId = ?', whereArgs: [animalId], orderBy: 'date DESC');
    return maps.map((map) => MedicationRecord.fromMap(map)).toList();
  }

  Future<void> addReproductiveEvent(
      String animalId, ReproductiveEvent record) async {
    final db = await instance.database;
    await db.insert('reproductive_events', record.toMap(animalId: animalId));
  }

  Future<void> updateReproductiveEvent(ReproductiveEvent record) async {
    final db = await instance.database;
    await db.update('reproductive_events', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> deleteReproductiveEvent(String recordId) async {
    final db = await instance.database;
    await db
        .delete('reproductive_events', where: 'id = ?', whereArgs: [recordId]);
  }

  Future<List<ReproductiveEvent>> getReproductiveEventsForAnimal(
      String animalId) async {
    final db = await instance.database;
    final maps = await db.query('reproductive_events',
        where: 'animalId = ?', whereArgs: [animalId], orderBy: 'date DESC');
    return maps.map((map) => ReproductiveEvent.fromMap(map)).toList();
  }

  Future<void> addMilkRecord(String animalId, MilkRecord record) async {
    final db = await instance.database;
    await db.insert('milk_records', record.toMap(animalId: animalId));
  }

  Future<void> updateMilkRecord(MilkRecord record) async {
    final db = await instance.database;
    await db.update('milk_records', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> deleteMilkRecord(String recordId) async {
    final db = await instance.database;
    await db.delete('milk_records', where: 'id = ?', whereArgs: [recordId]);
  }

  Future<List<MilkRecord>> getMilkRecordsForAnimal(String animalId) async {
    final db = await instance.database;
    final maps = await db.query('milk_records',
        where: 'animalId = ?', whereArgs: [animalId], orderBy: 'date DESC');
    return maps.map((map) => MilkRecord.fromMap(map)).toList();
  }

  Future<void> addAnalysisSnapshot(AnalysisSnapshot snapshot) async {
    final db = await instance.database;
    await db.insert('analysis_snapshots', snapshot.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AnalysisSnapshot>> getAnalysisHistory() async {
    final db = await instance.database;
    final maps = await db.query('analysis_snapshots', orderBy: 'date DESC');
    return maps.map((map) => AnalysisSnapshot.fromMap(map)).toList();
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('weight_records');
    await db.delete('health_events');
    await db.delete('medication_records');
    await db.delete('reproductive_events');
    await db.delete('milk_records');
    await db.delete('analysis_snapshots');
    await db.delete('animals');
    await db.delete('lotes');
    await db.delete('propriedades');
  }

  Future<void> restoreFromBackup(Map<String, dynamic> data) async {
    await clearAllData();
    final db = await instance.database;

    await db.transaction((txn) async {
      if (data.containsKey('propriedades')) {
        for (var item in (data['propriedades'] as List)) {
          await txn.insert('propriedades', Propriedade.fromJson(item).toMap());
        }
      }
      if (data.containsKey('lotes')) {
        for (var item in (data['lotes'] as List)) {
          await txn.insert('lotes', Lote.fromJson(item).toMap());
        }
      }
      if (data.containsKey('animals')) {
        for (var item in (data['animals'] as List)) {
          final animal = Animal.fromJson(item);
          await txn.insert('animals', animal.toMap());
          for (var rec in animal.historicoPeso) {
            await txn.insert(
                'weight_records', rec.toMap(animalId: animal.dbId));
          }
          for (var rec in animal.historicoSaude) {
            await txn.insert('health_events', rec.toMap(animalId: animal.dbId));
          }
          for (var rec in animal.historicoMedicacao) {
            await txn.insert(
                'medication_records', rec.toMap(animalId: animal.dbId));
          }
          for (var rec in animal.historicoReprodutivo) {
            await txn.insert(
                'reproductive_events', rec.toMap(animalId: animal.dbId));
          }
          for (var rec in animal.historicoLeite) {
            await txn.insert('milk_records', rec.toMap(animalId: animal.dbId));
          }
        }
      }
      if (data.containsKey('herdIndicators')) {
        for (var item in (data['herdIndicators'] as List)) {
          await txn.insert(
              'herd_indicators', HerdIndicator.fromJson(item).toMap());
        }
      }
      if (data.containsKey('analysisHistory')) {
        for (var item in (data['analysisHistory'] as List)) {
          await txn.insert(
              'analysis_snapshots', AnalysisSnapshot.fromJson(item).toMap());
        }
      }
    });
  }

  /// Export the raw SQLite database file as bytes for backup.
  Future<Uint8List> exportDatabaseAsBytes() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bovicheck.db');
    final file = File(path);
    return await file.readAsBytes();
  }

  /// Import the raw SQLite database bytes, replacing current DB.
  /// Closes and reopens the database to apply the imported file.
  Future<void> importDatabaseFromBytes(Uint8List bytes) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bovicheck.db');

    // Close existing DB if open
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    // Reinitialize database instance on next access
    _database = null;
  }

  // --- NOVOS MÉTODOS ADICIONADOS ---

  Future<Propriedade?> getPropriedadeById(String id) async {
    final db = await instance.database;
    final maps =
        await db.query('propriedades', where: 'dbId = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Propriedade.fromMap(maps.first);
    }
    return null;
  }

  Future<Lote?> getLoteById(String id) async {
    final db = await instance.database;
    final maps = await db.query('lotes', where: 'dbId = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Lote.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Lote>> getLotesForPropriedade(String propriedadeId) async {
    final db = await instance.database;
    final maps = await db.query('lotes',
        where: 'propriedadeId = ?',
        whereArgs: [propriedadeId],
        orderBy: 'nome');
    return maps.map((map) => Lote.fromMap(map)).toList();
  }

  Future<List<Lote>> getLotesForPropriedadeByDbId(
      String propriedadeDbId) async {
    final db = await instance.database;
    final maps = await db.query('lotes',
        where: 'propriedadeId = ?',
        whereArgs: [propriedadeDbId],
        orderBy: 'nome');
    return maps.map((map) => Lote.fromMap(map)).toList();
  }

  Future<List<Animal>> getAnimalsForLote(String loteId) async {
    final db = await instance.database;
    final maps = await db.query('animals',
        where: 'loteId = ?', whereArgs: [loteId], orderBy: 'brinco');
    // Retorna a lista simples de animais, sem histórico (para performance)
    return maps.map((map) => Animal.fromMap(map)).toList();
  }

  Future<List<Animal>> getAnimalsForLoteByDbId(String loteDbId) async {
    final db = await instance.database;
    final maps = await db.query('animals',
        where: 'loteId = ?', whereArgs: [loteDbId], orderBy: 'brinco');
    // Retorna a lista simples de animais, sem histórico (para performance)
    return maps.map((map) => Animal.fromMap(map)).toList();
  }

  // Verifica se um brinco já existe (exceto o animal atual se estiver editando)
  Future<bool> brincoExists(String brinco, {String? excludeAnimalId}) async {
    final db = await instance.database;
    final maps = excludeAnimalId != null
        ? await db.query('animals',
            where: 'brinco = ? AND dbId != ?',
            whereArgs: [brinco, excludeAnimalId])
        : await db.query('animals', where: 'brinco = ?', whereArgs: [brinco]);
    return maps.isNotEmpty;
  }

  // Calcula a área total já destinada em lotes para uma propriedade
  Future<double> getAreaDestinadaTotal(String propriedadeId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(areaDestinada), 0.0) as total FROM lotes WHERE propriedadeId = ?',
      [propriedadeId],
    );
    return (result.first['total'] as num).toDouble();
  }

  // --- MÉTODOS PARA ÍNDICES DO REBANHO ---

  Future<void> addOrUpdateHerdIndicator(HerdIndicator indicator) async {
    final db = await instance.database;
    await db.insert('herd_indicators', indicator.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<HerdIndicator>> getAllHerdIndicators() async {
    final db = await instance.database;
    final maps = await db.query('herd_indicators', orderBy: 'createdAt DESC');
    return maps.map((map) => HerdIndicator.fromMap(map)).toList();
  }

  Future<HerdIndicator?> getHerdIndicatorById(String id) async {
    final db = await instance.database;
    final maps =
        await db.query('herd_indicators', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return HerdIndicator.fromMap(maps.first);
    }
    return null;
  }

  Future<void> deleteHerdIndicator(String id) async {
    final db = await instance.database;
    await db.delete('herd_indicators', where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODOS PARA ÁREAS DE PASTAGEM ---

  Future<void> addOrUpdateAreaPastagem(AreaPastagem area) async {
    final db = await instance.database;
    await db.insert('area_pastagens', area.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AreaPastagem>> getAllAreaPastagens() async {
    final db = await instance.database;
    final maps = await db.query('area_pastagens', orderBy: 'nome');
    return maps.map((map) => AreaPastagem.fromMap(map)).toList();
  }

  Future<List<AreaPastagem>> getAreaPastagensForLote(String loteId) async {
    final db = await instance.database;
    final maps = await db.query('area_pastagens',
        where: 'loteId = ?', whereArgs: [loteId], orderBy: 'nome');
    return maps.map((map) => AreaPastagem.fromMap(map)).toList();
  }

  Future<AreaPastagem?> getAreaPastagemById(String id) async {
    final db = await instance.database;
    final maps =
        await db.query('area_pastagens', where: 'dbId = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return AreaPastagem.fromMap(maps.first);
    }
    return null;
  }

  Future<void> deleteAreaPastagem(String id) async {
    final db = await instance.database;
    await db.delete('area_pastagens', where: 'dbId = ?', whereArgs: [id]);
  }

  // --- FIM DOS MÉTODOS PARA ÁREAS DE PASTAGEM ---
}
