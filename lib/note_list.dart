import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:neorganizer/note_editor.dart';
import 'package:webdav_client/webdav_client.dart';

class NoteListRoute extends StatefulWidget {
  const NoteListRoute({super.key});

  @override
  State<NoteListRoute> createState() => _NoteListRouteState();
}

class _NoteListRouteState extends State<NoteListRoute> {
  final Future<List<Note>> _notes = fetchNotes();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Заметки'),
        ),
        body: Center(
          child: FutureBuilder(
            future: _notes,
            builder: (context, snapshot) {
              var notes = snapshot.data ?? [];
              return Column(
                children: notes.map((note) => NoteCard(note: note)).toList(),
              );
            },
          ),
        ));
  }

  static Future<List<Note>> fetchNotes() async {
    // TODO introduce settings
    var client = newClient(
      'XXX',
      user: 'XXX',
      password: 'XXX',
    );
    var files = await client.readDir('/org');
    var notes = <Note>[];
    for (var file in files) {
      var title = file.name;
      var path = file.path;
      var lastUpdate = file.mTime;
      if (title == null ||
          !title.endsWith('.norg') ||
          path == null ||
          lastUpdate == null) {
        continue;
      }
      var content = utf8.decode(await client.read(path));
      notes.add(Note(title: title, content: content, lastUpdate: lastUpdate));
    }
    return notes;
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
