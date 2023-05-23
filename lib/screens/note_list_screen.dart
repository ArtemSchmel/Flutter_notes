import 'package:flutter/material.dart';
import 'package:notes_app/helper/note_provider.dart';
import 'package:notes_app/screens/note_edit_screen.dart';
import 'package:notes_app/utils/constants.dart';
import 'package:notes_app/widgets/list_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:notes_app/screens/settings_screen.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<NoteProvider>(context, listen: false).getNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              body: Consumer<NoteProvider>(
                child: noNotesUI(context),
                builder: (context, noteprovider, child) => noteprovider.items.length <= 0
                    ? child!
                    : ListView.builder(
                        itemCount: noteprovider.items.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return DynamicHeader();
                          } else {
                            final i = index - 1;
                            final item = noteprovider.items[i];
                            return ListItem(
                            id: item.id,
                            title: item.title,
                            content: item.content,
                            imagePaths: item.imagePaths,
                            date: item.date,
                          );
                          }
                        },
                      ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  goToNoteEditScreen(context);
                },
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.add),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: 0,
                selectedFontSize: 0, // скрываю лейблы в навбаре
                unselectedFontSize: 0, // скрываю лейблы в навбаре
                backgroundColor: Theme.of(context).colorScheme.primary,
                items: [
                  BottomNavigationBarItem(
                    icon: IconButton(
                      icon: Icon(
                        Icons.home,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 30,
                      ),
                      onPressed: () {},
                      alignment: Alignment.center, // выровнять по центру
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      onTap: () {
                        goToSettingsScreen(context);
                      },
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, SettingsScreen.route);
                        },
                        alignment: Alignment.center, // выровнять по центру
                      ),
                    ),
                    label: '',
                  ),
                ],
              ),
            );
          }
        }
        return Container();
      },
    );
  }

  Widget noNotesUI(BuildContext context) {
    return ListView(
      children: [
        DynamicHeader(),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Image.asset(
                'assets/emoji.png',
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: noNotesStyle,
                children: [
                  TextSpan(text: '\nНет заметок\nНажмите на "'),
                  TextSpan(
                    text: '+',
                    style: boldPlus,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        goToNoteEditScreen(context);
                      },
                  ),
                  TextSpan(text: '" чтобы добавить новую заметку'),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  void goToNoteEditScreen(BuildContext context) {
  print('Navigating to NoteEditScreen');
  Navigator.of(context).pushNamed(NoteEditScreen.route);
}

  void goToSettingsScreen(BuildContext context) {
    Navigator.of(context).pushNamed(SettingsScreen.route);
  }
}

class DynamicHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String greeting = getGreeting(now.hour);

    return Container(
      height: 100,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            greeting,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  String getGreeting(int hour) {
    if (hour < 10) {
      return 'Доброе утро!';
    } else if (hour < 20) {
      return 'Добрый день!';
    } else {
      return 'Добрый вечер!';
    }
  }
} 