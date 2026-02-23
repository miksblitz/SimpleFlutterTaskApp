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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // CREATE - Insert a new task
  Future<int> insertTask(Task task) async {
    final db = await database;
    print('📝 [DB] Inserting task: ${task.title}');
    final id = await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ [DB] Task inserted with ID: $id');
    return id;
  }

  // READ - Get all tasks
  Future<List<Task>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'id DESC');
    print('📖 [DB] Retrieved ${maps.length} tasks from database');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
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
      print('📖 [DB] Found task with ID: $id');
      return Task.fromMap(maps.first);
    }
    print('⚠️ [DB] Task not found with ID: $id');
    return null;
  }

  // UPDATE - Update task
  Future<int> updateTask(Task task) async {
    final db = await database;
    print('✏️ [DB] Updating task ID ${task.id}: ${task.title}');
    final result = await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    print('✅ [DB] Task updated: $result rows affected');
    return result;
  }

  // DELETE - Delete task
  Future<int> deleteTask(int id) async {
    final db = await database;
    print('🗑️ [DB] Deleting task with ID: $id');
    final result = await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('✅ [DB] Task deleted: $result rows affected');
    return result;
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
}
