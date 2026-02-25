import 'package:sqflite/sqflite.dart';
import '../../models/task_model.dart';
import '../database/db_connection.dart';

class TaskQueries {
  static final TaskQueries _instance = TaskQueries._internal();

  factory TaskQueries() {
    return _instance;
  }

  TaskQueries._internal();

  final DatabaseConnection _dbConnection = DatabaseConnection();

  Future<Database> get _database async => await _dbConnection.database;

  // CREATE - Insert a new task
  Future<int> insertTask(Task task) async {
    final db = await _database;
    return await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ - Get all tasks
  Future<List<Task>> getTasks() async {
    final db = await _database;
    final maps = await db.query('tasks', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // READ - Get task by id
  Future<Task?> getTaskById(int id) async {
    final db = await _database;
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
    final db = await _database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // DELETE - Delete task
  Future<int> deleteTask(int id) async {
    final db = await _database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Delete all tasks
  Future<int> deleteAllTasks() async {
    final db = await _database;
    return await db.delete('tasks');
  }
}
