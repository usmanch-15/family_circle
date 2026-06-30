import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'family_circle_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_messages (
            id TEXT PRIMARY KEY,
            familyId TEXT,
            senderName TEXT,
            text TEXT,
            type TEXT,
            mediaUrl TEXT,
            sentAt INTEGER,
            synced INTEGER DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_messages (
            id TEXT PRIMARY KEY,
            familyId TEXT,
            text TEXT,
            createdAt INTEGER
          )
        ''');
      },
    );
  }

  // Message offline cache mein save karna
  Future<void> cacheMessage(Map<String, dynamic> message) async {
    final db = await database;
    await db.insert(
      'cached_messages',
      message,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Cached messages wapis lana - jab internet na ho
  Future<List<Map<String, dynamic>>> getCachedMessages(String familyId) async {
    final db = await database;
    return await db.query(
      'cached_messages',
      where: 'familyId = ?',
      whereArgs: [familyId],
      orderBy: 'sentAt DESC',
    );
  }

  // Internet na ho to message yahan rakho, baad mein bhejna hai
  Future<void> addPendingMessage({
    required String id,
    required String familyId,
    required String text,
  }) async {
    final db = await database;
    await db.insert('pending_messages', {
      'id': id,
      'familyId': familyId,
      'text': text,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Internet wapis aaye to pending messages nikal kar bhejo
  Future<List<Map<String, dynamic>>> getPendingMessages() async {
    final db = await database;
    return await db.query('pending_messages');
  }

  Future<void> clearPendingMessage(String id) async {
    final db = await database;
    await db.delete('pending_messages', where: 'id = ?', whereArgs: [id]);
  }
}
