import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String tableName = 'notes'; // Add the tableName property

  static Database? _instance; // Add the instance property

  static Future<Database> database() async {
    final databasePath = await getDatabasesPath();
    return openDatabase(
      join(databasePath, 'notes_database.db'),
      onCreate: (database, version) {
        return database.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY, title TEXT, content TEXT)',
        ).then((value) {
          return database.execute(
            'CREATE TABLE media_files(id INTEGER PRIMARY KEY AUTOINCREMENT, noteId INTEGER, path TEXT)',
          );
        });
      },
      version: 2, // Increase the version number
    );
  }

 static Future<void> insertNoteWithMedia(Map<String, Object?> noteData, List<String> mediaPaths) async {
    final database = await DatabaseHelper.database();
    await database.transaction((txn) async {
      final noteId = await txn.insert('notes', noteData, conflictAlgorithm: ConflictAlgorithm.replace);
      for (final path in mediaPaths) {
        await txn.insert('media_files', {
          'note_id': noteId,
          'file_path': path,
        });
      }
    });
  }

static Future<void> insert(Map<String, Object> noteData) async {
  final database = await DatabaseHelper.database();
  await database.insert('notes', noteData, conflictAlgorithm: ConflictAlgorithm.replace);
}

  static Future<List<Map<String, Object?>>> getNotesFromDB() async {
  final database = await DatabaseHelper.database();
  return database.rawQuery('''
    SELECT n.id, n.title, n.content, GROUP_CONCAT(m.file_path) AS imagePaths
    FROM notes AS n
    LEFT JOIN media_files AS m ON n.id = m.note_id
    GROUP BY n.id
    ORDER BY n.id DESC
  ''');
}

  static Future<void> delete(int id) async {
    final database = await DatabaseHelper.database();
    await database.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  static Future<void> deleteMediaFilesForNoteId(int noteId) async {
    final database = await DatabaseHelper.database();
    await database.delete('media_files', where: 'note_id = ?', whereArgs: [noteId]);
  }

  static Future<void> _upgradeDatabaseV1ToV2(Database database) async {
    await database.execute(
      'CREATE TABLE media_files('
      'id INTEGER PRIMARY KEY, '
      'note_id INTEGER, '
      'file_path TEXT, '
      'FOREIGN KEY(note_id) REFERENCES notes(id))'
    );
  }
}