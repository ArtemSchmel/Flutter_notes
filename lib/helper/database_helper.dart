import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String tableName = 'notes';
  static Database? _instance;

static Future<Database> database() async {
  final databasePath = await getDatabasesPath();
  return openDatabase(
    join(databasePath, 'notes_database.db'),
    onCreate: (database, version) async {
      await database.execute(
        'CREATE TABLE $tableName(id INTEGER PRIMARY KEY, title TEXT, content TEXT)',
      );
      await database.execute(
        'CREATE TABLE media_files(id INTEGER PRIMARY KEY AUTOINCREMENT, note_id INTEGER, file_path TEXT, file_type TEXT, FOREIGN KEY(note_id) REFERENCES $tableName(id))',
      );
    },
    version: 2,
    onUpgrade: (database, oldVersion, newVersion) async {
      if (oldVersion == 1 && newVersion == 2) {
        await database.execute('ALTER TABLE media_files ADD COLUMN file_type TEXT');
      }
    },
  );
}

  static Future<void> insertNoteWithMedia(
    Map<String, Object?> noteData,
    List<String> imagePaths,
    List<String> videoPaths,
  ) async {
    final database = await DatabaseHelper.database();
    await database.transaction((txn) async {
      final noteId = await txn.insert('notes', noteData, conflictAlgorithm: ConflictAlgorithm.replace);
      for (final path in imagePaths) {
        await txn.insert('media_files', {
          'note_id': noteId,
          'file_path': path,
          'file_type': 'image',
        });
      }
      for (final path in videoPaths) {
        await txn.insert('media_files', {
          'note_id': noteId,
          'file_path': path,
          'file_type': 'video',
        });
      }
    });
  }

  static Future<void> insert(Map<String, Object> noteData) async {
    final database = await DatabaseHelper.database();
    await database.insert(tableName, noteData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, Object?>>> getNotesFromDB() async {
    final database = await DatabaseHelper.database();
    return database.rawQuery('''
      SELECT n.id, n.title, n.content, GROUP_CONCAT(m.file_path) AS imagePaths
      FROM $tableName AS n
      LEFT JOIN media_files AS m ON n.id = m.note_id
      GROUP BY n.id
      ORDER BY n.id DESC
    ''');
  }

  static Future<void> delete(int id) async {
    final database = await DatabaseHelper.database();
    await database.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteMediaFilesForNoteId(int noteId) async {
    final database = await DatabaseHelper.database();
    await database.delete('media_files', where: 'note_id = ?', whereArgs: [noteId]);
  }
}