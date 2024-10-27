import 'package:flutter/material.dart';
import 'package:neorganizer/note_editor.dart';

class NoteListRoute extends StatelessWidget {
  const NoteListRoute({super.key});

  @override
  Widget build(BuildContext context) {
    var notes = [
      Note(
          title: 'Список покупок',
          content: '* ( ) Хлеб\n'
              '* ( ) Молоко\n',
          lastUpdate: DateTime(2024, 10, 27)),
      Note(
          title: 'Работа',
          content: '* ( ) Написать тесты\n'
              '* ( ) Провести ревью\n',
          lastUpdate: DateTime(2024, 10, 26)),
      Note(
          title: 'Учёба',
          content: '* ( ) Написать введение к диплому\n'
              '* ( ) Сделать ДЗ\n',
          lastUpdate: DateTime(2024, 10, 25)),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Заметки'),
      ),
      body: Center(
          child: Column(
        children: notes.map((note) => NoteCard(note: note)).toList(),
      )),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required var this.note});

  @override
  Widget build(BuildContext context) {
    var formattedLastUpdate =
        "${note.lastUpdate.day}.${note.lastUpdate.month}.${note.lastUpdate.year}";
    return GestureDetector(
      onTap: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => NoteEditor(note: note)))
      },
      child: Card(
          child: Column(
        children: [
          ListTile(
            title: Text(note.title),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(Icons.calendar_month),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(formattedLastUpdate),
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}

class Note {
  final String title;
  final String content;
  final DateTime lastUpdate;

  const Note(
      {required var this.title,
      required var this.content,
      required var this.lastUpdate});
}
