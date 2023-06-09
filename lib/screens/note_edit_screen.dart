import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/utils/constants.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:notes_app/helper/note_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/widgets/delete_popup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'note_view_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class NoteEditScreen extends StatefulWidget {
  static const route = '/edit-note';
  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  List<File> _images = [];

  final picker = ImagePicker();

  bool firstTime = true;
  Note? selectedNote;
  late int? id;

    @override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (firstTime) {
    id = ModalRoute.of(context)?.settings.arguments as int?;

    if (id != null) {
      selectedNote = Provider.of<NoteProvider>(
        context,
        listen: false,
      ).getNote(id!);
      if (selectedNote != null) {
        titleController.text = selectedNote!.title;
        contentController.text = selectedNote!.content;
        if (selectedNote!.imagePaths.isNotEmpty) {
          _images = selectedNote!.imagePaths.map((path) => File(path)).toList();
        }
      }
    }
    firstTime = false;

    setState(() {}); // Trigger UI rebuild
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
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: () {
              getImage(ImageSource.camera);
            },
          ),
          IconButton(
            icon: Icon(Icons.insert_photo),
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: () {
              getImage(ImageSource.gallery);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: () {
              if (id != null) {
                _showDialog();
              } else {
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 10.0,
                right: 5.0,
                top: 10.0,
                bottom: 5.0,
              ),
              child: TextField(
                controller: titleController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: createTitle,
                decoration: InputDecoration(
                  hintText: 'Введите заголовок заметки',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_images.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10.0),
                height: 250.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 8.0),
                          width: 80.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            image: DecorationImage(
                              image: FileImage(_images[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5.0,
                          right: 5.0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _images.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 5.0,
                top: 10.0,
                bottom: 5.0,
              ),
              child: TextField(
                controller: contentController,
                maxLines: null,
                style: createContent,
                decoration: InputDecoration(
                  hintText: 'Введите что-нибудь...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
            floatingActionButton: FloatingActionButton(
        foregroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          if (titleController.text.isEmpty) 
            titleController.text = 'Заметка без темы';
          saveNote(context);
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(Icons.save),
      ),
    );
  }

void getImage(ImageSource imageSource) async {
  List<Asset>? assets = await MultiImagePicker.pickImages(
    maxImages: 999,
    enableCamera: true,
    selectedAssets: [],
    materialOptions: MaterialOptions(
      actionBarColor: "#abcdef",
      statusBarColor: "#abcdef",
      actionBarTitle: "Select Images",
      allViewTitle: "All Photos",
      selectionLimitReachedText: "You have reached the maximum limit.",
    ),
  );

  if (assets == null) return;

  List<File> tempImages = [];

  for (var asset in assets) {
    final byteData = await asset.getByteData();
    final buffer = byteData.buffer;
    final tempDir = await getTemporaryDirectory();
    final fileName = Path.basename(asset.name ?? 'image.png');
    final tempFilePath = '${tempDir.path}/$fileName';
    final file = await File(tempFilePath).writeAsBytes(buffer.asUint8List());

    tempImages.add(file);
  }

  setState(() {
    _images.addAll(tempImages);
  });
}

void saveNote(BuildContext context) {
  String title = titleController.text.trim();
  String content = contentController.text.trim();
  List<String> imagePaths = _images.map((image) => image.path).toList();

  final NoteProvider noteProvider = Provider.of<NoteProvider>(context, listen: false);

  if (noteProvider.selectedNote != null) {
    noteProvider.addOrUpdateNote(
      id: noteProvider.selectedNote!.id,
      title: title,
      content: content,
      imagePaths: imagePaths,
    );
    Navigator.of(context).pop();
  } else {
    int newId = DateTime.now().millisecondsSinceEpoch;
    noteProvider.addOrUpdateNote(
      id: newId,
      title: title,
      content: content,
      imagePaths: imagePaths,
    );
    Navigator.of(context).pushReplacementNamed(
      NoteViewScreen.route,
      arguments: newId, // Передача id новой заметки как аргумент
    ).whenComplete(()=>setState((){}));
  }
  @override
    void dispose() {
      titleController.dispose();
      contentController.dispose();
      super.dispose();
    }
}

void _showDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return DeletePopUp(selectedNote: selectedNote!);
    },
  );
}

  Future<void> scheduleNotification(
      String title, String body, DateTime scheduledDate) async {
    var androidDetails = new AndroidNotificationDetails(
        'channelId', 'Local Notification',
        importance: Importance.high);

    var platformDetails = new NotificationDetails(android: androidDetails);

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