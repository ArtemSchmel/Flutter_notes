import 'package:flutter/material.dart';
import '/helper/note_provider.dart';
import '../models/note.dart';
import 'package:provider/provider.dart';

class DeletePopUp extends StatelessWidget {
  const DeletePopUp({Key? key, required this.selectedNote}) : super(key: key);
  final Note selectedNote;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: Text('Удалить?'),
      content: Text('Вы действительно хотите удалить замтеку?'),
      actions: [
        TextButton(
          child: Text('Да'),
          onPressed: () {
            Provider.of<NoteProvider>(context, listen: false)
                .deleteNote(selectedNote.id);
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
        TextButton(
          child: Text('Нет'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}