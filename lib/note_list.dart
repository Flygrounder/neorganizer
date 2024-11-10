import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:neorganizer/note_editor.dart';
import 'package:neorganizer/settings.dart';
import 'package:neorganizer/top_bar.dart';
import 'package:webdav_client/webdav_client.dart';

import 'bottom_bar.dart';

class NoteListRoute extends StatelessWidget {
  final Future<List<Note>> _notes = fetchNotes();

  NoteListRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar('Заметки', displayBackButton: false),
      body: Center(
        child: FutureBuilder(
          future: _notes,
          builder: (context, snapshot) {
            var notes = snapshot.data ?? [];
            return ListView(
              children: notes.map((note) => NoteCard(note: note)).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.create),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  TextEditingController titleController =
                      TextEditingController();
                  return AlertDialog(
                      title: const Text('Создание заметки'),
                      content: TextField(
                          controller: titleController,
                          decoration:
                              const InputDecoration(label: Text('Название'))),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              var settings =
                                  await WebDavSettingsStorage.loadSettings();
                              if (context.mounted) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NoteEditorRoute(
                                            note: Note(
                                                title: titleController.text,
                                                content: '',
                                                path:
                                                    "${settings.directory}/${titleController.text}.norg",
                                                lastUpdate: DateTime.now()))));
                              }
                            },
                            child: const Text('СОЗДАТЬ'))
                      ]);
                });
          }),
      bottomNavigationBar: const BottomBar(BottomBarTab.notes),
    );
  }

  static Future<List<Note>> fetchNotes() async {
    var settings = await WebDavSettingsStorage.loadSettings();
    var client = newClient(
      settings.address,
      user: settings.username,
      password: settings.password,
    );
    var files = await client.readDir(settings.directory);
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
      notes.add(Note(
          title: title, content: content, path: path, lastUpdate: lastUpdate));
    }
    notes.sort(
        (first, second) => -first.lastUpdate.compareTo(second.lastUpdate));
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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NoteEditorRoute(note: note)))
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
  final String path;
  final DateTime lastUpdate;

  const Note(
      {required var this.title,
      required var this.content,
      required var this.path,
      required var this.lastUpdate});
}
