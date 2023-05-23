import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notes_app/helper/note_provider.dart';
import 'package:notes_app/screens/note_edit_screen.dart';
import 'package:notes_app/screens/note_view_screen.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';

class ListItem extends StatelessWidget {
  final int id;
  final String title;
  final String content;
  final List<String> imagePaths;
  final String date;

  final String placeholderImagePath = 'assets/test.png';

  ListItem({
    required this.id,
    required this.title,
    required this.content,
    required this.imagePaths,
    required this.date,
  });

  String? getPreviewImagePath() {
    if (imagePaths.isNotEmpty) {
      // Return the first image path as the preview image
      return imagePaths[0];
    } else {
      // Return null if there are no images
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 135.0,
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, NoteViewScreen.route, arguments: id);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.3),
                offset: Offset(0, 2),
                blurRadius: 10.0,
              ),
            ],
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.surface,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: itemTitle,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        date,
                        overflow: TextOverflow.ellipsis,
                        style: itemDateStyle,
                      ),
                      SizedBox(height: 8.0),
                      Expanded(
                        child: Text(
                          content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: itemContentStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (getPreviewImagePath() != null) ...[
                SizedBox(width: 12.0),
                Container(
                  width: 80.0,
                  height: 95.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: DecorationImage(
                      image: FileImage(File(getPreviewImagePath()!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}