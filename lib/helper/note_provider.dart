import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_app/helper/database_helper.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/utils/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class NoteProvider with ChangeNotifier {
  Note? _selectedNote;
  Note? get selectedNote => _selectedNote;

  List<Note> _items = [];

  List get items {
    return [..._items];
  }

  Note getNote(int id) {
    return _items.firstWhere((note) => note.id == id, orElse: () => Note.empty());
  }

  Future<void> deleteNote(int id) async {
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
    await DatabaseHelper.delete(id);
  }

  Future<void> addOrUpdateNote(
      int id,
      String title,
      String content,
      List<String> imagePaths,
      List<String> videoPaths,
      EditMode editMode) async {
    final note = Note(id, title, content, imagePaths, videoPaths);

    if (editMode == EditMode.ADD) {
      _items.insert(0, note);
    } else {
      final index = _items.indexWhere((item) => item.id == id);
      if (index >= 0) {
        _items[index] = note;
      }
    }

    notifyListeners();

    await DatabaseHelper.insertNoteWithMedia(
      {
        'id': note.id,
        'title': note.title,
        'content': note.content,
      },
      note.imagePaths,
      note.videoPaths,
    );
  }

  Future<void> getNotes() async {
    final notesList = await DatabaseHelper.getNotesFromDB();

    _items = notesList
        .map((item) => Note(
              item['id'] as int,
              item['title'] as String,
              item['content'] as String,
              (item['imagePaths'] as String?)?.split(';') ?? [],
              (item['videoPaths'] as String?)?.split(';') ?? [],
            ))
        .toList();
    notifyListeners();
  }

  Future<void> scheduleNotification(
    String title, String body, DateTime scheduledDate) async {
    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'Local Notification',
      importance: Importance.high,
    );

    var platformDetails = NotificationDetails(android: androidDetails);

    debugPrint('Notification scheduled successfully');

    await FlutterLocalNotificationsPlugin().schedule(
      0,
      title,
      body,
      scheduledDate,
      platformDetails,
      payload: 'Custom_Sound',
      androidAllowWhileIdle: true,
    );
  }
}