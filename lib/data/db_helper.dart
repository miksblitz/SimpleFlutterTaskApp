import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'task_manager.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        dateCompleted TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Version 1 → 2: Add dateCompleted column
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN dateCompleted TEXT');
      } catch (e) {
        // Column already exists
      }
    }
  }

  // CREATE - Insert a new task
  Future<int> insertTask(Task task) async {
    await _ensureDateCompletedColumn();
    final db = await database;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ - Get all tasks
  Future<List<Task>> getTasks() async {
    await _ensureDateCompletedColumn();
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // MIGRATION HELPER: Ensure dateCompleted column exists (fallback for existing DBs)
  Future<void> _ensureDateCompletedColumn() async {
    final db = await database;
    try {
      await db.execute('ALTER TABLE tasks ADD COLUMN dateCompleted TEXT');
    } catch (e) {
      // Column already exists - no action needed
    }
  }

  // READ - Get task by id
  Future<Task?> getTaskById(int id) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE - Update task
  Future<int> updateTask(Task task) async {
    await _ensureDateCompletedColumn();
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // DELETE - Delete task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Delete all tasks
  Future<int> deleteAllTasks() async {
    final db = await database;
    return await db.delete('tasks');
  }

  // Close database
  Future<void> closeDB() async {
    final db = await database;
    db.close();
  }

  // Get database file path
  Future<String> getDatabasePath() async {
    return join(await getDatabasesPath(), 'task_manager.db');
  }
}
