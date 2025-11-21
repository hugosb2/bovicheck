import 'package:bovicheck/models/animal/animal.dart';
import 'package:bovicheck/models/animal/health_event.dart';
import 'package:bovicheck/models/animal/medication_record.dart';
import 'package:bovicheck/models/animal/milk_record.dart';
import 'package:bovicheck/models/animal/reproductive_event.dart';
import 'package:bovicheck/models/animal/weight_record.dart';
import 'package:bovicheck/models/analysis_snapshot.dart';
import 'package:bovicheck/models/lote.dart';
import 'package:bovicheck/models/propriedade.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE propriedades(
      id TEXT PRIMARY KEY,
      nome TEXT NOT NULL,
      proprietario TEXT NOT NULL,
      latitude TEXT NOT NULL,
      longitude TEXT NOT NULL,
      cidade TEXT NOT NULL,
      estado TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE lotes(
      id TEXT PRIMARY KEY,
      nome TEXT NOT NULL,
      descricao TEXT,
      propriedadeId TEXT NOT NULL,
      FOREIGN KEY (propriedadeId) REFERENCES propriedades(id) ON DELETE RESTRICT
    )
    ''');

    await db.execute('''
    CREATE TABLE animals(
      id TEXT PRIMARY KEY,
      brinco TEXT NOT NULL,
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
      FOREIGN KEY (loteId) REFERENCES lotes(id) ON DELETE SET NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE weight_records(
      id TEXT PRIMARY KEY,
      animalId TEXT NOT NULL,
      date TEXT NOT NULL,
      weight REAL NOT NULL,
      notes TEXT,
      FOREIGN KEY (animalId) REFERENCES animals(id) ON DELETE CASCADE
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
      FOREIGN KEY (animalId) REFERENCES animals(id) ON DELETE CASCADE
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
      FOREIGN KEY (animalId) REFERENCES animals(id) ON DELETE CASCADE
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
      FOREIGN KEY (animalId) REFERENCES animals(id) ON DELETE CASCADE
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
      FOREIGN KEY (animalId) REFERENCES animals(id) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE analysis_snapshots(
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      results TEXT NOT NULL
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
    await db.delete('propriedades', where: 'id = ?', whereArgs: [id]);
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
    await db.delete('lotes', where: 'id = ?', whereArgs: [id]);
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
    final maps = await db.query('animals', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;

    final animal = Animal.fromMap(maps.first);
    animal.historicoPeso = await getWeightRecordsForAnimal(animal.id);
    animal.historicoSaude = await getHealthEventsForAnimal(animal.id);
    animal.historicoMedicacao = await getMedicationRecordsForAnimal(animal.id);
    animal.historicoReprodutivo =
        await getReproductiveEventsForAnimal(animal.id);
    animal.historicoLeite = await getMilkRecordsForAnimal(animal.id);
    return animal;
  }

  Future<void> addOrUpdateAnimal(Animal animal) async {
    final db = await instance.database;
    await db.insert('animals', animal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteAnimal(String id) async {
    final db = await instance.database;
    await db.delete('animals', where: 'id = ?', whereArgs: [id]);
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
            await txn.insert('weight_records', rec.toMap(animalId: animal.id));
          }
          for (var rec in animal.historicoSaude) {
            await txn.insert('health_events', rec.toMap(animalId: animal.id));
          }
          for (var rec in animal.historicoMedicacao) {
            await txn.insert(
                'medication_records', rec.toMap(animalId: animal.id));
          }
          for (var rec in animal.historicoReprodutivo) {
            await txn.insert(
                'reproductive_events', rec.toMap(animalId: animal.id));
          }
          for (var rec in animal.historicoLeite) {
            await txn.insert('milk_records', rec.toMap(animalId: animal.id));
          }
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

  // --- NOVOS MÉTODOS ADICIONADOS ---

  Future<Propriedade?> getPropriedadeById(String id) async {
    final db = await instance.database;
    final maps =
        await db.query('propriedades', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Propriedade.fromMap(maps.first);
    }
    return null;
  }

  Future<Lote?> getLoteById(String id) async {
    final db = await instance.database;
    final maps = await db.query('lotes', where: 'id = ?', whereArgs: [id]);
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

  Future<List<Animal>> getAnimalsForLote(String loteId) async {
    final db = await instance.database;
    final maps = await db.query('animals',
        where: 'loteId = ?', whereArgs: [loteId], orderBy: 'brinco');
    // Retorna a lista simples de animais, sem histórico (para performance)
    return maps.map((map) => Animal.fromMap(map)).toList();
  }
  // --- FIM DOS NOVOS MÉTODOS ---
}
