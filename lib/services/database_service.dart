import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/respectful_person.dart';

/// Service for managing SQLite database operations for RespectfulPerson records.
///
/// Handles database initialization, CRUD operations, and table schema management.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Get the database instance, initializing if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database and create tables if needed
  Future<Database> _initDatabase() async {
    // Get the database path
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'respectful_persons.db');

    // Open the database and create the table if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create the database schema
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE respectful_persons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Create index on createdAt for efficient sorting
    await db.execute('''
      CREATE INDEX idx_createdAt ON respectful_persons(createdAt DESC)
    ''');
  }

  /// Initialize the database (to be called on app start)
  Future<void> initialize() async {
    await database;
  }

  /// Insert a new person into the database
  ///
  /// Returns the ID of the inserted person
  /// Throws DatabaseException if insert fails
  Future<int> insertPerson(RespectfulPerson person) async {
    try {
      final db = await database;
      return await db.insert(
        'respectful_persons',
        person.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert person: $e');
    }
  }

  /// Retrieve all registered people, ordered by creation date (newest first)
  ///
  /// Returns a list of all RespectfulPerson records
  /// Throws DatabaseException if query fails
  Future<List<RespectfulPerson>> getAllPersons() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'respectful_persons',
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return RespectfulPerson.fromMap(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get all persons: $e');
    }
  }

  /// Retrieve all people with valid coordinates (for map and compass)
  ///
  /// Returns a list of RespectfulPerson records that have non-null lat/lng
  /// Throws DatabaseException if query fails
  Future<List<RespectfulPerson>> getPersonsWithCoordinates() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'respectful_persons',
        where: 'latitude IS NOT NULL AND longitude IS NOT NULL',
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return RespectfulPerson.fromMap(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get persons with coordinates: $e');
    }
  }

  /// Get a single person by ID
  ///
  /// Returns the RespectfulPerson or null if not found
  /// Throws DatabaseException if query fails
  Future<RespectfulPerson?> getPerson(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'respectful_persons',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return RespectfulPerson.fromMap(maps.first);
    } catch (e) {
      throw DatabaseException('Failed to get person: $e');
    }
  }

  /// Delete a person by ID
  ///
  /// Returns the number of rows deleted (0 or 1)
  /// Throws DatabaseException if delete fails
  Future<int> deletePerson(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'respectful_persons',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete person: $e');
    }
  }

  /// Update an existing person
  ///
  /// Returns the number of rows updated
  /// Throws DatabaseException if update fails
  Future<int> updatePerson(RespectfulPerson person) async {
    if (person.id == null) {
      throw DatabaseException('Cannot update person without an ID');
    }

    try {
      final db = await database;
      return await db.update(
        'respectful_persons',
        person.toMap(),
        where: 'id = ?',
        whereArgs: [person.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update person: $e');
    }
  }

  /// Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete all persons (for testing/debugging)
  Future<void> deleteAllPersons() async {
    try {
      final db = await database;
      await db.delete('respectful_persons');
    } catch (e) {
      throw DatabaseException('Failed to delete all persons: $e');
    }
  }

  /// Get count of all persons
  Future<int> getPersonCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM respectful_persons');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get person count: $e');
    }
  }
}

/// Exception thrown when database operations fail
class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
