import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseConnection {
  static final DatabaseConnection _instance = DatabaseConnection._internal();

  factory DatabaseConnection() {
    return _instance;
  }

  DatabaseConnection._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'task_manager.db');
    return await openDatabase(
      path,
      version: 4,
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
        dateCompleted TEXT,
        dueDate TEXT,
        dueTime TEXT,
        priority TEXT,
        assignedTo TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Get list of existing columns
    final info = await db.rawQuery('PRAGMA table_info(tasks)');
    final columnNames = <String>{};
    for (var col in info) {
      columnNames.add(col['name'].toString());
    }

    // Version 1 → 2: Add dateCompleted column if it doesn't exist
    if (oldVersion < 2 && !columnNames.contains('dateCompleted')) {
      try {
        await db.execute('ALTER TABLE tasks ADD COLUMN dateCompleted TEXT');
      } catch (e) {
        print('Error adding dateCompleted column: $e');
      }
    }

    // Version 2 → 3: Add new columns if they don't exist
    if (oldVersion < 3) {
      if (!columnNames.contains('dueDate')) {
        try {
          await db.execute('ALTER TABLE tasks ADD COLUMN dueDate TEXT');
        } catch (e) {
          print('Error adding dueDate column: $e');
        }
      }
      if (!columnNames.contains('dueTime')) {
        try {
          await db.execute('ALTER TABLE tasks ADD COLUMN dueTime TEXT');
        } catch (e) {
          print('Error adding dueTime column: $e');
        }
      }
      if (!columnNames.contains('priority')) {
        try {
          await db.execute('ALTER TABLE tasks ADD COLUMN priority TEXT');
        } catch (e) {
          print('Error adding priority column: $e');
        }
      }
      if (!columnNames.contains('assignedTo')) {
        try {
          await db.execute('ALTER TABLE tasks ADD COLUMN assignedTo TEXT');
        } catch (e) {
          print('Error adding assignedTo column: $e');
        }
      }
    }
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
