import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notes_app/helper/note_provider.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/utils/constants.dart';
import 'package:notes_app/widgets/delete_popup.dart';
import 'package:provider/provider.dart';
import 'package:flutter_share/flutter_share.dart';
import 'note_edit_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NoteViewScreen extends StatefulWidget {
  NoteViewScreen({Key? key}) : super(key: key);

  static const route = '/note-view';

  @override
  _NoteViewScreenState createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {

  late final note;
  late DateTime _scheduledTime;
  late Note selectedNote; // Добавьте late перед объявлением переменной
 
  @override
  void didChangeDependencies() {
  super.didChangeDependencies();
  final int id = ModalRoute.of(context)?.settings.arguments as int;
  
  // Получение данных из провайдера вне компонента
  final provider = Provider.of<NoteProvider>(context, listen: false);
  final note = provider.getNote(id);
  final String title = note.title;
  final String content = note.content;
  final List<String> imagePaths = note.imagePaths;
  
  if (note != null) {
    setState(() {
      selectedNote = note;
    });
  }
}

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0.7,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
           IconButton(
            icon: Icon(Icons.share),
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: shareNote,
          ),
          IconButton(
            icon: Icon(Icons.alarm),
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: () async {
              print('Title: ${selectedNote.title}');
              final DateTime now = DateTime.now();
              final TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
              );
              if (selectedTime != null) {
                _scheduledTime = selectedTime as DateTime;
                final provider = Provider.of<NoteProvider>(context, listen: false);
                provider.scheduleNotification(selectedNote.title, selectedNote.content, _scheduledTime);
                Navigator.of(context).pop();
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => _showDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(selectedNote.title,
                style: viewTitleStyle,
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.access_time,
                    size: 18,
                  ),
                ),
                Text(selectedNote.date)
              ],
            ),
            if (selectedNote.imagePaths != null && selectedNote.imagePaths.isNotEmpty) 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.file(File(selectedNote.imagePaths[0])),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                selectedNote.content,
                style: viewContentStyle,
              ),
            ),
          ],
        ),
      ),
            floatingActionButton: FloatingActionButton(
        foregroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditScreen(),
              settings: RouteSettings(arguments: selectedNote.id),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(Icons.edit),
      ),
    );
  }
 void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DeletePopUp(selectedNote: selectedNote);
      },
    );
  }
 Future<void> shareNote() async {
    await FlutterShare.share(
      title: 'Example share',
      text:
          'Тема заметки: ${selectedNote?.title} \n Содержание заметки: ${selectedNote?.content}',
      chooserTitle: 'Where to Share the Notes',
    );
  }
}