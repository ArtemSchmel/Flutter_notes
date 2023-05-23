import 'package:intl/intl.dart';

class Note {
  int _id;
  String _title;
  String _content;
  List<String> _imagePaths;

  Note(this._id, this._title, this._content, this._imagePaths);

  int get id => _id;
  String get title => _title;
  String get content => _content;
  List<String> get imagePaths => _imagePaths;

  factory Note.empty() {
    return Note(0, '', '', []);
  }

  String get date {
    final date = DateTime.fromMillisecondsSinceEpoch(id);
    return DateFormat('h:mm a, dd/MM/yyyy').format(date);
  }
}