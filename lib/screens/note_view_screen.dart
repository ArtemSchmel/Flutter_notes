import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_app/helper/note_provider.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/utils/constants.dart';
import 'package:notes_app/widgets/delete_popup.dart';
import 'package:provider/provider.dart';
import 'package:flutter_share/flutter_share.dart';
import 'note_edit_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:video_player/video_player.dart';

class NoteViewScreen extends StatefulWidget {
  NoteViewScreen({Key? key}) : super(key: key);

  static const route = '/note-view';

  @override
  _NoteViewScreenState createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  late DateTime _scheduledTime;
  late Note selectedNote = Note.empty();

  final List<VideoPlayerController> _videoPlayerControllers = [];
  final List<Future<void>> _initializeVideoPlayerFutures = [];

  @override
    @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final int id = ModalRoute.of(context)?.settings.arguments as int;
    final provider = Provider.of<NoteProvider>(context, listen: false);
    final note = await provider.getNote(id);

  setState(() {
    selectedNote = note;
    _initializeVideoPlayers(); // Вызов метода после загрузки данных
  });
}
  
@override
void initState() {
  super.initState();
  _initializeVideoPlayers();
  setState(() {});
}

  void _initializeVideoPlayers() {
    for (final videoPath in selectedNote.videoPaths) {
      final videoPlayerController = VideoPlayerController.file(File(videoPath));
      final initializeVideoPlayerFuture = videoPlayerController.initialize();
      _videoPlayerControllers.add(videoPlayerController);
      _initializeVideoPlayerFutures.add(initializeVideoPlayerFuture);
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
              child: Text(
                selectedNote.title,
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
                Text(selectedNote.date),
              ],
            ),
            if (selectedNote.imagePaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    for (int i = 0; i < selectedNote.imagePaths.length; i++)
                      Column(
                        children: [
                          Image.file(File(selectedNote.imagePaths[i])),
                          SizedBox(height: 8.0), // Пустое расстояние между изображениями
                        ],
                      ),
                  ],
                ),
              ),
            if (selectedNote.videoPaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    for (int i = 0; i < selectedNote.videoPaths.length; i++)
                      Column(
                        children: [
                        FutureBuilder(
                          future: _initializeVideoPlayerFutures[i],
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              // Обработка ошибок
                              print('Error loading video: ${snapshot.error}');
                              return Text('Error loading video: ${snapshot.error}');
                            }
                            if (snapshot.connectionState == ConnectionState.done) {
                              final videoPlayerController = _videoPlayerControllers[i];
                              return AspectRatio(
                                aspectRatio: videoPlayerController.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerControllers[i]),
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.play_arrow),
                                onPressed: () {
                                  setState(() {
                                    _videoPlayerControllers[i].play();
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.pause),
                                onPressed: () {
                                  setState(() {
                                   _videoPlayerControllers[i].pause();
                                  });
                                },       
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0), // Пустое расстояние между видеофайлами
                        ],
                      ),
                  ],
                ),
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditScreen(),
              settings: RouteSettings(arguments: selectedNote.id),
            ),
          ).whenComplete(() {
            if (mounted) {
              setState(() {});
            }
          });
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

  @override
  void dispose() {
    for (final controller in _videoPlayerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> shareNote() async {
    await FlutterShare.share(
      title: 'Example share',
      text:
          'Тема заметки: ${selectedNote.title} \n Содержание заметки: ${selectedNote.content}',
      chooserTitle: 'Where to Share the Notes',
    );
  }
}